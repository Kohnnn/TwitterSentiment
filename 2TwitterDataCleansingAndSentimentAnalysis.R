# Load required packages
packages <- c("tm", "tidyverse", "sentimentr", "data.table", "hrbrthemes", "lubridate", "rtweet", "xlsx", "stargazer", "ggplot2")
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

# Load libraries
library(lubridate) #for process time data
library(rtweet) #for take hourly tweets volume
library(dplyr) #for data manipulation
library(xlsx) #for export xlsx
library(tm) #for text mining (remove stopword, etc)
library(sentimentr) #for sentiment analysis
library(ggplot2) #for ploting 
library(tidyverse) #in case i forget something
library(data.table)
library(hrbrthemes)
library(stargazer)

### Constants
RAW_DATA <- "RawTwitterDataSet26-15"
CLEAN_DATA <- "TwitterDataSet26-15"
TEXT_ONLY_DATA <- "TwitterDataSet26-15TextOnly"

### Data screening and cleansing
`{{RAW_DATA}}` <- `{{RAW_DATA}}`[!duplicated(`{{RAW_DATA}}`$text),] #Delete duplicated

# Required data for the report
`{{CLEAN_DATA}}` %>% dplyr::transmute(created_at,screen_name,text,favorite_count,
retweet_count,followers_count,verified) -> `{{CLEAN_DATA}}`

# Separate text 
`{{CLEAN_DATA}}` %>% dplyr::transmute(created_at, text) -> `{{TEXT_ONLY_DATA}}`

# Take hourly number of tweet
ts_data(`{{CLEAN_DATA}}`, by = "hours", trim = 0L, tz = "UTC") -> TweetsVolume
TweetsVolume[-(509),] -> TweetsVolume #Remove uncompleted data

within(TweetsVolume, n <- log(n)) -> TweetsVolume #optional

ts_plot(`{{CLEAN_DATA}}`, by = "hours", trim = 0L, tz = "UTC") + 
  theme_get() +
  ggtitle("Number of Tweets per hour")

### Function to clean text data
clean_text <- function(text) {
  # Remove unwanted characters and clean text
  text <- gsub("<(.*)>", "", text) # Remove Unicodes like <U+A>
  text <- gsub("\\ \. ", " ", text) # Replace orphaned full stops with space
  text <- gsub("%%", "'", text) # Change %% back to apostrophes
  text <- gsub("\\n", "-", text) # Replace line breaks with "-"
  text <- gsub("^[[:space:]]*", "", text) # Remove leading whitespaces
  text <- gsub("[[:space:]]*$", "", text) # Remove trailing whitespaces
  text <- gsub(" +", " ", text) # Remove extra whitespaces
  text <- gsub("'", "%%", text) # Replace apostrophes with %%
  return(text)
}

### Function to remove stopwords
remove_stopwords <- function(text) {
  # Remove English stopwords from text
  stopwords_list <- stopwords('en')
  text <- removeWords(text, stopwords_list)
  return(text)
}

### Function to convert time format
convert_time <- function(created_at) {
  # Convert created_at to a standard datetime format
  created_at <- substr(created_at, 1, 13)
  created_at <- paste0(created_at, ':00:00')
  return(ymd_hms(created_at))
}

### Consolidated function for text cleaning
clean_and_process_text <- function(text) {
  text <- tolower(text) # Convert to lower case
  text <- gsub("http\\S+", "", text) # Remove URLs
  text <- gsub("@\\w+", "", text) # Remove mentions
  text <- gsub("[[:punct:]]", "", text) # Remove punctuation
  text <- gsub("[ |	]{2,}", "", text) # Remove extra spaces
  text <- iconv(text, "latin1", "ASCII", sub="") # Remove emojis
  text <- gsub("^ ", "", text) # Remove leading spaces
  text <- gsub(" $", "", text) # Remove trailing spaces
  return(text)
}

### Data text cleansing 
`{{TEXT_ONLY_DATA}}`$text <- clean_and_process_text(`{{TEXT_ONLY_DATA}}`$text)
`{{TEXT_ONLY_DATA}}`$text <- clean_text(`{{TEXT_ONLY_DATA}}`$text)
`{{TEXT_ONLY_DATA}}`$text <- remove_stopwords(`{{TEXT_ONLY_DATA}}`$text)

