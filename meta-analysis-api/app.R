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
library(assertthat)
library(readxl)
library(jsonlite)
library(ggplot2)
library(dplyr)
library(logger)

source("R/analysis.R")
source("R/sensitivity.R")
source("R/validators.R")
source("R/visualization.R")
source("R/data_handlers.R")

#* @apiTitle Meta-Analysis API
#* @apiDescription API for conducting meta-analyses

#* Upload data
#* @post /upload
#* @param file:file
#* @param file_type:string
function(file, file_type) {
  tryCatch({
    validate_file_type(file_type)
    data <- read_data(file, file_type)
    data <- preprocess_data(data)
    save_data(data, "uploaded_data.csv")
    log_info("Data uploaded and preprocessed successfully")
    list(message = "Data uploaded and preprocessed successfully")
  }, error = function(e) {
    log_error("Error in data upload: {conditionMessage(e)}")
    list(error = conditionMessage(e))
  })
}

#* Perform meta-analysis
#* @post /analyze
#* @param method:string
#* @param model:string
#* @param test:string
function(method = "REML", model = "random", test = "z") {
  validate_meta_analysis_params(method, model, test)
  data <- load_data("uploaded_data.csv")
  results <- perform_meta_analysis(data, method, model, test)
  list(summary = summary(results))
}

#* Get results
#* @get /results
#* @param type:string
function(type = "summary") {
  data <- load_data("uploaded_data.csv")
  results <- perform_meta_analysis(data)
  
  if (type == "summary") {
    return(summary(results))
  } else if (type == "heterogeneity") {
    return(list(
      I2 = results$I2,
      H2 = results$H2,
      QE = results$QE,
      QEp = results$QEp
    ))
  } else {
    stop("Invalid result type")
  }
}

#* Generate visualization
#* @get /visualize
#* @param plot_type:string
#* @serializer contentType list(type="image/png")
function(plot_type = "forest") {
  validate_plot_type(plot_type)
  data <- load_data("uploaded_data.csv")
  results <- perform_meta_analysis(data)
  plot <- generate_plot(data, results, plot_type)
  
  # Save plot to a temporary file
  temp_file <- tempfile(fileext = ".png")
  save_plot(plot, temp_file)
  
  # Read and return the plot as raw bytes
  readBin(temp_file, "raw", n = file.info(temp_file)$size)
}

#* Perform sensitivity analysis
#* @post /sensitivity
#* @param analysis_type:string
#* @param params:object
function(analysis_type, params = list()) {
  tryCatch({
    validate_sensitivity_params(analysis_type, params)
    data <- load_data("uploaded_data.csv")
    results <- perform_meta_analysis(data)
    sensitivity_results <- perform_sensitivity_analysis(results, analysis_type, params)
    list(results = sensitivity_results)
  }, error = function(e) {
    log_error("Error in sensitivity analysis: {conditionMessage(e)}")
    list(error = conditionMessage(e))
  })
}