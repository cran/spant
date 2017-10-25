% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/varpro_3_para.R
\name{varpro_3_para_opts}
\alias{varpro_3_para_opts}
\title{Return a list of options for VARPRO based fitting with 3 free parameters:
\itemize{
\item zero'th order phase correction
\item global damping
\item global frequency shift.
}}
\usage{
varpro_3_para_opts(nstart = 20, init_damping = 2, maxiters = 200,
  max_shift = 5, max_damping = 5, anal_jac = FALSE, bl_smth_pts = 80)
}
\arguments{
\item{nstart}{Position in the time-domain to start fitting, units of data
points.}

\item{init_damping}{Starting value for the global Gaussian line-broadening
term - measured in Hz.}

\item{maxiters}{Maximum number of levmar iterations to perform.}

\item{max_shift}{Maximum global shift allowed, measured in Hz.}

\item{max_damping}{Maximum damping allowed, FWHM measured in Hz.}

\item{anal_jac}{Option to use the analytic or numerical Jacobian (logical).}

\item{bl_smth_pts}{Number of data points to use in the baseline smoothing
calculation.}
}
\value{
List of options.
}
\description{
Return a list of options for VARPRO based fitting with 3 free parameters:
\itemize{
\item zero'th order phase correction
\item global damping
\item global frequency shift.
}
}