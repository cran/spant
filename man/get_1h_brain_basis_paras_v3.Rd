% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qm_simulation.R
\name{get_1h_brain_basis_paras_v3}
\alias{get_1h_brain_basis_paras_v3}
\title{Return a list of \code{mol_parameter} objects suitable for 1H brain MRS
analyses.}
\usage{
get_1h_brain_basis_paras_v3(ft, metab_lw = NULL, lcm_compat = FALSE)
}
\arguments{
\item{ft}{transmitter frequency in Hz.}

\item{metab_lw}{linewidth of metabolite signals (Hz).}

\item{lcm_compat}{when TRUE, lipid, MM and -CrCH molecules will be excluded
from the output.}
}
\value{
list of \code{mol_parameter} objects.
}
\description{
Return a list of \code{mol_parameter} objects suitable for 1H brain MRS
analyses.
}
