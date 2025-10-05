# service.R
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(jsonlite)
  library(rlang)
})

# --- Parse JSON payload into a named numeric vector duties_1..duties_30 ---
.parse_new_participant <- function(json_str) {
  x <- tryCatch(fromJSON(json_str, simplifyVector = TRUE), error = function(e) NULL)
  if (is.null(x)) stop("Invalid JSON.")

  # Case A: bare array of 30 numbers
  if (is.numeric(x) && length(x) == 30) {
    names(x) <- paste0("duties_", 1:30)
    return(x)
  }

  # Case B: { duties: [ ...30 numbers... ] } OR { duties: { duties_1:..., ... } }
  if (is.list(x) && !is.null(x$duties)) {
    d <- x$duties
    if (is.numeric(d) && length(d) == 30) {
      names(d) <- paste0("duties_", 1:30)
      return(d)
    }
    if (is.numeric(d) && !is.null(names(d))) {
      return(d[paste0("duties_", 1:30)])
    }
  }

  # Case C: bare named object { duties_1:..., ..., duties_30:... }
  if (is.list(x) && !is.null(names(x)) && all(paste0("duties_", 1:30) %in% names(x))) {
    v <- unlist(x[paste0("duties_", 1:30)])
    return(v)
  }

  stop("JSON must include 30 duty values as array or named object (duties_1..duties_30).")
}

# --- Load & prepare training data once per request (simple & clear). ---
# If needed, you can cache this in a global for speed.
.prepare_training <- function(csv_path) {
  if (!file.exists(csv_path)) stop(paste0("CSV not found: ", csv_path))
  raw <- suppressWarnings(read.csv(csv_path, stringsAsFactors = FALSE))

  if ("pid3" %in% names(raw)) raw$pid3 <- trimws(raw$pid3)
  names(raw) <- gsub("^duties_full_list_", "duties_", names(raw))

  duty_cols <- paste0("duties_", 1:30)
  missing_cols <- setdiff(duty_cols, names(raw))
  if (length(missing_cols)) {
    stop(paste0("Training CSV is missing columns: ", paste(missing_cols, collapse = ", ")))
  }

  clean <- raw %>%
    mutate(across(all_of(duty_cols), ~ case_when(
      .x %in% c("Civic responsibility", "Civic Responsibility") ~ 1,
      .x %in% c("Not a civic responsibility", "Not a Civic Responsibility") ~ 0,
      TRUE ~ suppressWarnings(as.numeric(.x))
    ))) %>%
    mutate(
      urban_binary = case_when(
        urban == "Urban" ~ "Urban",
        urban %in% c("Suburban", "Rural") ~ "Suburban/Rural",
        TRUE ~ NA_character_
      ),
      ideology_tri = case_when(
        ideology %in% c("Liberal", "Slightly liberal", "Very liberal") ~ "Liberal",
        ideology == "Moderate" ~ "Moderate",
        ideology %in% c("Conservative", "Slightly conservative", "Very conservative") ~ "Conservative",
        TRUE ~ NA_character_
      ),
      age_binary = case_when(
        suppressWarnings(as.numeric(age)) > 50 ~ "old",
        suppressWarnings(as.numeric(age)) <= 50 ~ "young",
        TRUE ~ NA_character_
      )
    )

  if (!("Weight" %in% names(clean))) clean$Weight <- 1

  list(data = clean, duty_cols = duty_cols)
}

# --- Core predictor returning a list (plumber will JSON-serialize it) ---
.predict_groups_with_probs <- function(new_vec, df, duty_cols, group_vars, temperature = 1) {
  nd <- as.numeric(new_vec)
  names(nd) <- names(new_vec)
  out <- list()

  for (group_var in group_vars) {
    prototype_df <- df %>%
      filter(!is.na(.data[[group_var]])) %>%
      group_by(.data[[group_var]]) %>%
      summarise(across(all_of(duty_cols), ~ weighted.mean(.x, w = Weight, na.rm = TRUE)),
                .groups = "drop") %>%
      rename(group = !!sym(group_var))

    distances <- prototype_df %>%
      rowwise() %>%
      mutate(dist = sum(abs(c_across(all_of(duty_cols)) - nd[duty_cols]), na.rm = TRUE)) %>%
      ungroup() %>%
      select(group, dist) %>%
      mutate(
        similarity = 1 / (1 + dist),
        alignment  = 1 - (dist / length(duty_cols))
      )

    logits <- -distances$dist / temperature
    logits <- logits - max(logits, na.rm = TRUE)
    distances$prob <- as.numeric(exp(logits) / sum(exp(logits)))

    winner <- distances %>% slice_min(dist, n = 1, with_ties = FALSE)

    out[[group_var]] <- list(
      predicted  = unname(winner$group),
      dist       = round(as.numeric(winner$dist), 4),
      prob       = round(as.numeric(winner$prob), 4),
      similarity = round(as.numeric(winner$similarity), 4),
      alignment  = round(as.numeric(winner$alignment), 3)
    )
  }
  out
}

# --- Public function used by api.R ---
predict_service <- function(csv_path, payload_json, temperature = 1) {
  # parse input
  np_raw <- .parse_new_participant(payload_json)
  np <- suppressWarnings(as.numeric(np_raw))
  if (any(is.na(np))) stop("All duty values must be numeric (0/1).")
  names(np) <- names(np_raw)

  # training data
  prep <- .prepare_training(csv_path)
  df <- prep$data
  duty_cols <- prep$duty_cols
  group_vars <- c("urban_binary", "ideology_tri", "age_binary")

  # predict
  preds <- .predict_groups_with_probs(np, df, duty_cols, group_vars, temperature = temperature)

  # return list (plumber will JSON it)
  list(predictions = preds)
}
