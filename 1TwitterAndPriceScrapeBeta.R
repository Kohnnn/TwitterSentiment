# Load required packages
packages <- c("rtweet", "dplyr", "ggplot2", "jsonlite", "httr", "xlsx", "tm", "tidyverse", "lubridate")
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

# Load libraries
library(rtweet) # for crawling tweets
library(dplyr) # for data manipulation
library(jsonlite) # for JSON transfer
library(lubridate) # for date and time processing
library(httr) # for web crawling
library(xlsx) # for exporting to Excel
library(tidyverse) # for data manipulation and visualization

### Personal Twitter Token
# To ensure security and prevent unauthorized access, we utilize environment variables to store sensitive information.
# The following variables are set to retrieve the Twitter API credentials securely:
consumerKey <- Sys.getenv("TWITTER_CONSUMER_KEY")
consumerSecret <- Sys.getenv("TWITTER_CONSUMER_SECRET")
accessToken <- Sys.getenv("TWITTER_ACCESS_TOKEN")
accessTokenSecret <- Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")

### Import Twitter API Token
# Create a token for authenticating with the Twitter API, allowing us to extract tweets efficiently.
create_token <- function(app, consumer_key, consumer_secret, access_token, access_secret) {
  token <- rtweet::create_token(
    app = app,
    consumer_key = consumer_key,
    consumer_secret = consumer_secret,
    access_token = access_token,
    access_secret = access_secret
  )
  return(token)
}

token <- create_token(
  app = "ExtractTweet",
  consumer_key = consumerKey,
  consumer_secret = consumerSecret,
  access_token = accessToken,
  access_secret = accessTokenSecret
)

### Function to scrape tweets based on a query
#' Scrape tweets based on a query
#'
#' @param query The query to search for
#' @param n The number of tweets to retrieve
#' @return A dataframe of tweets
scrape_tweets <- function(query, n = 100) {
  tweets <- rtweet::search_tweets(query, n = n, include_rts = FALSE)
  return(tweets)
}

### Scrape Twitter
# Extract tweets containing specific hashtags and keywords, with a focus on Bitcoin-related conversations.
BTCFinaltest2 <- scrape_tweets("#Bitcoin OR #BTC OR $BTC OR bitcoin", n = 588000, retryonratelimit = TRUE, max_id = FALSE, 
  include_rts = FALSE, lang = "en", 
  since = "2021-04-9", 
  until = "2021-04-11") #The day needs update since twitter not allow more than 7 days pull

### Function to save tweets to Excel
#' Save tweets to Excel
#'
#' @param tweets_data The dataframe of tweets
#' @param file_name The name of the file to save
save_tweets_to_excel <- function(tweets_data, file_name) {
  write.xlsx(tweets_data, file = file_name, row.names = FALSE)
}

### Save the extracted tweets to a file for further processing and analysis.
saveRDS(BTCFinaltest2, file = "RawTwitterDataSet26-15.rds") #Save my gig, prepare for processing

### Merge dataframe
# Combine multiple dataframes containing Twitter data into a single, comprehensive dataset.
bind_rows(`BTC26-01`, y = `BTC1-7`) %>%
  bind_rows(`BTC8-10`) %>%
  bind_rows(`BTC9-16`) -> `RawTwitterDataSet26-15`

### Scrape bitcoin price hourly, the api contain only 2 weeks data so need to update weekly
# Retrieve the Bitcoin price data from the CryptoCompare API, with a focus on hourly price movements.
url = "https://min-api.cryptocompare.com/data/v2/histohour?aggregate=1&e=CCCAGG&extraParams=https:%2F%2Fwww.cryptocompare.com&fsym=BTC&limit=387&tryConversion=false&tsym=USD"
##Get the url content
r <- GET(url) 
r <- httr::content(r, as = "text")
##Parse to df
df <- fromJSON(r, simplifyDataFrame = TRUE)
df[["Data"]][["Data"]] -> df
##Covert Epoch time into date
mutate(df, date = lubridate::as_datetime(Pric1$time), .after = 1) -> Price

##Parse data, optional as can be done later
# Perform optional data transformations to prepare the data for analysis.
within(Price, volume <- log(volumefrom)) -> Price#ptional
within(Price, price <- log(close)) -> Price ##ptional
within(Price, return <- (close[-1]/close)-1) -> Price #optional
##Take what needed
Price %>% dplyr::transmute(date, price, volume) %>%
  Price %>% rename(time = date) -> Price

### Export excel file for back up
# Export the processed data to an Excel file for backup and further analysis.
write.xlsx(Price, "BitcoinPriceAndVolume.xlsx", row.names = FALSE) 

### NOTE: Full material I used for the script can be found here: https://cutt.ly/hbT6GXQ
