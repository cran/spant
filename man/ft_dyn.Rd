% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mrs_data_proc.R
\name{ft_dyn}
\alias{ft_dyn}
\title{Apply the Fourier transform over the dynamic dimension.}
\usage{
ft_dyn(mrs_data, ft_shift = FALSE)
}
\arguments{
\item{mrs_data}{MRS data where the dynamic dimension is in the time-domain.}

\item{ft_shift}{apply FT shift to the output, default is FALSE.}
}
\value{
transformed MRS data.
}
\description{
Apply the Fourier transform over the dynamic dimension.
}
