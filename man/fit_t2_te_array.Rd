% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/relaxation_fitting.R
\name{fit_t2_te_array}
\alias{fit_t2_te_array}
\title{Fit a T2 relaxation curve, from multiple TEs, to a set of amplitudes.}
\usage{
fit_t2_te_array(
  te_vec,
  amp_vec,
  lower = 0,
  upper = 10,
  output_fit_res = 0.01,
  ret_full = TRUE
)
}
\arguments{
\item{te_vec}{vector of TE values in seconds.}

\item{amp_vec}{vector of amplitudes.}

\item{lower}{minimum allowable T2 value.}

\item{upper}{maximum allowable T2 value.}

\item{output_fit_res}{temporal resolution (seconds) of the ideal output
relaxation curve.}

\item{ret_full}{return full fitting information including ideal relaxation
curve.}
}
\value{
a list containing relaxation parameters and an ideal curve for fit
evaluation.
}
\description{
Fit a T2 relaxation curve, from multiple TEs, to a set of amplitudes.
}
