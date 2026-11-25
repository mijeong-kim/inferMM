\name{inferMM-package}
\alias{inferMM-package}
\alias{inferMM}
\title{inferMM: Variance-Aware Michaelis-Menten Estimation and Inference}
\description{
The \pkg{inferMM} package provides variance-aware tools for Michaelis-Menten
estimation, clustered repeated-measurement analysis, model screening, grouped
curve analysis, simulation, and prediction.
Single-curve fits and grouped screening accept user-defined fixed positive
variance functions in addition to the built-in variance shapes.
An optional higher-moment estimator fits independent curves using working
skewness and kurtosis, with joint sandwich or model-based covariance.
By default, \code{\link{fit_mm}} compares four fixed variance shapes and
returns the selected curve fit with its screening table. Specifying a
variance shape or function fits that shape directly.
}
\details{
The data help pages \code{\link{sdl_demo}} and
\code{\link{alves_demo}} document the original publications, public data
locations and preparation of the bundled examples.

Kim and Ma (2012, Section 3) provide the conditional-moment score framework
used by the independent-curve estimators. The optional
\code{cluster_mm(method = "projected")} adapts the conditional-centering
construction of Ma and Genton (2010, Section 3.2).
Kim (2023) provides related background on how error-distribution assumptions
affect regression estimation. The individual function help pages identify
the references for their estimation, resampling and screening methods.

The package focuses on enzyme-kinetic settings where measurement variability may
increase with substrate concentration, making standard homoscedastic nonlinear
least squares inadequate for interval estimation and uncertainty quantification.
}
\references{
Kim, M. and Ma, Y. (2012). The efficiency of the second-order nonlinear
least squares estimator and its extension.
\emph{Annals of the Institute of Statistical Mathematics}, \bold{64}, 751--764.

\doi{10.1007/s10463-011-0332-y}.

Kim, M. (2023). Appropriate use of parametric and nonparametric methods
in estimating regression models with various shapes of errors.
\emph{Stat}, \bold{12}, e606.

\doi{10.1002/sta4.606}.

Ma, Y. and Genton, M. G. (2010). Explicit estimating equations for
semiparametric generalized linear latent variable models.
\emph{Journal of the Royal Statistical Society: Series B}, \bold{72}, 475--495.

\doi{10.1111/j.1467-9868.2010.00741.x}.
}
\seealso{
\code{\link{fit_mm}}, \code{\link{fit_mm_moments}},
\code{\link{cluster_mm}}, \code{\link{report_mm}},
\code{\link{screen_mm}}, \code{\link{group_mm}},
\code{\link{simulate_mm_data}}, \code{\link{variance_function}},
\code{\link{sdl_demo}}, \code{\link{alves_demo}}
}
\keyword{package}
