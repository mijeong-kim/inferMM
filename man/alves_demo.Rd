\name{alves_demo}
\alias{alves_demo}
\title{Subset of the Alves Soil Enzyme Kinetics Data}
\format{
A data frame with 247 rows and 6 variables:
\describe{
  \item{\code{core}}{Soil core identifier (Core1--Core3).}
  \item{\code{depth}}{Soil depth interval in centimetres.}
  \item{\code{enzyme}}{Enzyme code: AP, BG, or LAP.}
  \item{\code{temperature}}{Incubation temperature in degrees Celsius.}
  \item{\code{substrate_conc}}{Substrate concentration in micromolar units.}
  \item{\code{activity}}{Enzyme activity in nanomoles per gram of dry soil per hour.}
}
}
\description{
A filtered subset of the Alves et al. soil exoenzyme kinetics data, restricted
to depth \code{00-10} and temperature \code{10} for fast reproducible package
examples.
}
\source{
Corrected soil exoenzyme activity measurements accompanying Alves et al.
(2021; see References). Raw and processed study data and R code are provided
in the article's Supplementary Material, Data Sheet 2 (ZIP):
\href{https://pmc.ncbi.nlm.nih.gov/articles/instance/8669745/bin/Data_Sheet_2.zip}{supplementary data archive}.
The corrected activity table is \file{enzymeActivity_corr.csv}, in the nested
\file{enzymes_dataProcessed.zip} archive.
\href{https://www.frontiersin.org/journals/microbiology/articles/10.3389/fmicb.2021.735282/full}{Original article}.
}
\details{
This prepared demonstration subset retains depth \code{00-10}
(0--10 cm), temperature \code{10} (10 degrees Celsius), and rows with
positive, non-missing substrate concentration and activity. It contains
three soil cores and the enzymes AP, BG, and LAP, and is not the complete
study dataset. The column \code{core} preserves the original soil-core
identifier for clustered analyses.
}
\references{
Alves, R. J. E., Callejas, I. A., Marschmann, G. L., Mooshammer, M.,
Singh, H. W., Whitney, B., Torn, M. S., and Brodie, E. L. (2021).
Kinetic Properties of Microbial Exoenzymes Vary With Soil Depth but Have
Similar Temperature Sensitivities Through the Soil Profile.
\emph{Frontiers in Microbiology}, \bold{12}, 735282.

\doi{10.3389/fmicb.2021.735282}.
}
\examples{
head(alves_demo)
table(alves_demo$enzyme)
}
