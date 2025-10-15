# service.R — Match notebook logic & results 1:1

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(jsonlite)
  library(rlang)
})

select <- dplyr::select

# ─────────────────────────────────────────────────────────
# Data Org (same as notebook)
# ─────────────────────────────────────────────────────────
.load_and_clean <- function(csv_path) {
  Data_Raw <- read.csv(csv_path, stringsAsFactors = FALSE)

  Data_Clean <- Data_Raw %>%
    mutate(pid3 = trimws(pid3))

  names(Data_Clean) <- gsub("^duties_full_list_", "duties_", names(Data_Clean))

  duty_vars <- grep("^duties_\\d+$", names(Data_Clean), value = TRUE)

  Data_Clean <- Data_Clean %>%
    mutate(across(all_of(duty_vars), ~ case_when(
      .x == "Civic responsibility" ~ 1,
      .x == "Not a civic responsibility" ~ 0,
      TRUE ~ suppressWarnings(as.numeric(.x))
    )))

  Data_Clean <- Data_Clean %>%
    mutate(
      urban_binary = case_when(
        urban == "Urban" ~ "Urban",
        urban %in% c("Suburban", "Rural") ~ "Suburban/Rural",
        TRUE ~ NA_character_
      ),
      ideology_binary = case_when(
        ideology %in% c("Liberal", "Slightly liberal", "Very liberal") ~ "Liberal",
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
    duty_cols  = paste0("duties_", 1:30),
    group_vars = c("urban_binary", "ideology_binary", "age_binary")
  )
}

# ─────────────────────────────────────────────────────────
# Notebook model function (unchanged logic)
# - Winner by SUM Manhattan distance over answered items
# - percent_fit by per-item point system with tie_mode
# - Allows skipped items (NA); denominator = answered count
# ─────────────────────────────────────────────────────────
predict_groups_with_fit <- function(new_data_row,
                                    df,
                                    duty_cols,
                                    group_vars,
                                    tie_mode = c("fractional","highest_if_1_lowest_if_0","first")) {
  tie_mode <- match.arg(tie_mode)

  # Coerce new_data_row to named numeric vector aligned to duty_cols
  if (is.data.frame(new_data_row)) {
    new_vec <- unlist(new_data_row[, duty_cols, drop = FALSE])
  } else if (is.numeric(new_data_row) || is.integer(new_data_row)) {
    new_vec <- new_data_row
    names(new_vec) <- duty_cols[seq_along(new_vec)]
  } else {
    stop("new_data_row must be a single-row data.frame or a numeric vector.")
  }
  new_vec <- new_vec[duty_cols]  # keep order; may include NA

  results_detail <- list()
  predictions <- list()
  summary_rows <- list()

  for (gv in group_vars) {
    # 1) Weighted prototypes for this grouping variable
    prototypes <- df %>%
      filter(!is.na(.data[[gv]])) %>%
      group_by(.data[[gv]]) %>%
      summarise(across(all_of(duty_cols), ~ weighted.mean(.x, w = Weight, na.rm = TRUE)),
                .groups = "drop") %>%
      rename(group = !!gv)

    # ensure numeric matrix of prototypes over duty columns
    proto_mat <- as.matrix(prototypes[, duty_cols, drop = FALSE])
    rownames(proto_mat) <- prototypes$group

    # 2) Predict closest subgroup via Manhattan distance (drop NA items)
    keep_items   <- !is.na(new_vec)
    denom_items  <- sum(keep_items)
    if (denom_items == 0) {
      pred <- NA_character_
      detail <- tibble::tibble(group = prototypes$group,
                               points = 0, fit = 0,
                               is_target = FALSE,
                               denom = 0, target_fit = NA_real_)
      predictions[[gv]] <- pred
      results_detail[[gv]] <- detail
      summary_rows[[gv]] <- tibble::tibble(
        group_var = gv,
        predicted_group = pred,
        percent_fit = NA_real_,
        items_used = 0
      )
      next
    }

    proto_use <- proto_mat[, keep_items, drop = FALSE]
    new_use   <- new_vec[keep_items]

    # Manhattan distance = rowSums(|prototype - new|)
    dists <- rowSums(abs(proto_use - matrix(new_use, nrow = nrow(proto_use), ncol = length(new_use), byrow = TRUE)))
    pred_idx <- which.min(dists)
    pred <- rownames(proto_use)[pred_idx]
    predictions[[gv]] <- pred

    # 3) Point-per-item fit (with tie handling)
    pts <- setNames(numeric(nrow(proto_use)), rownames(proto_use))

    for (j in seq_len(ncol(proto_use))) {
      dj <- abs(proto_use[, j] - new_use[j])
      min_d <- min(dj)
      winners <- names(which(dj == min_d))

      if (length(winners) == 1 || tie_mode == "fractional") {
        pts[winners] <- pts[winners] + 1/length(winners)
      } else if (tie_mode == "highest_if_1_lowest_if_0") {
        if (new_use[j] == 1) {
          best <- winners[which.max(proto_use[winners, j])]
          pts[best] <- pts[best] + 1
        } else {
          best <- winners[which.min(proto_use[winners, j])]
          pts[best] <- pts[best] + 1
        }
      } else if (tie_mode == "first") {
        pts[winners[1]] <- pts[winners[1]] + 1
      }
    }

    detail <- tibble::tibble(
      group = names(pts),
      points = as.numeric(pts),
      fit = points / denom_items,
      is_target = group == pred,
      denom = denom_items
    )
    detail$target_fit <- detail$fit[detail$group == pred][1]

    results_detail[[gv]] <- detail
    summary_rows[[gv]] <- tibble::tibble(
      group_var = gv,
      predicted_group = pred,
      percent_fit = detail$target_fit[1] * 100,
      items_used = denom_items
    )
  }

  summary_tbl <- dplyr::bind_rows(summary_rows)

  list(
    predictions = predictions,   # named list: group_var -> predicted subgroup
    summary = summary_tbl,       # tibble: group_var, predicted_group, percent_fit, items_used
    detail = results_detail      # list of tibbles per group_var with points & fits
  )
}

# ─────────────────────────────────────────────────────────
# JSON parser (allows skips; aligns to duty_cols)
# Accepts:
#   {"duties":[...]} OR {"duties":{"duties_1":...}} OR top-level duties_* keys
# Returns a named numeric vector (may contain NA) ordered by duty_cols
# ─────────────────────────────────────────────────────────
.parse_new_participant_flexible <- function(json_str, duty_cols) {
  x <- tryCatch(jsonlite::fromJSON(json_str, simplifyVector = FALSE),
                error = function(e) NULL)
  if (is.null(x)) stop("Invalid JSON.")

  d <- if (!is.null(x$duties)) x$duties else x
  v <- rep(NA_real_, length(duty_cols)); names(v) <- duty_cols

  as_num <- function(val) {
    if (is.null(val)) return(NA_real_)
    if (is.character(val) && (val == "" || tolower(val) == "na")) return(NA_real_)
    suppressWarnings(as.numeric(val))
  }

  if (is.list(d) && !is.null(names(d))) {
    # Named object: fill by key
    for (nm in names(d)) {
      m <- regmatches(nm, regexec("^duties_(\\d+)$", nm))[[1]]
      if (length(m) == 2) {
        idx <- as.integer(m[2])
        if (!is.na(idx) && idx >= 1 && idx <= length(duty_cols)) v[idx] <- as_num(d[[nm]])
      }
    }
  } else if (is.list(d) && is.null(names(d))) {
    # Array positional
    n <- min(length(d), length(duty_cols))
    for (i in seq_len(n)) v[i] <- as_num(d[[i]])
  } else {
    stop("Expected 'duties' as array or object (or top-level duties_* keys).")
  }

  v
}

# ─────────────────────────────────────────────────────────
# Optional: cache cleaned data in memory (reload if CSV changes)
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
    .cache$csv_path   <- csv_path
    .cache$mtime      <- finfo$mtime
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
# Public API entry — returns exactly the notebook outputs
#   predictions, summary (with percent_fit), detail
# Tie behavior can be controlled via env var TIE_MODE.
# ─────────────────────────────────────────────────────────
predict_service <- function(csv_path, payload_json,
                            tie_mode = Sys.getenv("TIE_MODE", "fractional")) {
  prep <- .get_prepared(csv_path)
  Data_Clean <- prep$Data_Clean
  duty_cols  <- prep$duty_cols
  group_vars <- prep$group_vars

  # Parse participant JSON (skips allowed, dropped from denom)
  new_participant <- .parse_new_participant_flexible(payload_json, duty_cols)

  # Run notebook-identical function
  res <- predict_groups_with_fit(
    new_data_row = new_participant,
    df           = Data_Clean,
    duty_cols    = duty_cols,
    group_vars   = group_vars,
    tie_mode     = tie_mode
  )

  # Return the same structure as the notebook function
  res
}
