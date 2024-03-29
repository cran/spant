% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qm_simulation.R
\name{sim_basis}
\alias{sim_basis}
\title{Simulate a basis set object.}
\usage{
sim_basis(
  mol_list,
  pul_seq = seq_pulse_acquire,
  acq_paras = def_acq_paras(),
  xlim = NULL,
  verbose = FALSE,
  ...
)
}
\arguments{
\item{mol_list}{list of \code{mol_parameter} objects. Alternatively, a
character vector matching molecules may also be provided. Use the
get_mol_names function for a full list of molecules.}

\item{pul_seq}{pulse sequence function to use.}

\item{acq_paras}{list of acquisition parameters or an mrs_data object. See
\code{\link{def_acq_paras}}}

\item{xlim}{ppm range limiting signals to be simulated.}

\item{verbose}{output simulation progress and timings.}

\item{...}{extra parameters to pass to the pulse sequence function.}
}
\value{
basis object.
}
\description{
Simulate a basis set object.
}
