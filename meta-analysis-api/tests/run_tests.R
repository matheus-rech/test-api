# New file to run all tests

# Set the working directory to the project root
setwd(dirname(dirname(getwd())))

# Print current working directory and list files for debugging
print(getwd())
print(list.files())

# Check if the tests directory exists
if (!dir.exists("tests")) {
  stop("Tests directory not found. Make sure you're in the correct directory.")
}

# Load required libraries
library(testthat)

# Check if all required packages are installed
required_packages <- c("testthat", "httr", "jsonlite", "checkmate", "metafor", "plumber", "assertthat", "readxl", "ggplot2", "dplyr")
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop("The following required packages are missing: ", paste(missing_packages, collapse = ", "))
}

# Run all tests in the tests directory
test_results <- test_dir("tests")

# Print test results summary
print(test_results)