# Path helpers. Each simulation run gets its own timestamped folder under
# output/, holding the data, the results and snapshots of the parameter files
# used (params_simulation.yml, params_equivalence.yml). File names are derived
# from the simulation parameters; readers default to the latest run.

# Locate the project root (the folder containing config/params_simulation.yml)
# by walking up from `start`. Also finds it in a "simulation_example"
# subfolder, so the scripts work from the parent folder as well.
project_root <- function(start = getwd()) {
  marker <- file.path("config", "params_simulation.yml")
  dir <- normalizePath(start, mustWork = TRUE)
  repeat {
    for (candidate in c(dir, file.path(dir, "simulation_example"))) {
      if (file.exists(file.path(candidate, marker))) return(candidate)
    }
    parent <- dirname(dir)
    if (parent == dir) stop("Project root (", marker, ") not found")
    dir <- parent
  }
}

# Identifies a dataset, e.g. "seed7342_n1000_rho0.6"
run_tag <- function(params_sim) {
  sprintf("seed%d_n%d_rho%s", params_sim$seed, params_sim$n_obs,
          format(params_sim$rho))
}

# File name within a run folder, e.g. "sim_data_seed7342_n1000_rho0.6.csv"
run_file <- function(prefix, params_sim) {
  paste0(prefix, "_", run_tag(params_sim), ".csv")
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
latest_run_dir <- function(root, params_sim) {
  out <- file.path(root, "output")
  dirs <- sort(list.dirs(out, recursive = FALSE))
  has_data <- file.exists(file.path(dirs, run_file("sim_data", params_sim)))
  if (!any(has_data)) {
    stop("No simulated data for ", run_tag(params_sim), " in ", out, "/")
  }
  tail(dirs[has_data], 1)
}
