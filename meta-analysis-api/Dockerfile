FROM rocker/r-ver:4.1.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev

# Install R packages
RUN R -e "install.packages(c('plumber', 'metafor', 'assertthat', 'readxl', 'jsonlite', 'ggplot2', 'dplyr', 'logger'))"

# Copy application files
COPY . /app
WORKDIR /app

# Expose port
EXPOSE 8000

# Run the API
CMD ["Rscript", "run_api.R"]
