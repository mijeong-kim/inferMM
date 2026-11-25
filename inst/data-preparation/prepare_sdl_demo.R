# Sourceable, non-exported data-preparation helpers; no fitting code is used.
# The source fluorescence CSV is distributed in inst/extdata/.

sdl_parse_headers <- function(headers) {
  cleaned <- gsub("[[:space:]]+", "", trimws(headers))
  # Decimal digits belong to the concentration. Never strip a trailing .number.
  pattern <- "^X?([0-9]+)[-.]([0-9]+(?:[.][0-9]+)?)(?:uM|u)?$"
  matches <- regmatches(cleaned, regexec(pattern, cleaned, perl = TRUE))
  valid <- lengths(matches) == 3L
  if (!all(valid)) {
    stop("Unrecognized SDL reaction header(s): ",
         paste(headers[!valid], collapse = ", "), call. = FALSE)
  }
  enzyme <- vapply(matches, `[`, "", 2L)
  concentration <- as.numeric(vapply(matches, `[`, "", 3L))
  key <- paste(enzyme, format(concentration, digits = 15), sep = ":")
  replicate <- as.integer(stats::ave(seq_along(key), key, FUN = seq_along))
  data.frame(column = seq_along(headers) + 1L, raw_header = headers,
             enzyme = as.integer(enzyme), s_uM = concentration,
             replicate = replicate, stringsAsFactors = FALSE)
}

sdl_validate_layout <- function(data) {
  enzymes <- c(1111L, 2222L, 3333L, 4444L, 5555L, 6666L)
  concentrations <- c(3.90625, 7.8125, 15.625, 31.25, 62.5, 125, 250, 500)
  if (nrow(data) != 192L ||
      !identical(sort(unique(as.integer(data$enzyme))), enzymes) ||
      !identical(sort(unique(data$s_uM)), concentrations)) {
    stop("SDL data must contain six enzymes and all eight concentrations (192 reactions).",
         call. = FALSE)
  }
  counts <- table(data$enzyme, data$s_uM)
  if (!identical(dim(counts), c(6L, 8L)) || any(counts != 4L)) {
    stop("Each SDL enzyme/concentration combination must contain four reactions.",
         call. = FALSE)
  }
  keys <- paste(data$enzyme, data$s_uM, data$replicate, sep = ":")
  if (anyDuplicated(keys) || any(!data$replicate %in% 1:4)) {
    stop("SDL within-concentration replicate ordinals must be unique values 1 to 4.",
         call. = FALSE)
  }
  invisible(TRUE)
}

sdl_prepare_rates <- function(raw_csv, calibration_slope = 794.64,
                              n_initial_points = 3L) {
  raw <- utils::read.csv(raw_csv, check.names = FALSE, colClasses = "character",
                         stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM")
  metadata <- sdl_parse_headers(names(raw)[-1L])
  sdl_validate_layout(metadata)
  times <- suppressWarnings(as.numeric(raw[[1L]]))
  keep <- which(is.finite(times))
  keep <- keep[order(times[keep])]
  if (length(keep) < n_initial_points) stop("Too few finite SDL time points.")
  keep <- utils::head(keep, n_initial_points)
  times <- times[keep]
  if (length(unique(times)) != n_initial_points ||
      !is.finite(calibration_slope) || calibration_slope <= 0) {
    stop("Invalid SDL initial time points or fluorescence calibration.")
  }
  rates <- lapply(seq_len(nrow(metadata)), function(i) {
    rfu <- suppressWarnings(as.numeric(trimws(raw[[metadata$column[i]]][keep])))
    if (any(!is.finite(rfu))) {
      stop("Non-finite initial fluorescence in reaction ", metadata$raw_header[i])
    }
    linear_fit <- stats::lm(rfu ~ times)
    slope <- unname(stats::coef(linear_fit)[2L])
    data.frame(enzyme = metadata$enzyme[i], s_uM = metadata$s_uM[i],
               replicate = metadata$replicate[i], n_used = n_initial_points,
               times_used = paste(round(times, 3), collapse = ", "),
               intercept_rfu = unname(stats::coef(linear_fit)[1L]),
               slope_rfu_per_s = slope, r2 = summary(linear_fit)$r.squared,
               v_uM_per_s = slope / calibration_slope,
               v_uM_per_min = 60 * slope / calibration_slope,
               stringsAsFactors = FALSE)
  })
  rates <- do.call(rbind, rates)
  rates <- rates[order(rates$enzyme, rates$s_uM, rates$replicate), ]
  rownames(rates) <- NULL
  sdl_validate_layout(rates)
  rates
}
