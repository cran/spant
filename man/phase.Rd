% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mrs_data_proc.R
\name{phase}
\alias{phase}
\title{Apply phasing parameters to MRS data.}
\usage{
phase(mrs_data, zero_order, first_order = 0)
}
\arguments{
\item{mrs_data}{MRS data.}

\item{zero_order}{zero'th order phase term in degrees.}

\item{first_order}{first order (frequency dependent) phase term in ms.}
}
\value{
MRS data with applied phase parameters.
}
\description{
Apply phasing parameters to MRS data.
}
