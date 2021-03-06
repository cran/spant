% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{sim_brain_1h}
\alias{sim_brain_1h}
\title{Simulate MRS data with a similar appearance to normal brain (by default).}
\usage{
sim_brain_1h(
  acq_paras = def_acq_paras(),
  type = "normal_v1",
  pul_seq = seq_press_ideal,
  xlim = c(0.5, 4.2),
  full_output = FALSE,
  amps = NULL,
  ...
)
}
\arguments{
\item{acq_paras}{list of acquisition parameters or an mrs_data object. See
\code{\link{def_acq_paras}}.}

\item{type}{type of spectrum, only "normal" is implemented currently.}

\item{pul_seq}{pulse sequence function to use.}

\item{xlim}{range of frequencies to simulate in ppm.}

\item{full_output}{when FALSE (default) only output the simulated MRS data.
When TRUE output a list containing the MRS data, basis set object and
corresponding amplitudes.}

\item{amps}{a vector of basis amplitudes may be specified to modify the
output spectrum.}

\item{...}{extra parameters to pass to the pulse sequence function.}
}
\value{
see full_output option.
}
\description{
Simulate MRS data with a similar appearance to normal brain (by default).
}
