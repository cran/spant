% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/amp_scaling.R
\name{apply_pvc}
\alias{apply_pvc}
\title{Convert default LCM/TARQUIN concentration scaling to molal units with partial
volume correction.}
\usage{
apply_pvc(fit_result, p_vols, te, tr)
}
\arguments{
\item{fit_result}{a \code{fit_result} object to apply partial volume
correction.}

\item{p_vols}{a numeric vector of partial volumes.}

\item{te}{the MRS TE.}

\item{tr}{the MRS TR.}
}
\value{
a \code{fit_result} object with a rescaled results table.
}
\description{
Convert default LCM/TARQUIN concentration scaling to molal units with partial
volume correction.
}
