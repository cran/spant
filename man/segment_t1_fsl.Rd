% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{segment_t1_fsl}
\alias{segment_t1_fsl}
\title{Segment T1 weighted MRI data using FSL FAST and write to file. Runs deface
and bet as preprocessing steps by default.}
\usage{
segment_t1_fsl(mri_path, deface = TRUE, bet_fit = 0.5)
}
\arguments{
\item{mri_path}{path to the volumetric T1 data.}

\item{deface}{deface the input T1 data before analysis. Defaults to TRUE.}

\item{bet_fit}{fractional intensity threshold for bet brain extraction.
Values should be between 0 and 1. Defaults to 0.5 with smaller values giving
larger brain estimates.}
}
\description{
This function requires a working installation of FSL and uses the fslr
package. You may need to specify the fsl install directory, eg:
'options(fsl.path = "/path/to/fsl")'
}
