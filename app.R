#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

library(plumber)
library(metafor)
library(dplyr)
library(ggplot2)
library(readxl)
library(jsonlite)
library(assertthat)

#* @apiTitle Advanced Meta-Analysis API
#* @apiDescription A comprehensive API for conducting sophisticated meta-analyses
#* @apiVersion 1.0.0

#* Root endpoint
#* @get /
function() {
  return(list(
    message = "Welcome to the Advanced Meta-Analysis API",
    version = "1.0.0",
    endpoints = c("/upload", "/analyze", "/results", "/visualize", "/sensitivity", "/test")
  )) # nolint
}

source("R/validators.R")
source("R/data_handlers.R")
source("R/analysis.R")
source("R/visualization.R")
source("R/sensitivity.R")

# Add error logging
log_error <- function(error_message) {
  cat(paste0("[ERROR] ", Sys.time(), " - ", error_message, "\n"), file = "error.log", append = TRUE)
}

#* Upload study data
#* @post /upload
#* @param file:file The file containing study data
#* @param file_type:string The type of file (csv, excel, or json)
function(file, file_type) {
  tryCatch(
    {
      assert_that(is.string(file_type), file_type %in% c("csv", "excel", "json"),
        msg = "Invalid file type. Must be one of 'csv', 'excel', or 'json'"
      )

      # Read and process the uploaded data
      data <- read_data(file, file_type)
      validate_data(data)
      processed_data <- preprocess_data(data)

      # Save with a unique filename (e.g., timestamp to avoid overwrites)
      filename <- paste0("uploaded_data_", format(Sys.time(), "%Y%m%d%H%M%S"), ".csv")
      save_data(processed_data, filename)

      list(status = "success", message = "Data uploaded and processed successfully", file = filename) # nolint
    },
    error = function(e) {
      log_error(paste("Error uploading data:", e$message))
      list(status = "error", message = paste("Error uploading data:", e$message))
    }
  )
}

#* Perform meta-analysis
#* @post /analyze
#* @param method:string The meta-analysis method (default: REML)
#* @param model:string The model type (default: random)
#* @param test:string The test type (default: z)
function(method = "REML", model = "random", test = "z") {
  tryCatch(
    {
      # Validate input parameters
      validate_meta_analysis_params(method, model, test)

      # Load the most recent uploaded data file
      data_files <- list.files(pattern = "^uploaded_data_.*\\.csv$")
      if (length(data_files) == 0) {
        stop("No uploaded data found. Please upload data first.")
      }
      latest_file <- data_files[which.max(file.info(data_files)$mtime)]
      data <- load_data(latest_file)

      # Perform meta-analysis
      res <- rma(
        yi = data$effect_size,
        sei = data$standard_error,
        method = method,
        model = model,
        test = test
      )

      # Prepare summary data
      summary_data <- data.frame(
        estimate = res$b,
        se = res$se,
        zval = res$zval,
        pval = res$pval,
        ci.lb = res$ci.lb,
        ci.ub = res$ci.ub
      )

      # Save the analysis results with unique filenames
      results_filename <- paste0("results_", format(Sys.time(), "%Y%m%d%H%M%S"), ".csv")
      heterogeneity_filename <- paste0("heterogeneity_", format(Sys.time(), "%Y%m%d%H%M%S"), ".csv")
      save_data(summary_data, results_filename)
      save_data(data.frame(I2 = res$I2, H2 = res$H2), heterogeneity_filename)

      list(
        status = "success",
        message = "Meta-analysis completed successfully",
        summary = summary_data,
        heterogeneity = list(I2 = res$I2, H2 = res$H2),
        results_file = results_filename,
        heterogeneity_file = heterogeneity_filename
      )
    },
    error = function(e) {
      list(status = "error", message = paste("Error performing meta-analysis:", e$message))
    }
  )
}

