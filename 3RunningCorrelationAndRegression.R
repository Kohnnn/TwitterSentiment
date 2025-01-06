# Load required packages
packages <- c("PerformanceAnalytics", "dplyr", "tidyverse", "stargazer")
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {
  install.packages(new_packages)
  message("Installed required packages.")
}

# Load libraries
library(PerformanceAnalytics) # for correlation chart
library(dplyr) # for data manipulation
library(tidyverse) # for data manipulation and visualization
library(stargazer) # for well-formatted regression tables

### NOTE: Full material I used for the script can be found here: https://cutt.ly/hbT6GXQ

# Function to run regression analysis
# Run Regression Analysis
#
# This function runs a linear regression analysis on the provided data.
#
# @param data A data frame containing the variables to be used in the regression analysis.
# @return A linear model object.
run_regression <- function(data) {
  if (!is.data.frame(data)) {
    stop("Input data must be a data frame.")
  }
  lm_model <- lm(price ~ volume + n + Agreement + sentiment, data = data)
  return(lm_model)
}

# Example usage of the run_regression function
# regression_results <- run_regression(FinalData)

# Function to plot correlation
# Plot Correlation
#
# This function plots the correlation between price and volume.
#
# @param data A data frame containing the price and volume variables.
plot_correlation <- function(data) {
  if (!is.data.frame(data)) {
    stop("Input data must be a data frame.")
  }
  plot(x = data$price, y = data$volume, col = rgb(0.4, 0, 0.9),
       xlab = "Price", ylab = "Volume", main = "Price vs Volume")
}

# Example usage of the plot_correlation function
# plot_correlation(FinalData)

# Main Analysis
if (exists("FinalData")) {
  # Run regression and display results
  regression_results <- run_regression(FinalData)
  stargazer(regression_results, type = "text",
            dep.var.labels = c("Price"),
            covariate.labels = c("Volume", "n", "Agreement", "Sentiment"))
  
  # Summary statistics
  summary(FinalData)
  
  # Standard deviation of volume
  sd_volume <- sd(FinalData$volume)
  
  # Print standard deviation
  print(paste("Standard Deviation of Volume:", sd_volume))
  
  ### Running correlation
  FinalData[, c(2,3,4,5,6,7)] %>% 
    chart.Correlation(histogram=TRUE)
  
  FinalData[, c(2,3,4,5,6)] %>% 
    pairs()
} else {
  message("FinalData not found. Please load the data before running the analysis.")
}

### Additional analysis and visualization can be added here
