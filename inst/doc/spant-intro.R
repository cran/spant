## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 6,
  fig.height = 5
)

## ---- message = FALSE---------------------------------------------------------
library(spant)

## -----------------------------------------------------------------------------
fname <- system.file("extdata", "philips_spar_sdat_WS.SDAT", package = "spant")

## -----------------------------------------------------------------------------
mrs_data <- read_mrs(fname, format = "spar_sdat")

## -----------------------------------------------------------------------------
print(mrs_data)

## -----------------------------------------------------------------------------
plot(mrs_data, xlim = c(5, 0.5))

## -----------------------------------------------------------------------------
mrs_proc <- hsvd_filt(mrs_data)
mrs_proc <- align(mrs_proc, 2.01)
plot(mrs_proc, xlim = c(5, 0.5))

## ---- fig.height=9------------------------------------------------------------
basis <- sim_basis_1h_brain_press(mrs_proc)
print(basis)
stackplot(basis, xlim = c(4, 0.5), labels = basis$names, y_offset = 5)

## ---- results = "hide"--------------------------------------------------------
fit_res <- fit_mrs(mrs_proc, basis)

## -----------------------------------------------------------------------------
plot(fit_res)

## -----------------------------------------------------------------------------
amps <- fit_amps(fit_res)
print(t(amps / amps$tCr))

