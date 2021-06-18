// One dimensional gaussian
// Some tutorials: https://www.youtube.com/watch?v=132s2B-mzBg&list=PLCrWEzJgSUqwL85xIj1wubGdY15C5Gf7H&index=8
// https://betanalpha.github.io/assets/case_studies/gaussian_processes.html#43_Approximating_Gaussian_Processes
// https://avehtari.github.io/casestudies/Motorcycle/motorcycle.html#GP_with_covariance_matrices

data {
    int<lower=1> N; 
    real x[N];
    int offset[N];
    int y[N];
}


transformed data {
    real delta = 1e-9;
    //vector[N] offset_log = log(offset);
    //real stdev = sd(x);
    //real xmean = mean(x);
    //real x_std[N] = to_array_1d((x - xmean)/stdev);
}

parameters {
    real<lower=0> rho;
    real<lower=0> alpha;
    real<lower=0> sigma;
    vector[N] eta;
    real phi;
}

transformed parameters{
    matrix[N,N] K = cov_exp_quad(x, alpha, rho) + diag_matrix(rep_vector(delta,N));
    matrix[N,N] K_decomp = cholesky_decompose(K);
    vector[N] f = K_decomp * eta;
    
    vector[N] mu;
    for (n in 1:N){
        mu[n] = inv_logit(f[n]);
    }
    vector[N] a = mu * phi;
    vector[N] b = (1 - mu) * phi;
    // vector[N] lp;
    // for (n in 1:N){
    //    lp[n] = f[n] + offset_log[n];
    // }
    //real mu[N];
    //mu = exp(lp);
}

model {
    rho ~ inv_gamma(5,5);
    alpha ~ std_normal();
    sigma ~ std_normal();
    eta ~ std_normal();
    
    // Sample from beta binomial model 
    y ~ beta_binomial(offset, a, b);
}


generated quantities {
    vector[N] fitted;
    for (n in 1:N){
        fitted[n] = beta_binomial_rng(offset[n], a[n], b[n]);
    }
    vector[N] prob;
    for (n in 1:N){
        prob[n] = beta_rng(a[n], b[n]);
    }
}