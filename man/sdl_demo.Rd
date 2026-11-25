\name{sdl_demo}
\alias{sdl_demo}
\title{Self-Driving Laboratory Michaelis-Menten Demo Data}
\format{
A data frame with 192 rows and 5 variables:
\describe{
  \item{\code{enzyme}}{Enzyme identifier.}
  \item{\code{s_uM}}{Substrate concentration in micromolar units.}
  \item{\code{replicate}}{Source-column occurrence ordinal within each enzyme/concentration (1--4), not a verified cross-concentration sample, well, plate, run or batch identifier.}
  \item{\code{v_uM_per_s}}{Velocity in micromolar units per second.}
  \item{\code{v_uM_per_min}}{Velocity in micromolar units per minute.}
}
}
\description{
A self-driving-laboratory enzyme-kinetic dataset used in the package examples
and vignette. Each of six enzyme variants has 32 reaction-level rates: eight
substrate concentrations (3.90625--500 micromolar) with four reactions each.
}
\source{
Reaction-level fluorescence measurements from Supplementary Data 4 of
Rapp, Bremer and Romero (2024), worksheet \code{Michaelis-Menten_data}.
The original workbook is available through the
\href{https://www.nature.com/articles/s44286-023-00002-4}{article's supplementary files}.

The source package includes:
\itemize{
  \item \file{inst/extdata/sdl_fluorescence_raw.csv}: fluorescence traces.
  \item \file{inst/data-preparation/prepare_sdl_demo.R}: preparation helper.
  \item \file{inst/data-raw/README.md}: regeneration instructions.
}
}
\references{
Rapp, J. T., Bremer, B. J., and Romero, P. A. (2024).
Self-driving laboratories to autonomously navigate the protein fitness landscape.
\emph{Nature Chemical Engineering}, \bold{1}, 97--107.

\doi{10.1038/s44286-023-00002-4}.
}
\details{
Rates are slopes fitted to the first three recorded times, converted with
794.64 RFU per micromolar and expressed per second or minute. Version 0.1.2
restores the 24 lowest-concentration reactions omitted in earlier demo data.
The ordinal \code{replicate} does not establish independent biological samples
or identify dependence across concentrations. Separate single-curve analysis
uses conditional independence of reaction errors; shared sample, batch or
calibration uncertainty is not automatically estimated.
}
\examples{
head(sdl_demo)
table(sdl_demo$enzyme)
}
