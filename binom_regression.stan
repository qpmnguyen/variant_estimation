//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

// The input data is a vector 'y' of length 'N'.
data {
  int<lower=0> N;
  int<lower=0> n[N]; //number of trials 
  int<lower=0> counts[N]; //successful counts 
}

// The parameters accepted by the model. 
parameters {
  real<lower=0, upper=1> mu;
  real<lower=0>sigma;
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  mu = 
  kappa ~ pareto(1, 1.5);
  theta ~ beta(phi * kappa, (1 - phi) * kappa);
  counts ~ binomial(n, theta); 
}

