# Data simulation: generate data, write to CSV, record filename in params.yml

library(tibble)
library(yaml)

source("R/functions.R")

params_file <- "config/params.yml"
params <- read_yaml(params_file)
sim <- params$simulation

set.seed(sim$seed)
data <- simulate_correlated_normals(sim$n_obs, sim$rho)

# Filename encodes date and seed
data_file <- file.path(
  "data",
  sprintf("sim_data_%s_seed%d.csv", format(Sys.Date(), "%Y-%m-%d"), sim$seed)
)
write.csv(data, data_file, row.names = FALSE)

# Note: rewriting the YAML drops its comments
params$files$data <- data_file
write_yaml(params, params_file)

message("Wrote ", data_file)
