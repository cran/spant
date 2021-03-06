% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mrs_data_proc.R
\name{calc_spec_snr}
\alias{calc_spec_snr}
\title{Calculate the spectral SNR.}
\usage{
calc_spec_snr(
  mrs_data,
  sig_region = c(4, 0.5),
  noise_region = c(-0.5, -2.5),
  p_order = 2,
  interp_f = 4,
  full_output = FALSE
)
}
\arguments{
\item{mrs_data}{an object of class \code{mrs_data}.}

\item{sig_region}{a ppm region to define where the maximum signal value
should be estimated.}

\item{noise_region}{a ppm region to defined where the noise level should be
estimated.}

\item{p_order}{polynomial order to fit to the noise region before estimating
the standard deviation.}

\item{interp_f}{interpolation factor to improve detection of the highest
signal value.}

\item{full_output}{output signal, noise and SNR values separately.}
}
\value{
an array of SNR values.
}
\description{
SNR is defined as the maximum signal value divided by the standard deviation
of the noise.
}
\details{
The mean noise value is subtracted from the maximum signal value to reduce DC
offset bias. A polynomial detrending fit (second order by default) is applied
to the noise region before the noise standard deviation is estimated.
}
