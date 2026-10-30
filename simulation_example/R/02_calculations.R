# Calculations: read data from a run folder, write results alongside it

library(yaml)

source(if (file.exists("R/paths.R")) "R/paths.R" else "simulation_example/R/paths.R")
root <- project_root()
source(file.path(root, "R", "functions.R"))

# run_dir defaults to the latest run for the current simulation parameters.
# Existing results are not replaced unless overwrite = TRUE.
run_calculations <- function(root, run_dir = NULL, overwrite = FALSE) {
  params <- read_yaml(file.path(root, "config", "params.yml"))
  if (is.null(run_dir)) run_dir <- latest_run_dir(root, params)

  # The data must come from the simulation settings currently in the config
  snapshot <- read_yaml(file.path(run_dir, "params.yml"))
  if (!identical(snapshot$simulation, params$simulation)) {
    stop("Simulation parameters in config/params.yml differ from those in ",
         run_dir, "/params.yml. Re-run the simulation or pass another run_dir.")
  }

  results_file <- file.path(run_dir, run_file("results", params))
  if (file.exists(results_file) && !overwrite) {
    stop(results_file, " already exists. Use overwrite = TRUE to replace it.")
  }

  data_file <- file.path(run_dir, run_file("sim_data", params))
  message("Reading ", data_file)
  data <- read.csv(data_file)

  # Sanity checks: correlation near rho, means near 0, SDs near 1
  print(cor(data$x, data$y))
  print(colMeans(data))
  print(apply(data, 2, sd))

  results <- paired_tost(
    data$x, data$y,
    sd_multiplier = params$equivalence$sd_multiplier,
    alpha = params$equivalence$alpha
  )

  write.csv(results, results_file, row.names = FALSE)
  # Equivalence settings used for these results
  write_yaml(params$equivalence, file.path(run_dir, "params_equivalence.yml"))

  message("Wrote ", results_file)
  results
}
