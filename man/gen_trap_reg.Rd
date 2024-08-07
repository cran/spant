% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fmrs.R
\name{gen_trap_reg}
\alias{gen_trap_reg}
\title{Generate trapezoidal regressors.}
\usage{
gen_trap_reg(
  onset,
  duration,
  trial_type = NULL,
  mrs_data = NULL,
  tr = NULL,
  Ndyns = NULL,
  Ntrans = NULL,
  rise_t = 0,
  fall_t = 0,
  exp_fall = FALSE,
  exp_fall_power = 1,
  smo_sigma = NULL,
  match_tr = TRUE,
  dt = 0.01,
  normalise = FALSE
)
}
\arguments{
\item{onset}{stimulus onset in seconds.}

\item{duration}{stimulus duration in seconds.}

\item{trial_type}{string label for the stimulus.}

\item{mrs_data}{mrs_data object for timing information.}

\item{tr}{repetition time.}

\item{Ndyns}{number of dynamic scans stored, potentially less than Ntrans
if block averaging has been performed.}

\item{Ntrans}{number of dynamic scans acquired.}

\item{rise_t}{time to reach a plateau from baseline in seconds.}

\item{fall_t}{time to fall from plateau level back to baseline in seconds.}

\item{exp_fall}{model an exponential fall instead of linear.}

\item{exp_fall_power}{exponential fall power.}

\item{smo_sigma}{standard deviation of Gaussian smoothing kernel in seconds.
Set to NULL to disable (default behavior).}

\item{match_tr}{match the output to the input mrs_data.}

\item{dt}{timing resolution for internal calculations.}

\item{normalise}{normalise the response function to have a maximum value of
one.}
}
\value{
trapezoidal regressor data frame.
}
\description{
Generate trapezoidal regressors.
}
