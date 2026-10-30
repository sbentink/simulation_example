# Path helpers. Each simulation run gets its own timestamped folder under
# output/, holding the data, a parameter snapshot and the results. File names
# are derived from the parameters; readers default to the latest run.

# Locate the project root (the folder containing config/params.yml) by walking
# up from `start`. Also finds it in a "simulation_example" subfolder, so the
# scripts work from the repository root as well.
project_root <- function(start = getwd()) {
  dir <- normalizePath(start, mustWork = TRUE)
  repeat {
    for (candidate in c(dir, file.path(dir, "simulation_example"))) {
      if (file.exists(file.path(candidate, "config", "params.yml"))) {
        return(candidate)
      }
    }
    parent <- dirname(dir)
    if (parent == dir) stop("Project root (config/params.yml) not found")
    dir <- parent
  }
}

# Identifies a dataset, e.g. "seed7342_n1000_rho0.6"
run_tag <- function(params) {
  sim <- params$simulation
  sprintf("seed%d_n%d_rho%s", sim$seed, sim$n_obs, format(sim$rho))
}

# File name within a run folder, e.g. "sim_data_seed7342_n1000_rho0.6.csv"
run_file <- function(prefix, params) {
  paste0(prefix, "_", run_tag(params), ".csv")
}

# Create a new timestamped run folder, e.g. <root>/output/20261030-134525.
# If the name is taken (same second), append -2, -3, ... (still sorts after).
new_run_dir <- function(root, time = Sys.time()) {
  base <- file.path(root, "output", format(time, "%Y%m%d-%H%M%S"))
  run_dir <- base
  i <- 1
  while (dir.exists(run_dir)) {
    i <- i + 1
    run_dir <- paste0(base, "-", i)
  }
  dir.create(run_dir, recursive = TRUE)
  run_dir
}

# Most recent run folder that contains the data file for these parameters.
# Timestamps sort lexically, so the last match is the newest.
latest_run_dir <- function(root, params) {
  out <- file.path(root, "output")
  dirs <- sort(list.dirs(out, recursive = FALSE))
  has_data <- file.exists(file.path(dirs, run_file("sim_data", params)))
  if (!any(has_data)) {
    stop("No simulated data for ", run_tag(params), " in ", out, "/")
  }
  tail(dirs[has_data], 1)
}
