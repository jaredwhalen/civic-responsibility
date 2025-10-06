# service.R
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(jsonlite)
  library(rlang)
})

# --- Parse JSON payload into a named numeric vector duties_1..duties_30 (with NAs allowed) ---
.parse_new_participant <- function(json_str) {
  x <- tryCatch(jsonlite::fromJSON(json_str, simplifyVector = FALSE),
                error = function(e) NULL)
  if (is.null(x)) stop("Invalid JSON.")

  d <- if (!is.null(x$duties)) x$duties else x

  keys <- paste0("duties_", 1:30)
  v <- rep(NA_real_, 30); names(v) <- keys

  as_num <- function(val) {
    if (is.null(val)) return(NA_real_)
    if (is.character(val) && (val == "" || tolower(val) == "na")) return(NA_real_)
    suppressWarnings(as.numeric(val))
  }

  if (is.list(d) && !is.null(names(d))) {
    # Named object: fill by explicit key
    for (nm in names(d)) {
      m <- regmatches(nm, regexec("^duties_(\\d+)$", nm))[[1]]
      if (length(m) == 2) {
        idx <- as.integer(m[2])
        if (!is.na(idx) && idx >= 1 && idx <= 30) v[idx] <- as_num(d[[nm]])
      }
    }
  } else if (is.list(d) && is.null(names(d))) {
    # Array: positionally map 1..length(d)
    n <- min(length(d), 30L)
    for (i in seq_len(n)) v[i] <- as_num(d[[i]])
  } else {
    stop("Expected 'duties' as array or object (or top-level duties_* keys).")
  }

  if (all(is.na(v))) stop("No answers provided (all 30 duties are missing).")
  v
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

# --- Core predictor: handles skipped items (NAs) by using answered-only average distance ---
.predict_groups_with_probs <- function(new_vec, df, duty_cols, group_vars, temperature = 1) {
  nd <- as.numeric(new_vec); names(nd) <- names(new_vec)

  answered_idx <- which(!is.na(nd[duty_cols]))
  k <- length(answered_idx)
  if (k == 0) stop("No answered items found in payload.")
  used_cols <- duty_cols[answered_idx]

  out <- list()

  for (group_var in group_vars) {
    prototype_df <- df %>%
      dplyr::filter(!is.na(.data[[group_var]])) %>%
      dplyr::group_by(.data[[group_var]]) %>%
      dplyr::summarise(
        dplyr::across(dplyr::all_of(duty_cols), ~ stats::weighted.mean(.x, w = Weight, na.rm = TRUE)),
        .groups = "drop"
      ) %>%
      dplyr::rename(group = !!rlang::sym(group_var))

    # Compute sum of absolute diffs only over answered items, then normalize by k
    distances <- prototype_df %>%
      dplyr::rowwise() %>%
      dplyr::mutate(
        dist_sum = sum(abs(dplyr::c_across(dplyr::all_of(used_cols)) - nd[used_cols]), na.rm = TRUE),
        dist     = dist_sum / k,                    # average distance in [0,1]
        similarity = 1 - dist,                      # [0,1], higher is closer
        alignment  = similarity
      ) %>%
      dplyr::ungroup() %>%
      dplyr::select(group, dist_sum, dist, similarity, alignment)

    # Softmax over negative average distance
    logits <- -distances$dist / temperature
    logits <- logits - max(logits, na.rm = TRUE)
    distances$prob <- as.numeric(exp(logits) / sum(exp(logits)))

    winner <- distances %>% dplyr::slice_min(dist, n = 1, with_ties = FALSE)

    out[[group_var]] <- list(
      predicted   = unname(winner$group),
      # 'dist' is now the average distance over answered items
      dist        = round(as.numeric(winner$dist), 4),
      dist_sum    = round(as.numeric(winner$dist_sum), 4),
      prob        = round(as.numeric(winner$prob), 4),
      similarity  = round(as.numeric(winner$similarity), 4),
      alignment   = round(as.numeric(winner$alignment), 3),
      answered    = k,
      coverage    = round(k / length(duty_cols), 3)
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
