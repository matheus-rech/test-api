# Validator for meta-analysis parameters
validate_meta_analysis_params <- function(method, model, test) {
  assert_that(
    is.string(method),
    method %in% c("REML", "ML", "DL", "HS", "SJ", "HE"),
    msg = "Invalid method. Must be one of: REML, ML, DL, HS, SJ, HE"
  )
  
  assert_that(
    is.string(model),
    model %in% c("random", "fixed"),
    msg = "Invalid model. Must be either 'random' or 'fixed'"
  )
  
  assert_that(
    is.string(test),
    test %in% c("z", "t"),
    msg = "Invalid test. Must be either 'z' or 't'"
  )
}

# Validator for plot type used in visualizations
validate_plot_type <- function(plot_type) {
  assert_that(
    is.string(plot_type),
    plot_type %in% c("forest", "funnel", "baujat", "radial"),
    msg = "Invalid plot type. Must be one of: forest, funnel, baujat, radial"
  )
}

# Validator for moderator analysis
validate_moderator <- function(data, moderator) {
  assert_that(
    is.string(moderator),
    moderator %in% colnames(data),
    msg = paste("Invalid moderator. Must be a column name in the dataset. Available columns:", paste(colnames(data), collapse = ", "))
  )
}

# Validator for sensitivity analysis parameters
validate_sensitivity_params <- function(analysis_type, params) {
  assert_that(
    is.string(analysis_type),
    analysis_type %in% c("leave_one_out", "influence"),
    msg = "Invalid analysis type. Must be either 'leave_one_out' or 'influence'"
  )
  
  if (analysis_type == "influence") {
    assert_that(
      is.list(params),
      "measure" %in% names(params),
      params$measure %in% c("cooks.distance", "dfbetas", "L", "covariance.ratio"),
      msg = "For influence analysis, params must include 'measure' which should be one of: cooks.distance, dfbetas, L, covariance.ratio"
    )
  }
}