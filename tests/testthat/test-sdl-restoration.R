test_that("SDL demo includes every source enzyme/concentration/reaction", {
  expect_equal(nrow(sdl_demo), 192L)
  expect_equal(sort(unique(sdl_demo$s_uM)),
               c(3.90625, 7.8125, 15.625, 31.25, 62.5, 125, 250, 500))
  expect_true(all(table(sdl_demo$enzyme, sdl_demo$s_uM) == 4L))
  expect_true(all(table(sdl_demo$enzyme) == 32L))
  csv <- utils::read.csv(system.file("extdata", "sdl_demo.csv", package = "inferMM"))
  expect_equal(sdl_demo, csv)
})

test_that("source preparation retains unit-free decimal headers and all rates", {
  preparation <- new.env(parent = baseenv())
  sys.source(system.file("data-preparation", "prepare_sdl_demo.R", package = "inferMM"),
             envir = preparation)
  headers <- preparation$sdl_parse_headers(c("1111-3.90625", "1111-7.8125uM"))
  expect_equal(headers$s_uM, c(3.90625, 7.8125))
  expect_error(preparation$sdl_parse_headers("unknown-reaction"), "Unrecognized")
  rates <- preparation$sdl_prepare_rates(
    system.file("extdata", "sdl_fluorescence_raw.csv", package = "inferMM"))
  expect_equal(rates[, names(sdl_demo)], sdl_demo, tolerance = 1e-12)
  expect_true(all(rates$n_used == 3L))
  expect_equal(rates$times_used[1L], "0, 119.815, 239.817")
})

test_that("grouped SDL fits remain separate single-curve fits after restoration", {
  data <- subset(sdl_demo, enzyme %in% c(1111L, 2222L))
  grouped <- group_mm(data, s = "s_uM", v = "v_uM_per_min", groups = "enzyme",
                       variance_models = "sqrt", quiet = TRUE)
  expect_equal(nrow(grouped$estimates), 2L)
  expect_true(all(grouped$estimates$n_obs == 32L))
  for (enzyme in unique(data$enzyme)) {
    curve <- data[data$enzyme == enzyme, , drop = FALSE]
    single <- fit_mm(curve$s_uM, curve$v_uM_per_min, variance = "sqrt")
    row <- grouped$estimates[grouped$estimates$group_label == paste0("enzyme=", enzyme), ]
    expect_equal(c(row$Vmax_hat, row$Km_hat), unname(coef(single)), tolerance = 1e-12)
    expect_equal(c(row$se_Vmax, row$se_Km), unname(sqrt(diag(vcov(single)))),
                 tolerance = 1e-12)
  }
  expect_gt(diff(range(grouped$estimates$Km_hat)), 50)
})
