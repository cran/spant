## ----include = FALSE----------------------------------------------------------
library(ragg)
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 6,
  fig.height = 5,
  dev = "ragg_png"
)

## ----message = FALSE----------------------------------------------------------
library(spant)

## -----------------------------------------------------------------------------
fname <- system.file("extdata", "philips_spar_sdat_WS.SDAT", package = "spant")

## -----------------------------------------------------------------------------
mrs_data <- read_mrs(fname)

## -----------------------------------------------------------------------------
print(mrs_data)

## -----------------------------------------------------------------------------
plot(mrs_data, xlim = c(5, 0.5))

## -----------------------------------------------------------------------------
mrs_proc <- hsvd_filt(mrs_data)
mrs_proc <- align(mrs_proc, 2.01)
plot(mrs_proc, xlim = c(5, 0.5))

## ----fig.height=9-------------------------------------------------------------
basis <- sim_basis_1h_brain_press(mrs_proc)
print(basis)
stackplot(basis, xlim = c(4, 0.5), labels = basis$names, y_offset = 5)

## ----results = "hide"---------------------------------------------------------
fit_res <- fit_mrs(mrs_proc, basis)

## -----------------------------------------------------------------------------
plot(fit_res)

## -----------------------------------------------------------------------------
fit_res$res_tab

## -----------------------------------------------------------------------------
fit_res$res_tab$tNAA.sd / fit_res$res_tab$tNAA * 100

## -----------------------------------------------------------------------------
fit_res$res_tab$SNR

## -----------------------------------------------------------------------------
fit_res$res_tab$tNAA_lw

## -----------------------------------------------------------------------------
fit_res_tcr_sc <- scale_amp_ratio(fit_res, "tCr")
amps <- fit_amps(fit_res_tcr_sc)
print(t(amps))

## -----------------------------------------------------------------------------
fname_wref <- system.file("extdata", "philips_spar_sdat_W.SDAT", package = "spant")
mrs_data_wref <- read_mrs(fname_wref)

## -----------------------------------------------------------------------------
p_vols <- c(WM = 100, GM = 0, CSF = 0)
TE = 0.03
TR = 2
fit_res_molal <- scale_amp_molal_pvc(fit_res, mrs_data_wref, p_vols, TE, TR)
fit_res_molal$res_tab$tNAA

## -----------------------------------------------------------------------------
fit_res_molar <- scale_amp_molar(fit_res, mrs_data_wref)
fit_res_molar$res_tab$tNAA

