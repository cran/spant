% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cli_utils.R
\name{install_cli}
\alias{install_cli}
\title{Install the spant command-line interface scripts to a system path.}
\usage{
install_cli(path = NULL)
}
\arguments{
\item{path}{optional path to install the scripts. Defaults to :
"/usr/local/bin".}
}
\description{
This should be run following each new install of spant to ensure consistency.
Typical command line usage : sudo Rscript -e "spant::install_cli()"
}
