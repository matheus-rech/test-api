# Function to generate plots
generate_plot <- function(data, results, plot_type) {
  if (plot_type == "forest") {
    return(forest(results))
  } else if (plot_type == "funnel") {
    return(funnel(results))
  } else if (plot_type == "baujat") {
    return(baujat(results))
  } else if (plot_type == "radial") {
    return(radial(results))
  } else {
    stop("Invalid plot type")
  }
}

# Function to save a plot
save_plot <- function(plot, filename) {
  ggsave(filename, plot)
}
