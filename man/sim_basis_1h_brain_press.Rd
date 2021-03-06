% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qm_simulation.R
\name{sim_basis_1h_brain_press}
\alias{sim_basis_1h_brain_press}
\title{Simulate a basis-set suitable for 1H brain MRS analysis acquired with a PRESS
sequence. Note, ideal pulses are assumed.}
\usage{
sim_basis_1h_brain_press(
  acq_paras = def_acq_paras(),
  xlim = c(0.5, 4.2),
  lcm_compat = FALSE,
  TE1 = 0.01,
  TE2 = 0.02
)
}
\arguments{
\item{acq_paras}{list of acquisition parameters or an mrs_data object. See
\code{\link{def_acq_paras}}}

\item{xlim}{range of frequencies to simulate in ppm.}

\item{lcm_compat}{exclude lipid and MM signals for use with default LCModel
options.}

\item{TE1}{TE1 of PRESS sequence (TE = TE1 + TE2).}

\item{TE2}{TE2 of PRESS sequence.}
}
\value{
basis object.
}
\description{
Simulate a basis-set suitable for 1H brain MRS analysis acquired with a PRESS
sequence. Note, ideal pulses are assumed.
}
