library(httr)
library(jsonlite)

MetaAnalysisClient <- R6::R6Class(
  "MetaAnalysisClient",
  public = list(
    base_url = NULL,
    
    initialize = function(base_url) {
      self$base_url <- base_url
    },
    
    upload_data = function(file_path, file_type) {
      url <- paste0(self$base_url, "/upload")
      tryCatch({
        response <- httr::POST(
          url,
          body = list(
            file = httr::upload_file(file_path),
            file_type = file_type
          ),
          encode = "multipart"
        )
        httr::stop_for_status(response)  # Check for HTTP errors
        httr::content(response, "parsed")  # Return parsed JSON
      }, error = function(e) {
        stop("Error uploading data: ", e$message)
      })
    },
    
    perform_analysis = function(method = "REML", model = "random", test = "z") {
      url <- paste0(self$base_url, "/analyze")
      tryCatch({
        response <- httr::POST(
          url,
          body = list(
            method = method,
            model = model,
            test = test
          ),
          encode = "json"
        )
        httr::stop_for_status(response)
        httr::content(response, "parsed")
      }, error = function(e) {
        stop("Error performing analysis: ", e$message)
      })
    },
    
    get_results = function(type = "summary") {
      url <- paste0(self$base_url, "/results")
      tryCatch({
        response <- httr::GET(url, query = list(type = type))
        httr::stop_for_status(response)
        httr::content(response, "parsed")
      }, error = function(e) {
        stop("Error retrieving results: ", e$message)
      })
    },
    
    get_visualization = function(plot_type = "forest", file_path = NULL) {
      url <- paste0(self$base_url, "/visualize")
      tryCatch({
        response <- httr::GET(url, query = list(plot_type = plot_type))
        httr::stop_for_status(response)
        
        # Check content type for valid image
        content_type <- headers(response)[["content-type"]]
        if (!grepl("^image/", content_type)) {
          stop("Unexpected content type received. Expected an image.")
        }
        
        # Handle raw data for visualization
        if (is.null(file_path)) {
          httr::content(response, "raw")
        } else {
          writeBin(httr::content(response, "raw"), file_path)
          message(paste("Plot saved to", file_path))
        }
      }, error = function(e) {
        stop("Error generating visualization: ", e$message)
      })
    },
    
    perform_sensitivity_analysis = function(analysis_type, params = list()) {
      url <- paste0(self$base_url, "/sensitivity")
      tryCatch({
        response <- httr::POST(
          url,
          body = list(
            analysis_type = analysis_type,
            params = params
          ),
          encode = "json"
        )
        httr::stop_for_status(response)
        httr::content(response, "parsed")
      }, error = function(e) {
        stop("Error performing sensitivity analysis: ", e$message)
      })
    }
  )
)