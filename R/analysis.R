# This file contains the meta-analysis logic

#' Perform meta-analysis
#'
#' @param data A data frame containing effect sizes and standard errors
#' @param method The meta-analysis method (default: REML)
#' @param model The model type (default: random)
#' @param test The test type (default: z)
#' @return A rma object containing meta-analysis results
#' @export
perform_meta_analysis <- function(data, method = "REML", model = "random", test = "z") {
  res <- rma(yi = data$effect_size, sei = data$standard_error, method = method, model = model, test = test) # nolint
  return(res)
}
