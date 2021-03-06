% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mrs_data_io.R
\name{read_mrs_tqn}
\alias{read_mrs_tqn}
\title{Read MRS data using the TARQUIN software package.}
\usage{
read_mrs_tqn(fname, fname_ref = NA, format, id = NA, group = NA)
}
\arguments{
\item{fname}{the filename containing the MRS data.}

\item{fname_ref}{a second filename containing reference MRS data.}

\item{format}{format of the MRS data. Can be one of the following:
siemens, philips, ge, dcm, dpt, rda, lcm, varian, bruker, jmrui_txt.}

\item{id}{optional ID string.}

\item{group}{optional group string.}
}
\value{
MRS data object.
}
\description{
Read MRS data using the TARQUIN software package.
}
\examples{
fname <- system.file("extdata","philips_spar_sdat_WS.SDAT",package="spant")
\dontrun{
mrs_data <- read_mrs_tqn(fname, format="philips")
}
}
