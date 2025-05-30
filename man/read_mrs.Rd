% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mrs_data_io.R
\name{read_mrs}
\alias{read_mrs}
\title{Read MRS data from the filesystem.}
\usage{
read_mrs(
  path,
  format = NULL,
  ft = NULL,
  fs = NULL,
  ref = NULL,
  n_ref_scans = NULL,
  full_fid = FALSE,
  omit_svs_ref_scans = TRUE,
  verbose = FALSE,
  extra = NULL,
  fid_filt_dist = NULL
)
}
\arguments{
\item{path}{file name or directory containing the MRS data.}

\item{format}{string describing the data format. Must be one of the
following : "spar_sdat", "rda", "dicom", "twix", "pfile", "list_data",
"paravis", "dpt", "lcm_raw", "rds", "nifti", "varian", "jmrui_txt". If not
specified, the format will be guessed from the filename extension, or will
be assumed to be a Siemens ima dynamic data if the path is a directory.}

\item{ft}{transmitter frequency in Hz (required for list_data format).}

\item{fs}{sampling frequency in Hz (required for list_data format).}

\item{ref}{reference value for ppm scale (required for list_data format).}

\item{n_ref_scans}{override the number of water reference scans detected in
the file header (GE p-file only).}

\item{full_fid}{export all data points, including those before the start
of the FID (default = FALSE), TWIX format only.}

\item{omit_svs_ref_scans}{remove any reference scans sometimes saved in
SVS twix data (default = TRUE).}

\item{verbose}{print data file information (default = FALSE).}

\item{extra}{an optional data frame to provide additional variables for use
in subsequent analysis steps, eg id or grouping variables.}

\item{fid_filt_dist}{indicate if the data has a distorted FID due to a
brick-wall filter being used to downsample the data. Default is to auto
detect this from the data, but TRUE or FALSE options can be given to override
detection.}
}
\value{
MRS data object.
}
\description{
Read MRS data from the filesystem.
}
\examples{
fname <- system.file("extdata", "philips_spar_sdat_WS.SDAT", package = "spant")
mrs_data <- read_mrs(fname)
print(mrs_data)
}
