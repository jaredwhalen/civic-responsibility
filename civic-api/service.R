# service.R (minimal output, no skips)
suppressPackageStartupMessages({
  library(dplyr)
  library(jsonlite)
  library(rlang)
})

# ───────── Parse input (no skips allowed) ─────────
# Accepts:
#   {"duties":[0/1 x30]}  OR
#   {"duties":{"duties_1":0/1, ..., "duties_30":0/1}}  OR
#   {"duties_1":..., ..., "duties_30":...}
# Returns: numeric vector length 30, values in {0,1}
.parse_new_participant <- function(json_str) {
  x <- tryCatch(jsonlite::fromJSON(json_str, simplifyVector = FALSE),
                error = function(e) NULL)
  if (is.null(x)) stop("Invalid JSON.")
  d <- if (!is.null(x$duties)) x$duties else x

  keys <- paste0("duties_", 1:30)

  # Flatten
  u <- unlist(d, use.names = TRUE)

  # Named object with duties_*
  if (!is.null(names(u)) && all(keys %in% names(u)) && length(u) >= 30) {
    v <- as.numeric(u[keys])
  } else if (length(u) == 30 && is.null(names(u))) {
    # Bare array of length 30
    v <- as.numeric(u)
    names(v) <- keys
  } else if (all(keys %in% names(x))) {
    v <- as.numeric(unlist(x[keys]))
    names(v) <- keys
  } else {
    stop("Expected 30 answers: array of length 30 or named duties_1..duties_30.")
  }

  if (any(is.na(v))) stop("All 30 duty values must be numeric 0/1 (no skips).")
  if (!all(v %in% c(0, 1))) stop("All 30 duty values must be 0 or 1.")
  v
}

# ───────── Prepare training data (one-time) ─────────
.prepare_training <- function(csv_path) {
  if (!file.exists(csv_path)) stop(paste0("CSV not found: ", csv_path))
  raw <- suppressWarnings(read.csv(csv_path, stringsAsFactors = FALSE))

  # Clean column names / recode duties to 0/1
  if ("pid3" %in% names(raw)) raw$pid3 <- trimws(raw$pid3)
  names(raw) <- gsub("^duties_full_list_", "duties_", names(raw))
  duty_cols <- paste0("duties_", 1:30)
  missing_cols <- setdiff(duty_cols, names(raw))
  if (length(missing_cols)) {
    stop(paste0("Training CSV is missing: ", paste(missing_cols, collapse = ", ")))
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

# Build weighted-mean prototype table for a grouping variable
.build_prototype <- function(df, duty_cols, group_var) {
  df %>%
    filter(!is.na(.data[[group_var]])) %>%
    group_by(.data[[group_var]]) %>%
    summarise(
      across(all_of(duty_cols), ~ weighted.mean(.x, w = Weight, na.rm = TRUE)),
      .groups = "drop"
    ) %>%
    rename(group = !!sym(group_var))
}

# ───────── In-memory cache (reloads if CSV changes) ─────────
.cache <- new.env(parent = emptyenv())

get_training <- function(csv_path) {
  finfo <- file.info(csv_path)
  if (is.na(finfo$mtime)) stop("CSV not found: ", csv_path)

  if (is.null(.cache$csv_path) ||
      !identical(.cache$csv_path, csv_path) ||
      is.null(.cache$mtime) ||
      .cache$mtime < finfo$mtime) {

    prep <- .prepare_training(csv_path)
    df <- prep$data
    duty_cols <- prep$duty_cols
    group_vars <- c("urban_binary", "ideology_tri", "age_binary")

    protos <- lapply(group_vars, function(g) .build_prototype(df, duty_cols, g))
    names(protos) <- group_vars

    .cache$csv_path   <- csv_path
    .cache$mtime      <- finfo$mtime
    .cache$duty_cols  <- duty_cols
    .cache$group_vars <- group_vars
    .cache$protos     <- protos
  }
  .cache
}

# ───────── Prediction (minimal output) ─────────
# match = 1 - mean(|prototype - answers|) over all 30 items  ∈ [0,1]
.predict_minimal <- function(answers_vec, cache) {
  nd <- as.numeric(answers_vec); names(nd) <- names(answers_vec)
  duty_cols  <- cache$duty_cols
  group_vars <- cache$group_vars
  out <- list()

  for (group_var in group_vars) {
    proto <- cache$protos[[group_var]]

    scores <- proto %>%
      rowwise() %>%
      mutate(
        avg_dist = mean(abs(c_across(all_of(duty_cols)) - nd[duty_cols]), na.rm = TRUE),
        match    = 1 - avg_dist
      ) %>%
      ungroup() %>%
      select(group, match)

    winner <- scores %>% slice_max(match, n = 1, with_ties = FALSE)

    out[[group_var]] <- list(
      predicted = unname(winner$group),
      match     = round(as.numeric(winner$match), 3)  # 0..1 ; UI can show as %
    )
  }
  out
}

# ───────── Public entry used by api.R ─────────
predict_service <- function(csv_path, payload_json, temperature = 1) { # temperature unused now
  # Parse strict 30× 0/1 input (no skips)
  np <- .parse_new_participant(payload_json)

  # Load/calc cached artifacts
  cache <- get_training(csv_path)

  # Predict
  list(predictions = .predict_minimal(np, cache))
}
