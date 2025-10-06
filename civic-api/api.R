# api.R
library(plumber)
source("service.R")

# Add CORS headers
#* @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
  plumber::forward()
}

#* Health check
#* @get /healthz
function() list(ok = TRUE)

#* Predict (JSON in, JSON out)
#* @post /predict
#* @serializer json
function(req){
  body <- req$postBody
  if (is.null(body) || nchar(trimws(body)) == 0) {
    return(list(error = "Empty body"))
  }
  csv <- Sys.getenv("CSV_PATH", "CR_Data_Names.csv")
  # Return a list; plumber handles JSON serialization
  predict_service(csv_path = csv, payload_json = body, temperature = 1)
}
