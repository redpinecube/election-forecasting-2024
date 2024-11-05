#### Preamble ####
# Purpose: Clean election data from FiveThirtyEight for the 2024 election.
# Author: Tara Chakkithara
# Date: October 29 2024
# Contact: tara.chakkithara@icloud.com
# License: MIT


### Required Packages ###
library(tidyverse)

# read data 
data <- read_csv('./data/raw_data/president_polls.csv')

# For our analysis we will only be looking at swing states.
swing_states <- c("Pennsylvania", "Nevada", "North Carolina", "Wisconsin",
                  "Michigan", "Georgia", "Arizona")
data <- data |>
  filter(state %in% swing_states) |>
  filter(candidate_name == "Donald Trump") |>
  rename(swing_state = state)

# To ensure that we are looking at high quality polls we can filter out polls with 
# a pollscore greater than 0. Lets choose to look at non hypothetical scenarios 
# and filter out data before Biden dropped out of the presidential election. 

biden_drop_date <- as.Date("2024-07-21")
data <- data |>
  filter(hypothetical == FALSE) |>
  filter(pollscore < 0) |>
  mutate(start_date = as.Date(sub("(..)$", "20\\1", start_date), format = "%m/%d/%Y")) |>
  filter(start_date > biden_drop_date)
  
# Finally we can just look at the variables swing state, and pct
# for our analysis. 

data <- data |>
  select(swing_state, pct)

# save cleaned data for analysis in data/analysis_data
write_csv(data, './data/analysis_data/analysis_data.csv')
  


