# This file contains the meta-analysis logic

library(metafor)
library(checkmate)

#' Perform meta-analysis
#'
#' @param data A data frame containing effect sizes and standard errors
#' @param method The meta-analysis method (default: REML)
#' @param model The model type (default: random)
#' @param test The test type (default: z)
#' @return A rma object containing meta-analysis results
#' @export
perform_meta_analysis <- function(data, method = "REML", model = "random", test = "z") {
  # Input validation
  assert_data_frame(data, min.rows = 2, min.cols = 2)
  assert_subset(c("effect_size", "standard_error"), names(data))
  assert_numeric(data$effect_size, any.missing = FALSE)
  assert_numeric(data$standard_error, lower = 0, any.missing = FALSE)
  assert_choice(method, choices = c("FE", "DL", "HE", "SJ", "ML", "REML", "EB", "HS"))
  assert_choice(model, choices = c("fixed", "random"))
  assert_choice(test, choices = c("z", "knha", "t"))
  
  # Perform meta-analysis
  res <- tryCatch({
    rma(yi = data$effect_size, sei = data$standard_error, method = method, model = model, test = test)
  }, error = function(e) {
    stop(paste("Meta-analysis failed:", e$message))
  })
  
  # Return results
  return(res)
}