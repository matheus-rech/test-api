# Install required packages if not already installed
if (!requireNamespace("httr", quietly = TRUE)) install.packages("httr")
if (!requireNamespace("jsonlite", quietly = TRUE)) install.packages("jsonlite")
if (!requireNamespace("assertthat", quietly = TRUE)) install.packages("assertthat")

# Load required libraries
library(httr)
library(jsonlite)
library(assertthat)

# Get the port from environment variable or use default
port <- Sys.getenv("APP_PORT", "8000")
base_url <- paste0("http://localhost:", port)

# Test function
run_test <- function(endpoint, test_name) {
  tryCatch({
    response <- GET(paste0(base_url, endpoint))
    content <- content(response, "parsed")
    print(paste(test_name, "test:"))
    print(content)
    if (response$status_code == 200) {
      print(paste(test_name, "test passed"))
    } else {
      print(paste(test_name, "test failed"))
    }
  }, error = function(e) {
    print(paste(test_name, "test failed:", e$message))
  })
}

# Run tests
run_test("/", "Root endpoint")
run_test("/test", "Test endpoint")
run_test("/health", "Health endpoint")

print("All tests completed.")