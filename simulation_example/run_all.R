# Run the full pipeline (works from this folder or from the repository root)
source(if (file.exists("R/01_simulate_data.R")) "R/01_simulate_data.R" else "simulation_example/R/01_simulate_data.R")
source(file.path(root, "R", "02_calculations.R"))

run_dir <- simulate_and_save(root)
run_calculations(root, run_dir)
