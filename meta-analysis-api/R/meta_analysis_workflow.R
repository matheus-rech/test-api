library(R6)
source("R/meta_analysis_client.R")

# Initialize the client
client <- MetaAnalysisClient$new(paste0("http://localhost:", Sys.getenv("APP_PORT", "8000")))

# Helper function to check if the API is reachable
check_api_status <- function(client) {
  tryCatch({
    response <- httr::GET(client$base_url)
    if (response$status_code == 200) {
      print("API is reachable.")
      TRUE
    } else {
      print(paste("API returned status:", response$status_code))
      FALSE
    }
  }, error = function(e) {
    print("Error: Unable to reach the API.")
    FALSE
  })
}

# Start the workflow only if API is reachable
if (check_api_status(client)) {
  
  # Step 1: Upload data
  tryCatch({
    upload_result <- client$upload_data("data/example_data.csv", "csv")
    print("Data upload result:")
    print(upload_result)
  }, error = function(e) {
    print(paste("Error during data upload:", e$message))
  })
  
  # Step 2: Perform meta-analysis
  tryCatch({
    analysis_result <- client$perform_analysis(method = "REML", model = "random", test = "z")
    print("Meta-analysis result:")
    print(analysis_result)
  }, error = function(e) {
    print(paste("Error during meta-analysis:", e$message))
  })
  
  # Step 3: Retrieve results (Summary and Heterogeneity)
  tryCatch({
    summary_results <- client$get_results(type = "summary")
    print("Summary results:")
    print(summary_results)
    
    heterogeneity_results <- client$get_results(type = "heterogeneity")
    print("Heterogeneity results:")
    print(heterogeneity_results)
  }, error = function(e) {
    print(paste("Error retrieving results:", e$message))
  })
  
  # Step 4: Generate and save visualizations
  tryCatch({
    client$get_visualization(plot_type = "forest", file_path = "forest_plot.png")
    client$get_visualization(plot_type = "funnel", file_path = "funnel_plot.png")
    print("Visualizations generated and saved.")
  }, error = function(e) {
    print(paste("Error generating visualizations:", e$message))
  })
  
  # Step 5: Perform sensitivity analysis
  tryCatch({
    leave_one_out_result <- client$perform_sensitivity_analysis("leave_one_out")
    print("Leave-one-out sensitivity analysis result:")
    print(leave_one_out_result)
    
    influence_result <- client$perform_sensitivity_analysis("influence", params = list(measure = "cooks.distance"))
    print("Influence analysis result:")
    print(influence_result)
  }, error = function(e) {
    print(paste("Error during sensitivity analysis:", e$message))
  })
  
  print("Meta-analysis workflow completed.")
  
} else {
  print("API is not reachable. Exiting workflow.")
}
