# service.R  — API-friendly script shaped like the original Rmd

# ─────────────────────────────────────────────────────────
# Get Started  (same section name as original)
# ─────────────────────────────────────────────────────────
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(jsonlite)
  library(rlang)
})

select <- dplyr::select

# ─────────────────────────────────────────────────────────
# Data Org  (same variable names as original)
# ─────────────────────────────────────────────────────────
.load_and_clean <- function(csv_path) {

  # Import Data
  Data_Raw <- read.csv(csv_path, stringsAsFactors = FALSE)

  Data_Clean <- Data_Raw %>%
    mutate(pid3 = trimws(pid3))  # Remove leading & trailing spaces

  # Rename duties_full_list_X to duties_X
  names(Data_Clean) <- gsub("^duties_full_list_", "duties_", names(Data_Clean))

  # Select just the civic duty columns
  duty_vars <- grep("^duties_\\d+$", names(Data_Clean), value = TRUE)

  # Recode all duty items as 1 (Civic obligation) and 0 (Not a civic obligation)
  Data_Clean <- Data_Clean %>%
    mutate(across(all_of(duty_vars), ~ case_when(
      .x == "Civic responsibility" ~ 1,
      .x == "Not a civic responsibility" ~ 0,
      TRUE ~ suppressWarnings(as.numeric(.x))
    )))

  # Binarize
  Data_Clean <- Data_Clean %>%
    mutate(
      urban_binary = case_when(
        urban == "Urban" ~ "Urban",
        urban %in% c("Suburban", "Rural") ~ "Suburban/Rural",
        TRUE ~ NA_character_
      ),
      ideology_tri = case_when(
        ideology %in% c("Liberal", "Slightly liberal", "Very liberal") ~ "Liberal",
        ideology %in% c("Moderate") ~ "Moderate",
        ideology %in% c("Conservative", "Slightly conservative", "Very conservative") ~ "Conservative",
        TRUE ~ NA_character_
      ),
      age_binary = case_when(
        suppressWarnings(as.numeric(age)) > 50 ~ "old",
        suppressWarnings(as.numeric(age)) <= 50 ~ "young",
        TRUE ~ NA_character_
      )
    )

  if (!("Weight" %in% names(Data_Clean))) Data_Clean$Weight <- 1

  list(
    Data_Clean = Data_Clean,
    duty_cols = paste0("duties_", 1:30),
    group_vars = c("urban_binary", "ideology_tri", "age_binary")
  )
}

# ─────────────────────────────────────────────────────────
# Model  (now also returns `match`)
#   - `match` = 1 - mean(|prototype - new_data_row|), over all 30 items
#   - Disallows skips: caller must pass 30 numeric 0/1s
# ─────────────────────────────────────────────────────────
predict_groups <- function(new_data_row, df, duty_cols, group_vars) {
  predictions <- list()

  # Ensure vector of length 30 numeric 0/1
  if (is.data.frame(new_data_row)) new_data_row <- unlist(new_data_row[1, ], use.names = TRUE)
  new_data_row <- as.numeric(new_data_row)
  if (length(new_data_row) != length(duty_cols) || any(is.na(new_data_row)) || !all(new_data_row %in% c(0,1))) {
    stop("new_data_row must be 30 numeric 0/1 values (no skips).")
  }

  for (group_var in group_vars) {
    # Compute weighted prototypes for each group
    prototype_df <- df %>%
      filter(!is.na(.data[[group_var]])) %>%
      group_by(.data[[group_var]]) %>%
      summarise(across(all_of(duty_cols), ~ weighted.mean(.x, w = Weight, na.rm = TRUE)), .groups = "drop") %>%
      rename(group = !!sym(group_var))

    # Compute mean Manhattan distance & match to each group prototype
    distances <- prototype_df %>%
      rowwise() %>%
      mutate(
        dist_mean = mean(abs(c_across(all_of(duty_cols)) - new_data_row)), # scaled 0..1
        match = 1 - dist_mean
      ) %>%
      ungroup()

    # Identify the closest group
    best <- distances %>% slice_min(dist_mean, n = 1, with_ties = FALSE)
    predictions[[group_var]] <- list(
      predicted = unname(best$group),
      match = round(as.numeric(best$match), 3)   # 0..1; multiply by 100 in UI
    )
  }

  return(predictions)
}

# ─────────────────────────────────────────────────────────
# API helper: parse participant JSON
# Accepts:
#   {"duties":[0/1 x30]}  OR
#   {"duties":{"duties_1":0/1,...,"duties_30":0/1}}  OR
#   {"duties_1":..., ..., "duties_30":...}
# ─────────────────────────────────────────────────────────
.parse_new_participant_strict <- function(json_str) {
  x <- tryCatch(fromJSON(json_str, simplifyVector = FALSE), error = function(e) NULL)
  if (is.null(x)) stop("Invalid JSON.")

  d <- if (!is.null(x$duties)) x$duties else x
  keys <- paste0("duties_", 1:30)
  u <- unlist(d, use.names = TRUE)

  if (!is.null(names(u)) && all(keys %in% names(u)) && length(u) >= 30) {
    v <- as.numeric(u[keys])
  } else if (length(u) == 30 && is.null(names(u))) {
    v <- as.numeric(u); names(v) <- keys
  } else if (all(keys %in% names(x))) {
    v <- as.numeric(unlist(x[keys])); names(v) <- keys
  } else {
    stop("Expected 30 answers: array of length 30 or named duties_1..duties_30.")
  }

  if (any(is.na(v)) || !all(v %in% c(0,1))) {
    stop("All 30 duty values must be numeric 0/1 (no skips).")
  }
  v
}

# ─────────────────────────────────────────────────────────
# Cache: keep cleaned data in-memory for speed
# ─────────────────────────────────────────────────────────
.cache <- new.env(parent = emptyenv())

.get_prepared <- function(csv_path) {
  finfo <- file.info(csv_path)
  if (is.na(finfo$mtime)) stop("CSV not found: ", csv_path)

  if (is.null(.cache$csv_path) ||
      !identical(.cache$csv_path, csv_path) ||
      is.null(.cache$mtime) ||
      .cache$mtime < finfo$mtime) {

    prepared <- .load_and_clean(csv_path)
    .cache$csv_path  <- csv_path
    .cache$mtime     <- finfo$mtime
    .cache$Data_Clean <- prepared$Data_Clean
    .cache$duty_cols  <- prepared$duty_cols
    .cache$group_vars <- prepared$group_vars
  }
  list(
    Data_Clean = .cache$Data_Clean,
    duty_cols  = .cache$duty_cols,
    group_vars = .cache$group_vars
  )
}

# ─────────────────────────────────────────────────────────
# API entry (used by api.R)
# ─────────────────────────────────────────────────────────
predict_service <- function(csv_path, payload_json, temperature = 1) {
  # Parse participant
  new_participant <- .parse_new_participant_strict(payload_json)

  # Prepare training data (cached)
  prep <- .get_prepared(csv_path)
  Data_Clean <- prep$Data_Clean
  duty_cols  <- prep$duty_cols
  group_vars <- prep$group_vars

  # Predict (same function name as original, augmented with match)
  preds <- predict_groups(new_participant, Data_Clean, duty_cols, group_vars)

  list(predictions = preds)
}

