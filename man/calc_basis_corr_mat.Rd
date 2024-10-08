% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/basis_set.R
\name{calc_basis_corr_mat}
\alias{calc_basis_corr_mat}
\title{Estimate the correlation matrix for a basis set.}
\usage{
calc_basis_corr_mat(basis, xlim = c(4, 0.2), zf = TRUE)
}
\arguments{
\item{basis}{basis_set object.}

\item{xlim}{spectral range to use in ppm.}

\item{zf}{zero-fill the basis set.}
}
\value{
correlation matrix.
}
\description{
Estimate the correlation matrix for a basis set.
}
