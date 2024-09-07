# Function to perform sensitivity analysis
perform_sensitivity_analysis <- function(data, analysis_type, params = list()) {
  if (analysis_type == "leave_one_out") {
    return(leave1out(data))
  } else if (analysis_type == "influence") {
    measure <- params$measure
    return(influence(data, measure = measure))
  } else {
    stop("Invalid sensitivity analysis type")
  }
}