# Replace double spaces with a single space
`{{TEXT_ONLY_DATA}}`$text <- gsub("  ", " ", `{{TEXT_ONLY_DATA}}`$text) # Can run multiple times for optimal results

# Apply time conversion
`{{TEXT_ONLY_DATA}}`$created_at <- convert_time(`{{TEXT_ONLY_DATA}}`$created_at)

### Sentiment analysis
# Error handling for sentiment analysis
tryCatch({
  TwitterSentimentHourly <- `{{TEXT_ONLY_DATA}}` %>% 
    get_sentences() %>% 
    sentiment_by(by = c("created_at")) %>% 
    mutate(tvolume = TweetsVolume$n) %>% 
    rename(time = created_at)
}, error = function(e) {
  message("Error in sentiment analysis: ", e$message, " at created_at: ", created_at)
})

### Data visualization section
# Plot the sentiment density
TwitterSentiment %>%
  ggplot(aes(x = Average_Sentiment)) + 
  geom_density(aes(ave_sentiment),fill="#69b3a2", color="#69b3a2", alpha=0.8) + 
  theme_get() +
  ggtitle("Public Twitter Sentiment Density")

# Plot the comparison of number of positive and negative tweets and price
TwitterSentiment %>% mutate(`{{TEXT_ONLY_DATA}}`) -> dfNPPlot
dfNPPlot$created_at <- format(as.Date(dfNPPlot$created_at, format = "%d-%m" ), "%m-%d") #format date and time for plotting
BTC.USD$Date <- format(as.Date(BTC.USD$Date, format = "%d-%m" ), "%m-%d") 

dfNPPlot %>%
  dplyr::transmute(created_at, ave_sentiment) %>%
  mutate(polarity_level = ifelse(ave_sentiment < 0, "Negative", ifelse(ave_sentiment > 0, "Positive","Neutral"))) %>%
  count(created_at,polarity_level) %>%
  ggplot() + 
  geom_col(aes(x = created_at, y = n, fill = polarity_level)) 

# Combine with the price line chart, still need polishing
dfNPPlot %>%
  dplyr::transmute(created_at, ave_sentiment) %>%
  mutate(polarity_level = ifelse(ave_sentiment < 0, "Negative", ifelse(ave_sentiment > 0, "Positive","Neutral"))) %>% 
  count(created_at,polarity_level) %>% 
  spread (polarity_level, n) -> PolarityLevel
  
PolarityLevel %>% 
  ggplot() + 
  geom_bar(aes(x = created_at, y = n, fill = polarity_level), stat="identity") +
  geom_line(data = BitcoinDailyDataForPlot, aes(x = Date, y= Close), stat="identity", group = 1, lwd=1.5, colour="orange4")

### Positiveness and Agreement calculation
within(PositiveAndNegative, Positiveness <- log((1 + Positive)/(1 + Negative))) -> PositivenessAndAgreement
within(PositivenessAndAgreement, Agreement <- 1 - sqrt(1 - ((Positive - Negative)/(Positive + Negative)))) -> PositivenessAndAgreement
PositivenessAndAgreement %>% transmute(time, Positiveness, Agreement) -> PositivenessAndAgreement
PositivenessAndAgreement %>% mutate(sentiment = TwitterSentimentHourly$ave_sentiment) -> PositivenessAndAgreement

### Combine positiveness and agreement, tweet volume, and bitcoin price and volume
bind_rows(BitcoinPriceAndVolume, TweetsVolume, PositivenessAndAgreement) -> FinalData
FinalData <- aggregate(FinalData[-1], list(FinalData$time), FUN = mean, na.rm = TRUE) #Aggregate for parse df
FinalData <- FinalData[complete.cases(FinalData), ] #Remove NA 
FinalData <- FinalData[-(509),]
FinalData <- FinalData[-(1),] #Remove uncompleted data
within(FinalData, n <- log(n)) -> FinalData
within(FinalData, volume <- log(volume)) -> FinalData
within(FinalData, price <- log(price)) -> FinalData