#* Retrieve analysis results
#* @get /results
#* @param type:string The type of result to retrieve (summary, heterogeneity, full)
function(type = "full") {
  tryCatch(
    {
      assert_that(type %in% c("summary", "heterogeneity", "full"),
        msg = "Invalid result type. Must be 'summary', 'heterogeneity', or 'full'"
      )

      results <- list()

      # Find the most recent results files
      results_files <- list.files(pattern = "^results_.*\\.csv$")
      heterogeneity_files <- list.files(pattern = "^heterogeneity_.*\\.csv$")

      if (length(results_files) == 0 || length(heterogeneity_files) == 0) {
        stop("No analysis results found. Please perform analysis first.")
      }

      latest_results_file <- results_files[which.max(file.info(results_files)$mtime)]
      latest_heterogeneity_file <- heterogeneity_files[which.max(file.info(heterogeneity_files)$mtime)]

      if (type %in% c("summary", "full")) {
        results$summary <- load_data(latest_results_file)
      }

      if (type %in% c("heterogeneity", "full")) {
        results$heterogeneity <- load_data(latest_heterogeneity_file)
      }

      list(status = "success", results = results)
    },
    error = function(e) {
      list(status = "error", message = paste("Error retrieving results:", e$message))
    }
  )
}

#* Generate visualizations
#* @get /visualize
#* @param plot_type:string The type of plot (forest, funnel)
#* @serializer contentType list(type="image/png")
function(plot_type = "forest") {
  tryCatch(
    {
      # Validate plot type
      validate_plot_type(plot_type)
      # nolint
      # Load the most recent data and results
      data_files <- list.files(pattern = "^uploaded_data_.*\\.csv$")
      results_files <- list.files(pattern = "^results_.*\\.csv$")
      # nolint: trailing_whitespace_linter.
      if (length(data_files) == 0 || length(results_files) == 0) {
        stop("No data or results found. Please upload data and perform analysis first.")
      }

      latest_data_file <- data_files[which.max(file.info(data_files)$mtime)]
      latest_results_file <- results_files[which.max(file.info(results_files)$mtime)]

      data <- load_data(latest_data_file)
      results <- load_data(latest_results_file)

      # Generate plot
      plot <- generate_plot(data, results, plot_type)

      # Save plot as a temporary file
      filename <- tempfile(fileext = ".png")
      save_plot(plot, filename)

      # Return the image as binary content
      readBin(filename, "raw", n = file.info(filename)$size)
    },
    error = function(e) {
      list(status = "error", message = paste("Error generating visualization:", e$message))
    }
  )
}

#* Perform sensitivity analysis
#* @post /sensitivity
#* @param analysis_type:string The type of sensitivity analysis
#* @param params:object Additional parameters for sensitivity analysis
function(analysis_type, params = list()) {
  tryCatch(
    {
      # Validate sensitivity analysis parameters
      validate_sensitivity_params(analysis_type, params)

      # Load the most recent data file
      data_files <- list.files(pattern = "^uploaded_data_.*\\.csv$")
      if (length(data_files) == 0) {
        stop("No uploaded data found. Please upload data first.")
      }
      latest_file <- data_files[which.max(file.info(data_files)$mtime)]
      data <- load_data(latest_file)

      # Perform sensitivity analysis
      results <- perform_sensitivity_analysis(data, analysis_type, params)

      # Save sensitivity analysis results
      sensitivity_filename <- paste0("sensitivity_", format(Sys.time(), "%Y%m%d%H%M%S"), ".csv")
      save_data(results, sensitivity_filename)
      # nolint
      list(
        status = "success",
        message = "Sensitivity analysis completed successfully",
        results = results,
        file = sensitivity_filename
      )
    },
    error = function(e) {
      list(status = "error", message = paste("Error performing sensitivity analysis:", e$message)) # nolint
    }
  )
}

#* Test endpoint
#* @get /test
function() {
  return(list(message = "API is working!"))
}
