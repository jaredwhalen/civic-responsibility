# entrypoint.R
library(plumber)
pr("api.R") |>
  pr_set_debug(FALSE) |>
  pr_run(host = "0.0.0.0", port = as.integer(Sys.getenv("PORT", "8000")))
