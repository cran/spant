% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mrs_data_proc.R
\name{align}
\alias{align}
\title{Align spectra to a reference frequency using a convolution based method.}
\usage{
align(
  mrs_data,
  ref_freq = 4.65,
  zf_factor = 2,
  lb = 2,
  max_shift = 20,
  ret_df = FALSE,
  mean_dyns = FALSE
)
}
\arguments{
\item{mrs_data}{data to be aligned.}

\item{ref_freq}{reference frequency in ppm units. More than one frequency
may be specified.}

\item{zf_factor}{zero filling factor to increase alignment resolution.}

\item{lb}{line broadening to apply to the reference signal.}

\item{max_shift}{maximum allowable shift in Hz.}

\item{ret_df}{return frequency shifts in addition to aligned data (logical).}

\item{mean_dyns}{align the mean spectrum and apply the same shift to each
dyanmic.}
}
\value{
aligned data object.
}
\description{
Align spectra to a reference frequency using a convolution based method.
}
