## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 6,
  fig.height = 5
)

## ----setup, message = FALSE---------------------------------------------------
library(spant)

## ----read_data----------------------------------------------------------------
fname    <- system.file("extdata", "philips_spar_sdat_WS.SDAT", package = "spant")
mrs_data <- read_mrs(fname, format = "spar_sdat")
basis    <- sim_basis_1h_brain_press(mrs_data)

## ----abfit_default, results = "hide"------------------------------------------
fit_res <- fit_mrs(mrs_data, basis)
plot(fit_res)

## ----abfit_bl_value-----------------------------------------------------------
fit_res$res_tab$bl_ed_pppm

## ----abfit_flex, results = "hide"---------------------------------------------
opts    <- abfit_opts(auto_bl_flex = FALSE, bl_ed_pppm = 8)
fit_res <- fit_mrs(mrs_data, basis, opts = opts)
plot(fit_res)

## ----abfit_stiff, results = "hide"--------------------------------------------
opts    <- abfit_opts(auto_bl_flex = FALSE, bl_ed_pppm = 1)
fit_res <- fit_mrs(mrs_data, basis, opts = opts)
plot(fit_res)

## ----abfit_aic, results = "hide"----------------------------------------------
opts    <- abfit_opts(aic_smoothing_factor = 1)
fit_res <- fit_mrs(mrs_data, basis, opts = opts)
plot(fit_res)

## ----abfit_bspline, results = "hide"------------------------------------------
opts    <- abfit_opts(export_sp_fit = TRUE)
fit_res <- fit_mrs(mrs_data, basis, opts = opts)
stackplot(fit_res, omit_signals = basis$names)

## ----abfit_bspline_more, results = "hide"-------------------------------------
opts    <- abfit_opts(export_sp_fit = TRUE, bl_comps_pppm = 25)
fit_res <- fit_mrs(mrs_data, basis, opts = opts)
stackplot(fit_res, omit_signals = basis$names)

## ----abfit_bl_value_more_splines----------------------------------------------
fit_res$res_tab$bl_ed_pppm

