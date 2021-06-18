data {
  int<lower=1> N;
  real x[N]; // our data 
  real<lower=0> alpha;
  real<lower=0> rho;
  vector[N] offset; // log offset
}

transformed data {
  matrix[N,N] K = cov_exp_quad(x, alpha, rho) + diag_matrix(rep_vector(1e-9,N)); 
  vector[N] mu = rep_vector(0, N);
  vector[N] f = multi_normal_rng(mu, K);
  vector[N] offset_log = log(offset);
}

generated quantities {
  vector[N] value;
  for (n in 1:N){
    value[n] = poisson_log_rng(f[n] + offset_log[n]);
  }
}