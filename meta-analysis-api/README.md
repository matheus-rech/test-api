# Meta-Analysis API

This project provides an API for conducting meta-analyses using R and Plumber.

## Getting Started

### Prerequisites

- R 4.1.0 or higher
- Docker (optional, for containerized deployment)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/meta-analysis-api.git
   cd meta-analysis-api
   ```

2. Install required R packages:
   ```R
   install.packages(c("plumber", "metafor", "assertthat", "readxl", "jsonlite", "ggplot2", "dplyr", "logger"))
   ```

### Running the API

1. To run the API locally:
   ```
   Rscript run_api.R
   ```

2. To run the API using Docker:
   ```
   docker build -t meta-analysis-api .
   docker run -p 8000:8000 meta-analysis-api
   ```

The API will be available at `http://localhost:
