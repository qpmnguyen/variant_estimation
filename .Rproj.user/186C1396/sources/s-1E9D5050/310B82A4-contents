library(tidyverse)
library(splines)
library(ebbr)


data <- read_csv(file = "data/processed.csv")
data
data <- data %>% group_by(wd) %>% summarise(var = sum(count), samples = sum(n)) %>% 
    mutate(prop = var/samples)
ggplot(data, aes(x = prop, y = avg_cases)) + geom_point() 

em_bayes <- data %>% 
    add_ebb_estimate(strain_counts, tot_samples, method = "gamlss", mu_predictors = ~ case_counts)
em_bayes

curve(dbeta(1.16, 3203))
hist(rbeta(10000,shape1 = 1.16, shape2 = 3203))
hist(rbeta(10000,1,1))
