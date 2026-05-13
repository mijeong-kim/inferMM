get_script_dir <- function() {
  frames <- sys.frames()
  ofiles <- vapply(
    frames,
    function(x) {
      if (is.null(x$ofile)) {
        return(NA_character_)
      }
      normalizePath(x$ofile, winslash = "/", mustWork = FALSE)
    },
    character(1)
  )
  ofiles <- ofiles[!is.na(ofiles)]

  if (length(ofiles)) {
    return(dirname(ofiles[length(ofiles)]))
  }

  file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(file_arg)) {
    return(dirname(normalizePath(sub("^--file=", "", file_arg[1]), winslash = "/")))
  }

  normalizePath(getwd(), winslash = "/", mustWork = FALSE)
}

script_dir <- get_script_dir()
package_dir <- normalizePath(file.path(script_dir, ".."), winslash = "/", mustWork = FALSE)
project_dir <- normalizePath(file.path(package_dir, ".."), winslash = "/", mustWork = FALSE)

sdl_source <- file.path(project_dir, "AY", "제출용", "code", "real_data_raw data", "SDL_data.csv")
alves_source <- file.path(project_dir, "AY", "제출용", "code", "real_data_raw data", "Alves_data.csv")

sdl_demo <- utils::read.csv(sdl_source, check.names = FALSE, stringsAsFactors = FALSE)
sdl_demo <- sdl_demo[, c("enzyme", "s_uM", "replicate", "v_uM_per_s", "v_uM_per_min")]

alves_demo <- utils::read.csv(alves_source, check.names = FALSE, stringsAsFactors = FALSE)
alves_demo <- subset(
  alves_demo,
  enzyme != "N/A" &
    activity != "-9999" &
    depth == "00-10" &
    temperature == "10"
)
alves_demo$substrate_conc <- as.numeric(alves_demo$substrate_conc)
alves_demo$activity <- as.numeric(alves_demo$activity)
alves_demo <- alves_demo[, c("core", "depth", "enzyme", "temperature", "substrate_conc", "activity")]
row.names(alves_demo) <- NULL

save(
  sdl_demo,
  alves_demo,
  file = file.path(package_dir, "data", "infer_mm_demo_data.rda"),
  compress = "xz"
)

utils::write.csv(sdl_demo, file.path(package_dir, "inst", "extdata", "sdl_demo.csv"), row.names = FALSE)
utils::write.csv(alves_demo, file.path(package_dir, "inst", "extdata", "alves_demo.csv"), row.names = FALSE)
