library(plumber)
library(logger)

# Configure logging
log_appender(appender_file("api.log"))

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
  log_info("Starting API on port {port}")
  pr$run(port = port, host = "0.0.0.0")
}, error = function(e) {
  log_error("Error starting the API: {conditionMessage(e)}")
  quit(status = 1)
})
