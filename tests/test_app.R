library(testthat)
source("R/validators.R")
source("R/analysis.R")
source("R/data_handlers.R")

test_that("validate_meta_analysis_params works", {
  expect_error(validate_meta_analysis_params("INVALID", "random", "z"), "Invalid method")
  expect_error(validate_meta_analysis_params("REML", "invalid_model", "z"), "Invalid model")
  expect_error(validate_meta_analysis_params("REML", "random", "invalid_test"), "Invalid test")
  expect_silent(validate_meta_analysis_params("REML", "random", "z"))
})

test_that("validate_plot_type works", {
  expect_error(validate_plot_type("invalid_plot"), "Invalid plot type")
  expect_silent(validate_plot_type("forest"))
})

test_that("perform_meta_analysis works", {
  test_data <- data.frame(
    effect_size = c(0.1, 0.2, 0.3),
    standard_error = c(0.05, 0.05, 0.05)
  )
  result <- perform_meta_analysis(test_data)
  expect_s3_class(result, "rma")
  expect_equal(length(result$b), 1)
})

test_that("read_data works", {
  # Create a temporary CSV file for testing
  temp_file <- tempfile(fileext = ".csv")
  write.csv(data.frame(x = 1:3, y = 4:6), temp_file, row.names = FALSE)
  
  # Test reading CSV
  data <- read_data(list(datapath = temp_file), "csv")
  expect_equal(nrow(data), 3)
  expect_equal(ncol(data), 2)
  
  # Clean up
  unlink(temp_file)
})