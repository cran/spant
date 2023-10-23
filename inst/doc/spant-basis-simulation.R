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
mol_list <- list(get_mol_paras("lac"),
                 get_mol_paras("naa"),
                 get_mol_paras("cr"),
                 get_mol_paras("gpc"))

## -----------------------------------------------------------------------------
basis <- sim_basis(mol_list, pul_seq = seq_slaser_ideal,
                   acq_paras = def_acq_paras(N = 2048, fs = 2000, ft = 127.8e6),
                   TE1 = 0.008, TE2 = 0.011, TE3 = 0.009)

stackplot(basis, xlim = c(4, 0.5), y_offset = 50, labels = basis$names)

## -----------------------------------------------------------------------------
mol_list_mm <- append(mol_list, list(get_mol_paras("MM09", ft = 127.8e6)))

basis_mm <- sim_basis(mol_list_mm, pul_seq = seq_slaser_ideal,
                   acq_paras = def_acq_paras(N = 2048, fs = 2000, ft = 127.8e6),
                   TE1 = 0.008, TE2 = 0.011, TE3 = 0.009)

stackplot(basis_mm, xlim = c(4, 0.5), y_offset = 50, labels = basis_mm$names)

## -----------------------------------------------------------------------------
basis <- sim_basis_1h_brain()
stackplot(basis, xlim = c(4, 0.5), y_offset = 20, labels = basis$names)

## -----------------------------------------------------------------------------
lcm_basis <- sim_basis_1h_brain()
stackplot(lcm_basis, xlim = c(4, 0.5), y_offset = 20, labels = basis$names)

