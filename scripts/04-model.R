#### Preamble ####
# Purpose: We will use bayesian forecasting with 
# monte carlo simulation to model the 2024 elction. 
# Author: Tara Chakkithara
# Date: October 29 2024
# Contact: tara.chakkithara@icloud.com
# License: MIT

### Required Packages ###
library(tidyverse)

# read data
data <- read_csv('data/analysis_data/analysis_data.csv')

set.seed(1)

# for all swing states generate KDEs for pct
generate_state_kde <- function(data, state){
  filtered_data <- data |>
    filter(swing_state == state)
  kde <- density(filtered_data$pct)
  kde_data <- data.frame(x = kde$x, y = kde$y)
  return(kde_data)
}

# simulate a pct for a state
simulate <- function(data, state) {
  kde_data <- generate_state_kde(data, state)
  random_sample <- sample(kde_data$x, size = 1, prob = kde_data$y,
                          replace = TRUE)
  
  return(random_sample/100)
}

# generate seats based on simulated pct for a swing state
add_seats <- function(data, state, seats) {
  prob_win <- simulate(data, state)
  outcome <- rbinom(1, 1, prob_win)
  return(seats * outcome)
}

# simulate an election round
simulate_election <- function(data) {
  # initially set seat count to include red states
  seats <- 219
  seats <- seats + add_seats(data, "Arizona", 11)
  seats <- seats + add_seats(data, "Nevada", 6)
  seats <- seats + add_seats(data, "Wisconsin", 10)
  seats <- seats + add_seats(data, "Michigan", 15)
  seats <- seats + add_seats(data, "Pennsylvania", 19)
  seats <- seats + add_seats(data, "North Carolina", 16)
  seats <- seats + add_seats(data, "Georgia", 16)
  return(seats / 538)
}

# helper to simulate the election multiple times. 
monte_carlo_simulation <- function(data, num_simulations) {
  results <- numeric(num_simulations)
  
  for(i in 1:num_simulations) {
    results[i] <- simulate_election(data)
  }
  
  return(results)
}

# update the beta prior with a learning rate of 0.001 to prevent overfitting. 
update_beta_prior <- function(prior_alpha, prior_beta, data, num_simulations){
  total_simulations <- monte_carlo_simulation(data, num_simulations)
  
  learning_rate <- 0.001
  wins <- sum(total_simulations > 0.5)
  losses = length(total_simulations) - wins
  updated_alpha <- prior_alpha + wins * learning_rate
  updated_beta <- prior_beta + losses * learning_rate
  
  x <- seq(0, 1, length.out = 100)
  prior_density <- dbeta(x, prior_alpha, prior_beta)
  updated_density <- dbeta(x, updated_alpha, updated_beta)
  
  plot_data <- data.frame(
    x = rep(x, 2),
    density = c(prior_density, updated_density),
    type = rep(c("Prior", "Updated"), each = length(x))
  )
  result <- list(
    prior = list(alpha = prior_alpha, beta = prior_beta),
    updated = list(alpha = updated_alpha, beta = updated_beta),
    plot_data = plot_data
  )
  saveRDS(result, './models/model.rds')
}

# since Donald Trump is running against a woman again.
# our prior mode is based on 2016 election results.
# run 10000 simulated elections. 
update_beta_prior(4, 3, data, 10000)