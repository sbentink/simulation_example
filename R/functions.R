# Reusable functions (no side effects)

# Simulate two standard normal variables with Pearson correlation rho.
# y is a mix of x and independent noise, scaled so that Var(y) = 1.
simulate_correlated_normals <- function(n, rho) {
  x <- rnorm(n)
  y <- rho * x + sqrt(1 - rho^2) * rnorm(n)
  tibble::tibble(x, y)
}

# Paired equivalence test (TOST) on the mean of x - y.
# Bounds are +/- sd_multiplier * SD of the paired differences.
paired_tost <- function(x, y, sd_multiplier, alpha = 0.05) {
  bound <- sd_multiplier * sd(x - y)

  # H0 lower: mean diff <= -bound; H0 upper: mean diff >= +bound
  lower <- t.test(x, y, paired = TRUE, mu = -bound, alternative = "greater")
  upper <- t.test(x, y, paired = TRUE, mu = bound, alternative = "less")

  # 1 - 2*alpha CI is equivalent to the TOST at level alpha
  ci <- t.test(x, y, paired = TRUE, conf.level = 1 - 2 * alpha)$conf.int
  p <- max(lower$p.value, upper$p.value)

  tibble::tibble(
    mean_diff = mean(x - y),
    bound = bound,
    ci_lower = ci[1],
    ci_upper = ci[2],
    tost_p = p,
    equivalent = p < alpha
  )
}
