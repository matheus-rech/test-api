library(plumber)

# Get port from environment variable
port <- as.integer(Sys.getenv("APP_PORT", "8000"))

# Create a new Plumber object
pr <- plumb("app.R")

# Add a health check endpoint
pr$handle("GET", "/health", function() {
  list(status = "OK", timestamp = Sys.time())
})

# Start the API with error handling
tryCatch({
  pr$run(port = port, host = "0.0.0.0")
}, error = function(e) {
  cat("Error starting the API:", conditionMessage(e), "\n")
  quit(status = 1)
})