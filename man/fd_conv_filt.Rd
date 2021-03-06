% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mrs_data_proc.R
\name{fd_conv_filt}
\alias{fd_conv_filt}
\title{Frequency-domain convolution based filter.}
\usage{
fd_conv_filt(mrs_data, K = 25, ext = 1)
}
\arguments{
\item{mrs_data}{MRS data to be filtered.}

\item{K}{window width in data points.}

\item{ext}{point separation for linear extrapolation.}
}
\description{
Frequency-domain convolution based filter.
}
