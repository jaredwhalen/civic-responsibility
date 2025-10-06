#!/usr/bin/env Rscript

# ---- Packages ----
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(jsonlite)
})

# ---- CLI Args ----
args <- commandArgs(trailingOnly = TRUE)
csv_path <- "CR_Data_Names.csv"
json_str <- NULL

i <- 1
while (i <= length(args)) {
  if (args[i] == "--csv" && i + 1 <= length(args)) {
    csv_path <- args[i + 1]; i <- i + 2
  } else if (args[i] == "--json" && i + 1 <= length(args)) {
    json_str <- args[i + 1]; i <- i + 2
  } else {
    i <- i + 1
  }
}

if (is.null(json_str)) {
  if (!interactive()) {
    json_str <- paste0(readLines(con = "stdin", warn = FALSE), collapse = "\n")
  }
}

if (is.null(json_str) || nchar(trimws(json_str)) == 0) {
  stop("No JSON provided. Pass with --json '<json>' or via stdin.")
}

# ---- Parse Input JSON ----
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


new_participant_vec <- parse_new_participant(json_str)
np <- suppressWarnings(as.numeric(new_participant_vec))
names(np) <- names(new_participant_vec)

# ---- Load Training Data ----
if (!file.exists(csv_path)) stop(paste0("CSV not found: ", csv_path))
Data_Raw <- suppressWarnings(read.csv(csv_path, stringsAsFactors = FALSE))

if ("pid3" %in% names(Data_Raw)) Data_Raw$pid3 <- trimws(Data_Raw$pid3)
names(Data_Raw) <- gsub("^duties_full_list_", "duties_", names(Data_Raw))
duty_cols <- paste0("duties_", 1:30)

Data_Clean <- Data_Raw %>%
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

if (!("Weight" %in% names(Data_Clean))) Data_Clean$Weight <- 1
group_vars <- c("urban_binary", "ideology_tri", "age_binary")

# ---- Model with Probabilities ----
predict_groups_with_probs <- function(new_data_row_vec, df, duty_cols, group_vars, temperature = 1) {
  nd <- as.numeric(new_data_row_vec)
  names(nd) <- names(new_data_row_vec)
  out <- list()

  for (group_var in group_vars) {
    prototype_df <- df %>%
      dplyr::filter(!is.na(.data[[group_var]])) %>%
      dplyr::group_by(.data[[group_var]]) %>%
      dplyr::summarise(
        dplyr::across(dplyr::all_of(duty_cols), ~ stats::weighted.mean(.x, w = Weight, na.rm = TRUE)),
        .groups = "drop"
      ) %>%
      dplyr::rename(group = !!group_var)

    distances <- prototype_df %>%
      dplyr::rowwise() %>%
      dplyr::mutate(dist = sum(abs(dplyr::c_across(dplyr::all_of(duty_cols)) - nd[duty_cols]), na.rm = TRUE)) %>%
      dplyr::ungroup() %>%
      dplyr::select(group, dist)

    # Per-group derived metrics
    distances <- distances %>%
      dplyr::mutate(
        similarity = 1 / (1 + dist),
        alignment  = 1 - (dist / length(duty_cols))   # 0..1, higher = closer
      )

    # Softmax prob over negative distances
    logits <- -distances$dist / temperature
    logits <- logits - max(logits, na.rm = TRUE)
    distances$prob <- as.numeric(exp(logits) / sum(exp(logits)))

    # Winner
    winner <- distances %>% dplyr::slice_min(dist, n = 1)

    # Return the winner's alignment as a scalar
    out[[group_var]] <- list(
      predicted  = unname(winner$group),
      dist       = as.numeric(winner$dist),
      prob       = as.numeric(winner$prob),
      similarity = as.numeric(winner$similarity),
      alignment  = round(as.numeric(winner$alignment), 3)
    )
  }
  out
}

predicted <- predict_groups_with_probs(np, Data_Clean, duty_cols, group_vars)

# ---- Output ----
out <- list(
  predictions = predicted
)
cat(toJSON(out, auto_unbox = TRUE, pretty = TRUE))
cat("\n")
