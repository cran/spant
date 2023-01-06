## ---- include = FALSE---------------------------------------------------------
library(ragg)
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 6,
  fig.height = 5,
  dev = "ragg_png"
)

## ---- message = FALSE---------------------------------------------------------
library(spant)

## -----------------------------------------------------------------------------
fname <- system.file("extdata", "philips_spar_sdat_WS.SDAT", package = "spant")
mrs_data <- read_mrs(fname, format = "spar_sdat")

## -----------------------------------------------------------------------------
plot(mrs_data, xlim = c(4, 0.5))

## -----------------------------------------------------------------------------
mrs_data_p180 <- phase(mrs_data, 180)
plot(mrs_data_p180, xlim = c(4, 0.5))

## -----------------------------------------------------------------------------
mrs_data_lb <- lb(mrs_data, 3)
plot(mrs_data_lb, xlim = c(4, 0.5))

## -----------------------------------------------------------------------------
mrs_data_zf <- zf(mrs_data, 2)
plot(mrs_data_zf, xlim = c(4, 0.5))

## -----------------------------------------------------------------------------
mrs_data_filt <- hsvd_filt(mrs_data)
stackplot(list(mrs_data, mrs_data_filt), xlim = c(5, 0.5), y_offset = 10,
          col = c("black", "red"), labels = c("original", "filtered"))

## -----------------------------------------------------------------------------
mrs_data_shift <- shift(mrs_data, 0.1, "ppm")
stackplot(list(mrs_data, mrs_data_shift), xlim = c(4, 0.5), y_offset = 10,
          col = c("black", "red"), labels = c("original", "shifted"))

## -----------------------------------------------------------------------------
mrs_data_proc <- mrs_data |> hsvd_filt() |> lb(2) |> zf()
plot(mrs_data_proc, xlim = c(5, 0.5))

