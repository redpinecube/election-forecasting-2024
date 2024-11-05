#### Preamble ####
# Purpose: Tests analysis data for any issues 
# Author: Tara Chakkithara
# Date: October 29 2024
# Contact: tara.chakkithara@icloud.com
# License: MIT


#### Required Packages ####
library(tidyverse)

# read data
data <- read_csv('./data/analysis_data/analysis_data.csv')

#### Test data ####
# Some important things we need to check is that there are no empty entries in our data. 

empty_swing_state <- data |>
  filter(is.na(swing_state))

empty_pct <- data |>
  filter(is.na(pct))

# The following must be true 

print(nrow(empty_swing_state) == 0) 
print(nrow(empty_pct) == 0)

# Check if pct is a number between 0 and 100. 
print(all(data$pct >= 0 & data$pct <= 100))

# All print statements must be true. 