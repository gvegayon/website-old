rm(list = ls())

logit <- function(x) log(x/(1-x))
expit <- function(x) 1/(1 + exp(-x))

set.seed(21312)
N <- 10000
k <- 5

X <- matrix(rnorm(N*k), ncol = k)
b <- cbind(runif(k))
Y <- expit(X %*% b) > runif(N)

ll <- function(par, y, x) {
  ans <- expit(x %*% par)
  ans[y==0] <- 1-ans[y==0]
  - sum(log(ans))
}

library(ABCoptim)

ans <- abc_optim(par = rep(.1, k), ll, y= Y, x = X,
                 lb = -10, ub = 10, criter=20);ans


coef(glm(Y~0+X, family = binomial(link="logit"))) - b
coef(glm(Y~0+X, family = binomial(link="probit"))) - b
b
