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

## ----message = FALSE----------------------------------------------------------
get_mol_names()

## ----message = FALSE----------------------------------------------------------
ins <- get_mol_paras("ins")
print(ins)

## ----message = FALSE----------------------------------------------------------
sim_mol(ins, ft = 300e6, N = 4096) |> lb(2) |> plot(xlim = c(3.8, 3.1))

## ----message = FALSE----------------------------------------------------------
ins_sim <- sim_mol(ins, seq_spin_echo_ideal, ft = 300e6, N = 4086, TE = 0.03)
ins_sim |> lb(2) |> plot(xlim = c(3.8, 3.1))

## ----message = FALSE, fig.height = 8------------------------------------------
sim_fn <- function(TE) {
  te_sim <- sim_mol(ins, seq_spin_echo_ideal, ft = 300e6, N = 4086, TE = TE)
  lb(te_sim, 2)
}

te_vals <- seq(0, 2, 0.4)

lapply(te_vals, sim_fn) |> stackplot(y_offset = 150, xlim = c(3.8, 3.1),
                                     labels = paste(te_vals * 100, "ms"))

## ----message = FALSE----------------------------------------------------------
get_uncoupled_mol("Lip13", c(1.3, 1.4), c("1H", "1H"), c(2, 1), c(10, 10),
                  c(1, 1)) |> sim_mol() |> plot(xlim = c(2, 0.8))

## ----message = FALSE----------------------------------------------------------
nucleus_a <- rep("1H", 4)

chem_shift_a <- c(4.0974, 1.3142, 1.3142, 1.3142)

j_coupling_mat_a <- matrix(0, 4, 4)
j_coupling_mat_a[2,1] <- 6.933
j_coupling_mat_a[3,1] <- 6.933
j_coupling_mat_a[4,1] <- 6.933

spin_group_a <- list(nucleus = nucleus_a, chem_shift = chem_shift_a, 
                     j_coupling_mat = j_coupling_mat_a, scale_factor = 1,
                     lw = 2, lg = 0)

nucleus_b <- c("1H")
chem_shift_b <- c(2.5)
j_coupling_mat_b <- matrix(0, 1, 1)

spin_group_b <- list(nucleus = nucleus_b, chem_shift = chem_shift_b, 
                     j_coupling_mat = j_coupling_mat_b, scale_factor = 3,
                     lw = 2, lg = 0)

source <- "This text should include a reference on the origin of the chemical shift and j-coupling values."

custom_mol <- list(spin_groups = list(spin_group_a, spin_group_b), name = "Cus",
              source = source, full_name = "Custom molecule")

class(custom_mol) <- "mol_parameters"

## ----message = FALSE----------------------------------------------------------
print(custom_mol)
custom_mol |> sim_mol() |> lb(2) |> zf() |> plot(xlim = c(4.4, 0.5))

