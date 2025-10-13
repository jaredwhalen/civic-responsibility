# api.R
library(plumber)
source("service.R")

# Add CORS headers
#* @filter cors
cors <- function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
  
  # Handle preflight OPTIONS request
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$status <- 200
    return(list())
  }
  
  plumber::forward()
}

#* Health check
#* @get /healthz
#* @serializer json
function() list(ok = TRUE)

#* Predict (JSON in, JSON out)
#* @post /predict
#* @serializer json
function(req, res){
  body <- req$postBody
  if (is.null(body) || nchar(trimws(body)) == 0) {
    res$status <- 400
    return(list(error = "Empty body"))
  }

  csv <- Sys.getenv("CSV_PATH", "CR_Data_Names.csv")
  tie_mode <- Sys.getenv("TIE_MODE", "fractional")  # "fractional" | "highest_if_1_lowest_if_0" | "first"

  tryCatch(
    predict_service(
      csv_path     = csv,
      payload_json = body,
      tie_mode     = tie_mode
    ),
    error = function(e) {
      res$status <- 400
      list(error = conditionMessage(e))
    }
  )
}
