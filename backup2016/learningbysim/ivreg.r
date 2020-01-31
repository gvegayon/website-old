rm(list = ls())

# System 1
# library(mvtnorm)
# 
# set.seed(11123)
# n <- 1000
# plot(ans)
# 
# 

set.seed(2)
n <- 1000
nsim <- 1e3

# Type of endogeneity: Errors correlated

bias_naive <- NULL
bias_2sls <- NULL

for (i in 1:nsim) {
  # Simulating data
  e <- mvtnorm::rmvnorm(n, sigma = matrix(c(1, .5, .5, 1), ncol=2))
  x1 <- cbind(rnorm(n))
  x2 <- cbind(rnorm(n))
  e0 <- cbind(rnorm(n))
  y0 <- 2 + x1*2 + e[,1]
  y1 <- 1 + y0*3 + x2*1 + e[,2]
  
  # Naive
  bias_naive <- rbind(bias_naive, coef(lm(y1 ~ y0 + x2)) - c(1,3,1))
  
  # 2SLS
  step1 <- lm(y0 ~ x1 + x2)
  y0hat <- predict(step1)
  bias_2sls <- rbind(bias_2sls, coef(lm(y1 ~ y0hat + x2)) - c(1,3,1))
}

oldpar <- par(no.readonly = TRUE)
par(mfrow=c(2, 1), mai=c(1,1,1,1)/2)
boxplot(bias_naive, main="Naive", ylim=c(-.3,.3))
abline(h=0)
boxplot(bias_2sls, main="2SLS", ylim=c(-.3,.3))
abline(h=0)
par(oldpar)

library(AER)
ansiv <- ivreg(y1~y0+x2|x2+x1)

ans <- lm(y1 ~ y0hat + x2)
Pz <- cbind(1, x1, x2)
Pz <- Pz %*% solve(t(Pz) %*% Pz) %*% t(Pz)
X <- cbind(1, y0hat, x2)
mean(ans$residuals^2)*solve(t(X)%*%Pz%*%X)
