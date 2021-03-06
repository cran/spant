% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mrs_data_proc.R
\name{set_lw}
\alias{set_lw}
\title{Apply line-broadening to an mrs_data object to achieve a specified linewidth.}
\usage{
set_lw(mrs_data, lw, xlim = c(4, 0.5))
}
\arguments{
\item{mrs_data}{data in.}

\item{lw}{target linewidth in units of ppm.}

\item{xlim}{region to search for peaks to obtain a linewidth estimate.}
}
\value{
line-broadened data.
}
\description{
Apply line-broadening to an mrs_data object to achieve a specified linewidth.
}
