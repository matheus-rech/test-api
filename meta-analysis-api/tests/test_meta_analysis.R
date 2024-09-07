library(testthat)
library(checkmate)

# Source all R scripts in the R folder
R_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
sapply(R_files, source)

# Validation tests
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

test_that("Input validation functions work", {
  expect_true(validate_meta_analysis_params("REML", "random", "z"))
  expect_error(validate_meta_analysis_params("invalid", "random", "z"))
  
  expect_true(validate_plot_type("forest"))
  expect_error(validate_plot_type("invalid"))
  
  expect_true(validate_sensitivity_params("leave_one_out", list()))
  expect_error(validate_sensitivity_params("invalid", list()))
})

# Meta-analysis function tests
test_that("Meta-analysis function exists and is callable", {
  expect_function(perform_meta_analysis, 
                  args = c("effect_sizes", "standard_errors"),
                  ordered = TRUE)
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

test_that("Meta-analysis function handles valid input correctly", {
  effect_sizes <- c(0.1, 0.2, 0.3)
  standard_errors <- c(0.05, 0.05, 0.05)
  
  result <- perform_meta_analysis(effect_sizes, standard_errors)
  
  expect_list(result, names = "named")
  expect_names(names(result), must.include = c("pooled_effect", "ci_lower", "ci_upper"))
  expect_number(result$pooled_effect, finite = TRUE)
  expect_number(result$ci_lower, finite = TRUE)
  expect_number(result$ci_upper, finite = TRUE)
  expect_true(result$ci_lower <= result$pooled_effect && result$pooled_effect <= result$ci_upper)
})

test_that("Meta-analysis function handles edge cases appropriately", {
  expect_error(perform_meta_analysis(NULL, NULL), "Invalid input: effect_sizes and standard_errors cannot be NULL")
  expect_error(perform_meta_analysis(numeric(0), numeric(0)), "Invalid input: effect_sizes and standard_errors cannot be empty")
  expect_error(perform_meta_analysis(c(1,2), c(1)), "Invalid input: effect_sizes and standard_errors must have the same length")
  expect_error(perform_meta_analysis(c("a", "b"), c(1, 2)), "Invalid input: effect_sizes must be numeric")
  expect_error(perform_meta_analysis(c(1, 2), c("a", "b")), "Invalid input: standard_errors must be numeric")
  expect_error(perform_meta_analysis(c(1, 2), c(-1, 2)), "Invalid input: standard_errors must be positive")
})

test_that("Meta-analysis function produces consistent results", {
  set.seed(123)  # For reproducibility
  effect_sizes <- rnorm(10, mean = 0.5, sd = 0.1)
  standard_errors <- runif(10, min = 0.01, max = 0.1)
  
  result1 <- perform_meta_analysis(effect_sizes, standard_errors)
  result2 <- perform_meta_analysis(effect_sizes, standard_errors)
  
  expect_equal(result1, result2)
})

# Data handling tests
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

test_that("Data upload and preprocessing works", {
  # Mock file upload and preprocessing
  temp_file <- tempfile(fileext = ".csv")
  write.csv(data.frame(effect = c(0.1, 0.2, 0.3), se = c(0.05, 0.05, 0.05)), temp_file)
  result <- read_data(temp_file, "csv")
  expect_data_frame(result, nrows = 3, ncols = 2)
  
  processed_data <- preprocess_data(result)
  expect_data_frame(processed_data)
  
  # Clean up
  unlink(temp_file)
})

# Visualization tests
test_that("Visualization function generates plots", {
  data <- data.frame(effect = c(0.1, 0.2, 0.3), se = c(0.05, 0.05, 0.05))
  results <- perform_meta_analysis(data$effect, data$se)
  
  forest_plot <- generate_plot(data, results, "forest")
  expect_is(forest_plot, "ggplot")
  
  funnel_plot <- generate_plot(data, results, "funnel")
  expect_is(funnel_plot, "ggplot")
})