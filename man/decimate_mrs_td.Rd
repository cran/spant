% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mrs_data_proc.R
\name{decimate_mrs_td}
\alias{decimate_mrs_td}
\title{Decimate an MRS signal by filtering in the time domain before downsampling.}
\usage{
decimate_mrs_td(mrs_data, q = 2, n = 4, ftype = "iir")
}
\arguments{
\item{mrs_data}{MRS data object.}

\item{q}{integer factor to downsample by (default = 2).}

\item{n}{filter order used in the downsampling.}

\item{ftype}{filter type, "iir" or "fir".}
}
\value{
decimated data.
}
\description{
Decimate an MRS signal by filtering in the time domain before downsampling.
}
