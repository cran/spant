% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mrs_data_proc.R
\name{scale_mrs_amp}
\alias{scale_mrs_amp}
\title{Scale an mrs_data object by a scalar or vector or amplitudes.}
\usage{
scale_mrs_amp(mrs_data, amp)
}
\arguments{
\item{mrs_data}{data to be scaled.}

\item{amp}{multiplicative factor, must have length equal to 1 or
Nspec(mrs_data).}
}
\value{
mrs_data object multiplied by the amplitude scale factor.
}
\description{
Scale an mrs_data object by a scalar or vector or amplitudes.
}
