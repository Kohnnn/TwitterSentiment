# Twitter Data Analysis Project

## Overview
This project analyzes Twitter data to explore its correlation with pricing trends through data scraping, cleansing, sentiment analysis, and regression modeling. The insights aim to inform pricing strategies and market trends.

## Installation Instructions
1. Install R and RStudio.
2. Install required packages:
   ```R
   install.packages(c('tidyverse', 'rvest', 'lubridate', 'ggplot2', 'dplyr'))
   ```
3. Clone the repository:
   ```bash
   git clone https://github.com/Kohnnn/TwitterDataAnalysis.git
   ```

## Usage Examples
1. Set your working directory in RStudio to the project folder.
2. Run the main script:
   ```R
   source('1TwitterAndPriceScrapeBeta.R')
   ```
3. Follow console prompts for parameters.

## Features
- **Data Scraping**: Collect real-time Twitter data.
- **Data Cleansing**: Preprocess data for analysis.
- **Sentiment Analysis**: Gauge public opinion.
- **Statistical Modeling**: Identify correlations with pricing.
- **Data Visualization**: Visualize findings.

## R Script Descriptions

### 1TwitterAndPriceScrapeBeta.R
This script scrapes Twitter data related to pricing trends using the Twitter API. It connects to the API with authentication tokens using the `rtweet` library. The script defines search parameters such as keywords (e.g., "#pricing", "#markettrends") and date ranges to filter relevant tweets. It handles Twitter's rate limits to ensure successful data collection, storing the collected tweets in a structured format (data frame) for further analysis.

### 2TwitterDataCleansingAndSentimentAnalysis.R
This script cleans the scraped Twitter data by removing duplicates and irrelevant tweets. It utilizes libraries like `dplyr` for data manipulation and `tidytext` for sentiment analysis. The text data is preprocessed by removing URLs, punctuation, and stop words. Sentiment analysis is conducted using a lexicon-based approach, categorizing tweets as positive, negative, or neutral. The results, including sentiment scores, are saved for subsequent analyses.

### 3RunningCorrelationAndRegression.R
This script performs correlation and regression analyses on the cleansed Twitter data. It uses libraries such as `ggplot2` for data visualization and `stats` for statistical modeling. The script calculates Pearson correlation coefficients between sentiment scores and pricing trends, running linear regression models to predict pricing based on sentiment. The output includes visualizations, such as scatter plots and regression lines, to illustrate relationships and trends effectively.

## Future Work
- Integrate additional data sources for richer analysis.
- Implement machine learning for advanced sentiment analysis.
- Develop a web application for real-time insights.

## Acknowledgments
Thanks to the developers of R packages used in this project, including `tidyverse`, `rvest`, and `ggplot2`.

## Badges
![Build Status](https://img.shields.io/badge/build-passing-brightgreen) ![License](https://img.shields.io/badge/license-MIT-blue) 

## Contact
For inquiries or collaboration, reach out via my GitHub profile: [Kohnnn](https://github.com/Kohnnn).
