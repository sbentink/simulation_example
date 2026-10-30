# Data simulation: write data and a parameter snapshot to a new run folder

library(tibble)
library(yaml)

# Bootstrap: find paths.R from the project folder or its parent
source(if (file.exists("R/paths.R")) "R/paths.R" else "simulation_example/R/paths.R")
root <- project_root()
source(file.path(root, "R", "functions.R"))

# Returns the path of the new run folder
simulate_and_save <- function(root) {
  params_sim <- read_yaml(file.path(root, "config", "params_simulation.yml"))

  set.seed(params_sim$seed)
  data <- simulate_correlated_normals(params_sim$n_obs, params_sim$rho)

  run_dir <- new_run_dir(root)
  data_file <- file.path(run_dir, run_file("sim_data", params_sim))
  write.csv(data, data_file, row.names = FALSE)

  # Snapshot of the simulation parameters used for this run
  write_yaml(params_sim, file.path(run_dir, "params_simulation.yml"))

  message("Wrote ", data_file)
  run_dir
}
