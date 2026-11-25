default_screen_data <- function() {
  x <- seq(1, 100, length.out = 60)
  data.frame(x = x, y = 100 * x / (20 + x) + sin(seq_along(x)))
}

test_that("omitted variance returns the best four-model screen as a regular fit", {
  dat <- subset(sdl_demo, enzyme == "1111")
  screen <- screen_mm(dat$s_uM, dat$v_uM_per_min, quiet = TRUE)
  fit <- fit_mm(dat$s_uM, dat$v_uM_per_min)
  explicit_screen <- fit_mm(dat$s_uM, dat$v_uM_per_min, variance = "screen")
  winner <- screen$table$model[which.min(screen$table$quasi_aic)]
  reference <- fit_mm(dat$s_uM, dat$v_uM_per_min, variance = winner)

  expect_s3_class(fit, "fit_mm")
  expect_identical(fit$variance_selection_mode, "screen")
  expect_identical(fit$variance_selection, "quasi_aic")
  expect_setequal(fit$screen_table$model, c("constant", "log", "sqrt", "cuberoot"))
  expect_equal(nrow(fit$screen_table), 4L)
  expect_identical(fit$screen_table, fit$variance_candidate_table)
  expect_type(fit$screen_table$selected, "logical")
  expect_equal(sum(fit$screen_table$selected), 1L)
  expect_identical(fit$screen_table$model[fit$screen_table$selected], winner)
  expect_identical(fit$variance_model, winner)
  expect_equal(coef(fit), coef(reference), tolerance = 1e-12)
  expect_equal(vcov(fit), vcov(reference), tolerance = 1e-12)
  expect_equal(confint(fit), confint(reference), tolerance = 1e-12)
  expect_equal(predict(fit, c(10, 50, 100), interval = "confidence"),
               predict(reference, c(10, 50, 100), interval = "confidence"),
               tolerance = 1e-12)
  expect_equal(coef(explicit_screen), coef(fit), tolerance = 1e-12)
  expect_identical(fit$call, quote(fit_mm(x = dat$s_uM, y = dat$v_uM_per_min)))
})

test_that("AIC and BIC select from the same four fixed candidate shapes", {
  dat <- default_screen_data()
  aic <- fit_mm(dat$x, dat$y)
  bic <- fit_mm(dat$x, dat$y, power_selection = "quasi_bic")
  expect_identical(bic$variance_selection, "quasi_bic")
  expect_identical(bic$variance_model, aic$variance_model)
  expect_equal(coef(bic), coef(aic), tolerance = 1e-12)
  tab <- bic$screen_table
  expect_equal(tab$rank_quasi_aic, tab$rank_quasi_bic)
  expect_equal(tab$quasi_bic - tab$quasi_aic,
               rep(3 * log(nrow(dat)) - 6, nrow(tab)), tolerance = 1e-12)
  expect_true(tab$selected[which.min(tab$quasi_bic)])
})

test_that("screening is silent until the fit or summary is printed", {
  dat <- default_screen_data()
  expect_silent(fit <- fit_mm(dat$x, dat$y))
  expect_silent(summ <- summary(fit))
  expect_identical(summ$screen_table, fit$screen_table)
  expect_identical(summ$variance_selection_mode, "screen")
  printed <- paste(capture.output(print(fit)), collapse = "\n")
  summary_printed <- paste(capture.output(print(summ)), collapse = "\n")
  for (txt in list(printed, summary_printed)) {
    expect_match(tolower(txt), "screen")
    expect_match(txt, "quasi_aic", fixed = TRUE)
    expect_match(txt, "quasi_bic", fixed = TRUE)
    expect_match(txt, "selected", ignore.case = TRUE)
    expect_match(txt, "condition", ignore.case = TRUE)
    expect_true(all(vapply(c("constant", "log", "sqrt", "cuberoot"),
                           grepl, logical(1), x = txt, fixed = TRUE)))
    expect_match(txt, "Vmax", fixed = TRUE)
    expect_match(txt, "Km", fixed = TRUE)
  }
  invisible(capture.output(out <- withVisible(print(fit))))
  expect_false(out$visible)
  expect_identical(out$value, fit)
})

test_that("explicit fixed and user-defined variance fits bypass screening", {
  dat <- default_screen_data()
  runs <- with_mocked_bindings(
    list(log = fit_mm(dat$x, dat$y, variance = "log"),
         sqrt = fit_mm(dat$x, dat$y, variance = "sqrt"),
         custom = fit_mm(dat$x, dat$y, variance = function(S) 1 + S / 20)),
    screen_mm = function(...) stop("Screening must not run for an explicit shape."),
    .package = "inferMM"
  )
  expect_identical(runs$log$variance_model, "log")
  expect_identical(runs$sqrt$variance_model, "sqrt")
  expect_identical(runs$custom$variance_model, "custom")
  for (fit in runs) {
    expect_null(fit$screen_table)
    expect_null(fit$variance_candidate_table)
    expect_true(all(is.finite(coef(fit))))
    expect_false(grepl("screening", paste(capture.output(print(fit)), collapse = "\n"),
                       ignore.case = TRUE))
  }
})

