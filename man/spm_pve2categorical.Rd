% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/image_reg.R
\name{spm_pve2categorical}
\alias{spm_pve2categorical}
\title{Convert SPM style segmentation files to a single categorical image where
the numerical values map as: 0) Other, 1) CSF, 2) GM and 3) WM.}
\usage{
spm_pve2categorical(fname)
}
\arguments{
\item{fname}{any of the segmentation files (eg c1_MY_T1.nii).}
}
\value{
nifti object.
}
\description{
Convert SPM style segmentation files to a single categorical image where
the numerical values map as: 0) Other, 1) CSF, 2) GM and 3) WM.
}
