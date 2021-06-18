library(cmdstanr)
library(rjson)
library(tidyverse)
library(lubridate)
library(posterior)

cmdstanr::check_cmdstan_toolchain()

data <- "https://raw.githubusercontent.com/hodcroftlab/covariants/master/cluster_tables/21A.Delta_data.json"

data <- rjson::fromJSON(file = data)

usa <- data$USA

usa_data <- usa %>% as_tibble() %>% mutate(week = as_date(week, format = "%Y-%m-%d")) %>% 
    mutate(epiweek = lubridate::epiweek(week)) %>% 
    mutate(prop = cluster_sequences/total_sequences) %>% 
    select(week, epiweek, prop, cluster_sequences, total_sequences)
    


input_data <- list(
    x = usa_data$cluster_sequences,
    offset = usa_data$total_sequences,
    N = nrow(usa_data),
    alpha = 1, 
    rho = 1
)

model <- cmdstan_model("sample.stan")

fit <- model$sample(
    data = input_data, 
    chains = 1, fixed_param = TRUE, 
    iter_warmup = 0, iter_sampling = 500,
)

saveRDS(fit, file = "output/sample_fit.rds")

model_latent <- cmdstan_model("gp.stan")

usa_data <- usa_data %>% mutate(time = seq(1:nrow(usa_data)))

input_data <- list(
    x = usa_data$time,
    y = usa_data$cluster_sequences,
    offset = usa_data$total_sequences,
    N = nrow(usa_data)
)

fit <- model_latent$sample(
    data = input_data, 
    chains = 4, 
    parallel_chains = 2, 
)


draws <- fit$draws()
saveRDS(draws, "output/latent_draw.rds")


draws_mat <- as_draws_matrix(draws)
draws_mat

Ef <- colMeans(subset(draws_mat, variable = 'fitted'))
lower <- apply(subset(draws_mat, variable = 'fitted'), 2, quantile, probs = 0.025)
upper <- apply(subset(draws_mat, variable = 'fitted'), 2, quantile, probs = 0.975)

rpois(lambda = Ef + log(input_data$offset))
y <- vector(length = length(Ef))
for (i in 1:length(Ef)){
    y[i] <- rpois(1, lambda = exp(Ef[i] + log(input_data$offset[i])))
}


ggplot() + 
    geom_line(aes(x = input_data$x, y = input_data$y, col = "True Values"), col = "red") + 
    geom_line(aes(x = input_data$x, y = Ef, col = "Fitted Values"), col = "steelblue") + 
    theme(legend.position = "left") + 
    geom_ribbon(aes(x = input_data$x, ymin = lower, ymax = upper), alpha = 0.3) + 
    theme_bw() + labs(x = "Time steps", y = "Number of detected cases")

prob_fit <- colMeans(subset(draws_mat, variable = "prob"))
ggplot() + 
    geom_line(aes(x = input_data$x, y = prob_fit), col = "steelblue") + 
    geom_line(aes(x = input_data$x, y = usa_data$prop), col = "red")

