# Data simulation: write data and a parameter snapshot to a new run folder

library(tibble)
library(yaml)

# Bootstrap: find paths.R from the project folder or the repository root
source(if (file.exists("R/paths.R")) "R/paths.R" else "simulation_example/R/paths.R")
root <- project_root()
source(file.path(root, "R", "functions.R"))

# Returns the path of the new run folder
simulate_and_save <- function(root) {
  params <- read_yaml(file.path(root, "config", "params.yml"))
  sim <- params$simulation

  set.seed(sim$seed)
  data <- simulate_correlated_normals(sim$n_obs, sim$rho)

  run_dir <- new_run_dir(root)
  data_file <- file.path(run_dir, run_file("sim_data", params))
  write.csv(data, data_file, row.names = FALSE)

  # Snapshot of all parameters used for this run
  write_yaml(params, file.path(run_dir, "params.yml"))

  message("Wrote ", data_file)
  run_dir
}