test_that("the existing auto option retains its log-plus-power-grid search", {
  dat <- default_screen_data()
  fit <- with_mocked_bindings(
    fit_mm(dat$x, dat$y, variance = "auto", power_grid = c(0.3, 0.7)),
    screen_mm = function(...) stop("The old auto path must not use the four-model screen."),
    .package = "inferMM"
  )
  expect_identical(fit$variance_selection_mode, "auto")
  expect_equal(nrow(fit$variance_candidate_table), 3L)
  expect_setequal(fit$variance_candidate_table$candidate,
                  c("log", "power(0.3)", "power(0.7)"))
  expect_null(fit$screen_table)
})

test_that("refits and bootstrap intervals condition on the selected shape", {
  dat <- default_screen_data()
  fit <- fit_mm(dat$x, dat$y, interval_level = 0.9, km_bounds = c(0.1, 500))
  refit <- with_mocked_bindings(
    inferMM:::refit_fit_mm(fit, x = rev(dat$x), y = rev(dat$y)),
    screen_mm = function(...) stop("A conditional refit must not repeat screening."),
    search_auto_variance = function(...) stop("A screen fit must not become power-grid auto."),
    .package = "inferMM"
  )
  expect_identical(refit$variance_model, fit$variance_model)
  expect_equal(refit$interval_level, 0.9)
  expect_equal(refit$km_bounds, c(0.1, 500))
  expect_equal(coef(refit), coef(fit), tolerance = 1e-10)
  expect_null(refit$screen_table)

  set.seed(507)
  ci <- with_mocked_bindings(
    confint(fit, method = "bootstrap", B = 25, bootstrap_type = "wild"),
    screen_mm = function(...) stop("Bootstrap resamples must hold the selected shape fixed."),
    .package = "inferMM"
  )
  expect_true(all(is.finite(ci)))
  expect_identical(attr(attr(ci, "bootstrap_draws"), "successful_B"), 25L)
})

test_that("the four-model screen forwards bounds and rejects invalid inputs", {
  dat <- default_screen_data()
  fit <- fit_mm(dat$x, dat$y, km_bounds = c(0.1, 500), interval_level = 0.9)
  reference <- fit_mm(dat$x, dat$y, variance = fit$variance_model,
                      km_bounds = c(0.1, 500), interval_level = 0.9)
  expect_equal(fit$km_bounds, c(0.1, 500))
  expect_equal(fit$interval_level, 0.9)
  expect_equal(confint(fit), confint(reference), tolerance = 1e-12)
  expect_error(fit_mm(dat$x, dat$y, km_bounds = c(500, 0.1)), "increasing")
  expect_error(fit_mm(dat$x, dat$y, power_selection = "unknown"), "arg")
  expect_error(fit_mm(dat$x, dat$y, variance = "unknown"), "arg")
})

test_that("failed candidates remain visible and cannot be selected", {
  dat <- default_screen_data()
  original <- inferMM:::fit_mm_from_spec
  fit <- with_mocked_bindings(
    fit_mm(dat$x, dat$y),
    fit_mm_from_spec = function(...) {
      args <- list(...)
      if (identical(args$variance, "sqrt")) stop("Synthetic square-root candidate failure.")
      do.call(original, args, quote = TRUE)
    },
    .package = "inferMM"
  )
  failed <- fit$screen_table[fit$screen_table$model == "sqrt", ]
  expect_equal(nrow(failed), 1L)
  expect_equal(failed$success, 0)
  expect_false(failed$selected)
  expect_true(is.na(failed$quasi_aic))
  expect_true(is.na(failed$quasi_bic))
  expect_match(failed$error_message, "Synthetic square-root candidate failure")
  expect_false(identical(fit$variance_model, "sqrt"))
  expect_equal(sum(fit$screen_table$selected), 1L)
  expect_true(all(is.finite(confint(fit))))
})

test_that("complete selection failure returns no fabricated fit or interval", {
  x <- seq(1, 100, length.out = 60)
  failure <- tryCatch(fit_mm(x, 2 * x), inferMM_profile_error = function(e) e)
  expect_s3_class(failure, "inferMM_profile_error")
  expect_identical(failure$reason, "no_successful_candidate")
  expect_false(inherits(failure, "fit_mm"))
  expect_true(is.data.frame(failure$screen_table))
  expect_equal(nrow(failure$screen_table), 4L)
  expect_true(all(failure$screen_table$success == 0))
  expect_false(any(failure$screen_table$selected))
  expect_match(conditionMessage(failure), "No fit or confidence intervals")
})

test_that("candidate warnings are not silently swallowed by default selection", {
  dat <- default_screen_data()
  original <- inferMM:::fit_mm_from_spec
  expect_warning(
    fit <- with_mocked_bindings(
      fit_mm(dat$x, dat$y),
      fit_mm_from_spec = function(...) {
        args <- list(...)
        if (identical(args$variance, "constant")) {
          warning("Synthetic fixed-candidate warning.", call. = FALSE)
        }
        do.call(original, args, quote = TRUE)
      },
      .package = "inferMM"
    ),
    "Synthetic fixed-candidate warning"
  )
  expect_equal(fit$screen_table$success[fit$screen_table$model == "constant"], 1)
  expect_true(all(is.finite(coef(fit))))
})
