library(tidyverse)
library(splines)
library(ebbr)


data <- read_csv(file = "data/processed.csv")
data <- data %>% mutate(days = seq(1,nrow(data)))
data

data
em_bayes <- data %>% 
    add_ebb_estimate(strain_detect, tot_samples, method = "gamlss", mu_predictors = ~ 0 + ns(days,df = 2) + new_cases)
em_bayes 

em_bayes
