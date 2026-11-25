# Rebuild the demo from the source fluorescence CSV without installing inferMM.
# From the package source root: Rscript data-raw/prepare_sdl_demo.R
# Optional arguments: path/to/raw.csv path/to/package/source
args <- commandArgs(trailingOnly = TRUE)
script <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1L])
package_root <- if (length(args) >= 2L) args[2L] else dirname(dirname(script))
if (basename(package_root) == "inst") package_root <- dirname(package_root)
package_root <- normalizePath(package_root, mustWork = TRUE)
raw_csv <- if (length(args)) args[1L] else
  file.path(package_root, "inst", "extdata", "sdl_fluorescence_raw.csv")
source(file.path(package_root, "inst", "data-preparation", "prepare_sdl_demo.R"))
rates <- sdl_prepare_rates(raw_csv)
sdl_demo <- rates[, c("enzyme", "s_uM", "replicate", "v_uM_per_s", "v_uM_per_min")]
environment_data <- new.env(parent = emptyenv())
data_file <- file.path(package_root, "data", "infer_mm_demo_data.rda")
load(data_file, envir = environment_data)
environment_data$sdl_demo <- sdl_demo
save(list = c("sdl_demo", "alves_demo"), envir = environment_data,
     file = data_file, compress = "xz", version = 2)
utils::write.csv(sdl_demo, file.path(package_root, "inst", "extdata", "sdl_demo.csv"),
                 row.names = FALSE)
cat("Prepared", nrow(sdl_demo), "rates: six enzymes x eight concentrations x four reactions.\n")
