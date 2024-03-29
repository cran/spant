% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/basis_set.R
\name{make_basis_from_raw}
\alias{make_basis_from_raw}
\title{Make a basis-set object from a directory containing LCModel formatted RAW
files.}
\usage{
make_basis_from_raw(dir_path, ft, fs, ref)
}
\arguments{
\item{dir_path}{path to the directory containing LCModel RAW files. One file
per signal.}

\item{ft}{transmitter frequency in Hz.}

\item{fs}{sampling frequency in Hz.}

\item{ref}{reference value for ppm scale.}
}
\value{
a basis-set object.
}
\description{
Make a basis-set object from a directory containing LCModel formatted RAW
files.
}
