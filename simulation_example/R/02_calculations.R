# Calculations: read simulated data and run the paired equivalence test

library(yaml)

source("R/functions.R")

params_file <- "config/params.yml"
params <- read_yaml(params_file)

data <- read.csv(params$files$data)

# Sanity checks: correlation near rho, means near 0, SDs near 1
cor(data$x, data$y)
colMeans(data)
apply(data, 2, sd)

results <- paired_tost(
  data$x, data$y,
  sd_multiplier = params$equivalence$sd_multiplier,
  alpha = params$equivalence$alpha
)

results_file <- sub("sim_data_", "results_", params$files$data)
results_file <- sub("^data/", "results/", results_file)
dir.create("results", showWarnings = FALSE)
write.csv(results, results_file, row.names = FALSE)

params$files$results <- results_file
write_yaml(params, params_file)

results
