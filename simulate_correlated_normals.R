# Simulate two standard normal variables with a Pearson correlation of 0.6

library(tibble)

# Seed for reproducibility
set.seed(7342)

# Sample size and target correlation
n <- 1000
rho <- 0.6

# x is standard normal; y is a mix of x and independent noise,
# scaled so that y also has variance 1 and cor(x, y) = rho
x <- rnorm(n)
y <- rho * x + sqrt(1 - rho^2) * rnorm(n)

sim <- tibble(x, y)

# Sanity checks: correlation near 0.6, means near 0, SDs near 1
cor(sim$x, sim$y)
colMeans(sim)
apply(sim, 2, sd)

# Paired equivalence test (TOST) on the mean difference x - y
# Equivalence bounds: +/- 3 times the SD of the paired differences
bound <- 3 * sd(sim$x - sim$y)

# H0 lower: mean diff <= -bound; H0 upper: mean diff >= +bound
lower <- t.test(sim$x, sim$y, paired = TRUE, mu = -bound, alternative = "greater")
upper <- t.test(sim$x, sim$y, paired = TRUE, mu = bound, alternative = "less")

# Equivalence is concluded if both one-sided tests reject, i.e. max p < 0.05
tost_p <- max(lower$p.value, upper$p.value)
tost_p

# 90% CI of the mean difference; equivalent if it lies within +/- bound
t.test(sim$x, sim$y, paired = TRUE, conf.level = 0.90)$conf.int
