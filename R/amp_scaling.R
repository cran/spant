#' Apply water reference scaling to a fitting results object to yield metabolite 
#' quantities in millimolar (mM) units (mol / kg of tissue water).
#'
#' Details of this method can be found in "Use of tissue water as a
#' concentration reference for proton spectroscopic imaging" by Gasparovic et al
#' MRM 2006 55(6):1219-26. 1.5 Tesla relaxation assumptions are taken from this
#' paper. For 3 Tesla data, relaxation assumptions are taken from "NMR 
#' relaxation times in the human brain at 3.0 Tesla" by Wansapura et al J Magn
#' Reson Imaging 1999 9(4):531-8. 
#' 
#' @param fit_result result object generated from fitting.
#' @param ref_data water reference MRS data object.
#' @param p_vols a numeric vector of partial volumes expressed as percentages.
#' For example, a voxel containing 100% white matter tissue would use : 
#' p_vols = c(WM = 100, GM = 0, CSF = 0).
#' @param te the MRS TE in seconds.
#' @param tr the MRS TR in seconds.
#' @param ... additional arguments to get_td_amp function.
#' @return A \code{fit_result} object with a rescaled results table.
#' @export
scale_amp_molal_pvc <- function(fit_result, ref_data, p_vols, te, tr, ...){
  
  # if (!identical(dim(fit_result$data$data)[2:6], dim(ref_data$data)[2:6])) {
  #   stop("Mismatch between fit result and reference data dimensions.")
  # }
  
  # check if res_tab_unscaled exists, and if not create it
  if (is.null(fit_result$res_tab_unscaled)) {
    fit_result$res_tab_unscaled <- fit_result$res_tab
  } else {
    fit_result$res_tab <- fit_result$res_tab_unscaled
  }
  
  B0 <- round(fit_result$data$ft / 42.58e6, 1)
  corr_factor <- get_corr_factor(te, tr, B0, p_vols[["GM"]], p_vols[["WM"]],
                                 p_vols[["CSF"]])
  
  amp_cols <- fit_result$amp_cols
  
  w_amp <- as.numeric(get_td_amp(ref_data, ...))
  
  # if there is only one water ref amp, extend if needed, eg for fMRS
  if ((length(w_amp) == 1) & (nrow(fit_result$res_tab) > 1)) {
    w_amp <- rep(w_amp, nrow(fit_result$res_tab)) 
  }
  
  if (length(w_amp) != nrow(fit_result$res_tab)) {
    stop("Mismatch between fit result and reference data.")
  }
  
  fit_result$res_tab$w_amp <- w_amp
  
  fit_result$res_tab <- append_p_vols(fit_result$res_tab, p_vols)
  
  # fit_result$res_tab$GM_vol    <- p_vols[["GM"]]
  # fit_result$res_tab$WM_vol    <- p_vols[["WM"]]
  # fit_result$res_tab$CSF_vol   <- p_vols[["CSF"]]
  # if ("Other" %in% names(p_vols)) {
  #   fit_result$res_tab$Other_vol <- p_vols[["Other"]]
  # }
  # fit_result$res_tab$GM_frac   <- p_vols[["GM"]] / 
  #                                (p_vols[["GM"]] + p_vols[["WM"]])
  
  fit_result$res_tab_unscaled <- append_p_vols(fit_result$res_tab_unscaled,
                                               p_vols)
  
  # fit_result$res_tab_unscaled$GM_vol    <- p_vols[["GM"]]
  # fit_result$res_tab_unscaled$WM_vol    <- p_vols[["WM"]]
  # fit_result$res_tab_unscaled$CSF_vol   <- p_vols[["CSF"]]
  # if ("Other" %in% names(p_vols)) {
  #   fit_result$res_tab_unscaled$Other_vol <- p_vols[["Other"]]
  # }
  # fit_result$res_tab_unscaled$GM_frac   <- p_vols[["GM"]] / 
  #                                         (p_vols[["GM"]] + p_vols[["WM"]])
  
  # append tables with %GM, %WM, %CSF and %Other
  pvc_cols <- 6:(5 + amp_cols * 2)
  fit_result$res_tab[, pvc_cols] <- fit_result$res_tab[, pvc_cols] *
                                    corr_factor / w_amp
  
  return(fit_result)
}

# append the p_vol coloumns to a results table
append_p_vols <- function(res_tab, p_vols) {
  
  res_tab$GM_vol    <- p_vols[["GM"]]
  res_tab$WM_vol    <- p_vols[["WM"]]
  res_tab$CSF_vol   <- p_vols[["CSF"]]
  if ("Other" %in% names(p_vols)) res_tab$Other_vol <- p_vols[["Other"]]
  res_tab$GM_frac   <- p_vols[["GM"]] / (p_vols[["GM"]] + p_vols[["WM"]])
  
  return(res_tab)
}

#' Apply water reference scaling to a fitting results object to yield metabolite 
#' quantities in millimolar (mM) units (mol / kg of tissue water).
#' 
#' Note, this function assumes the volume contains a homogeneous voxel, eg pure
#' WM, GM or  CSF. Also note that in the case of a homogeneous voxel the
#' relative densities of MR-visible water (eg GM=0.78, WM=0.65, and CSF=0.97)
#' cancel out and don't need to be considered. Use scale_amp_molal_pvc for
#' volumes containing  multiple compartments. Details of this method can be
#' found in "Use of tissue water as a concentration reference for proton
#' spectroscopic imaging" by Gasparovic et al MRM 2006 55(6):1219-26.
#' 
#' @param fit_result result object generated from fitting.
#' @param ref_data water reference MRS data object.
#' @param te the MRS TE in seconds.
#' @param tr the MRS TR in seconds.
#' @param water_t1 assumed water T1 value.
#' @param water_t2 assumed water T2 value.
#' @param metab_t1 assumed metabolite T1 value.
#' @param metab_t2 assumed metabolite T2 value.
#' @param ... additional arguments to get_td_amp function.
#' @return A \code{fit_result} object with a rescaled results table.
#' @export
scale_amp_molal <- function(fit_result, ref_data, te, tr, water_t1, water_t2,
                            metab_t1, metab_t2, ...){
  
  # if (!identical(dim(fit_result$data$data)[2:6], dim(ref_data$data)[2:6])) {
  #   stop("Mismatch between fit result and reference data dimensions.")
  # }
  
  # check if res_tab_unscaled exists, and if not create it
  if (is.null(fit_result$res_tab_unscaled)) {
    fit_result$res_tab_unscaled <- fit_result$res_tab
  } else {
    fit_result$res_tab <- fit_result$res_tab_unscaled
  }
  
  R_water   <- exp(-te / water_t2) * (1.0 - exp(-tr / water_t1))
  R_metab   <- exp(-te / metab_t2) * (1.0 - exp(-tr / metab_t1))
  
  water_conc <- 55510.0
  
  corr_factor <- R_water / R_metab * water_conc
  
  amp_cols <- fit_result$amp_cols
  
  w_amp <- as.numeric(get_td_amp(ref_data, ...))
  
  # if there is only one water ref amp, extend if needed, eg for fMRS
  if ((length(w_amp) == 1) & (nrow(fit_result$res_tab) > 1)) {
    w_amp <- rep(w_amp, nrow(fit_result$res_tab)) 
  }
  
  if (length(w_amp) != nrow(fit_result$res_tab)) {
    stop("Mismatch between fit result and reference data.")
  }
  
  fit_result$res_tab$w_amp <- w_amp
  
  pvc_cols <- 6:(5 + amp_cols * 2)
  fit_result$res_tab[, pvc_cols] <- fit_result$res_tab[, pvc_cols] *
                                    corr_factor / w_amp
  
  return(fit_result)
}

#' Apply water reference scaling to a fitting results object to yield metabolite 
#' quantities in units of "mmol per Kg wet weight".
#' 
#' See the LCModel manual (section 10.2) on water-scaling for details on the
#' assumptions and relevant references. Use this type of concentration scaling
#' to compare fit results with LCModel and TARQUIN defaults. Otherwise
#' scale_amp_molal_pvc is the preferred method. Note, the LCModel manual 
#' (section 1.3) states: 
#' 
#' "Concentrations should be labelled 'mmol per Kg wet weight'. We use the
#' shorter (incorrect) abbreviation mM. The actual mM is the mmol per Kg wet
#' weight multiplied by the specific gravity of the tissue, typically 1.04 in 
#' brain."
#' 
#' @param fit_result a result object generated from fitting.
#' @param ref_data water reference MRS data object.
#' @param w_att water attenuation factor (default = 0.7). Assumes water T2 of
#' 80ms and a TE = 30 ms. exp(-30ms / 80ms) ~ 0.7.
#' @param w_conc assumed water concentration (default = 35880). Default value
#' corresponds to typical white matter. Set to 43300 for gray matter, and 55556 
#' for phantom measurements.
#' @param ... additional arguments to get_td_amp function.
#' @return a \code{fit_result} object with a rescaled results table.
#' @export
scale_amp_legacy <- function(fit_result, ref_data, w_att = 0.7, w_conc = 35880,
                                ...) {
  
  # check if res_tab_unscaled exists, and if not create it
  if (is.null(fit_result$res_tab_unscaled)) {
    fit_result$res_tab_unscaled <- fit_result$res_tab
  } else {
    fit_result$res_tab <- fit_result$res_tab_unscaled
  }
  
  w_amp <- as.numeric(get_td_amp(ref_data, ...))
  
  # if there is only one water ref amp, extend if needed, eg for fMRS
  if ((length(w_amp) == 1) & (nrow(fit_result$res_tab) > 1)) {
    w_amp <- rep(w_amp, nrow(fit_result$res_tab)) 
  }
  
  if (length(w_amp) != nrow(fit_result$res_tab)) {
    stop("Mismatch between fit result and reference data.")
  }
  
  fit_result$res_tab$w_amp <- w_amp
  
  amp_cols <- fit_result$amp_cols
  ws_cols <- 6:(5 + amp_cols * 2)
  
  fit_result$res_tab[, ws_cols] <- (fit_result$res_tab[, ws_cols] * w_att *
                                    w_conc / w_amp)
    
  fit_result
}
  
#' Apply water reference scaling to a fitting results object to yield metabolite 
#' quantities in millimolar (mM) units (mol / Litre of tissue). This function is
#' depreciated, please use scale_amp_legacy instead.
#' 
#' See the LCModel manual (section 10.2) on water-scaling for details on the
#' assumptions and relevant references. Use this type of concentration scaling
#' to compare fit results with LCModel and TARQUIN defaults. Otherwise
#' scale_amp_molal_pvc is generally the preferred method.
#' 
#' @param fit_result a result object generated from fitting.
#' @param ref_data water reference MRS data object.
#' @param w_att water attenuation factor (default = 0.7). Assumes water T2 of
#' 80ms and a TE = 30 ms. exp(-30ms / 80ms) ~ 0.7.
#' @param w_conc assumed water concentration (default = 35880). Default value
#' corresponds to typical white matter. Set to 43300 for gray matter, and 55556 
#' for phantom measurements.
#' @param ... additional arguments to get_td_amp function.
#' @return a \code{fit_result} object with a rescaled results table.
#' @export
scale_amp_molar <- function(fit_result, ref_data, w_att = 0.7, w_conc = 35880,
                            ...) {
  
  # if (!identical(dim(fit_result$data$data)[2:6], dim(ref_data$data)[2:6])) {
  #   stop("Mismatch between fit result and reference data dimensions.")
  # }
  
  warning("Function name (scale_amp_molar) is missleading and has been replaced with scale_amp_legacy.")
  
  # check if res_tab_unscaled exists, and if not create it
  if (is.null(fit_result$res_tab_unscaled)) {
    fit_result$res_tab_unscaled <- fit_result$res_tab
  } else {
    fit_result$res_tab <- fit_result$res_tab_unscaled
  }
  
  w_amp <- as.numeric(get_td_amp(ref_data, ...))
  
  # if there is only one water ref amp, extend if needed, eg for fMRS
  if ((length(w_amp) == 1) & (nrow(fit_result$res_tab) > 1)) {
    w_amp <- rep(w_amp, nrow(fit_result$res_tab)) 
  }
  
  if (length(w_amp) != nrow(fit_result$res_tab)) {
    stop("Mismatch between fit result and reference data.")
  }
  
  fit_result$res_tab$w_amp <- w_amp
  
  amp_cols <- fit_result$amp_cols
  ws_cols <- 6:(5 + amp_cols * 2)
  
  fit_result$res_tab[, ws_cols] <- (fit_result$res_tab[, ws_cols] * w_att *
                                    w_conc / w_amp)
    
  fit_result
}

#' Scale metabolite amplitudes as a ratio to the unsuppressed water amplitude.
#' @param fit_result a result object generated from fitting.
#' @param ref_data a water reference MRS data object.
#' @param ... additional arguments to get_td_amp function.
#' @return a \code{fit_result} object with a rescaled results table.
#' @export
scale_amp_water_ratio <- function(fit_result, ref_data, ...) {
  
  # if (!identical(dim(fit_result$data$data)[2:6], dim(ref_data$data)[2:6])) {
  #  stop("Mismatch between fit result and reference data dimensions.")
  # }
  
  # check if res_tab_unscaled exists, and if not create it
  if (is.null(fit_result$res_tab_unscaled)) {
    fit_result$res_tab_unscaled <- fit_result$res_tab
  } else {
    fit_result$res_tab <- fit_result$res_tab_unscaled
  }
  
  w_amp <- as.numeric(get_td_amp(ref_data, ...))
  
  if (length(w_amp) != nrow(fit_result$res_tab)) {
    stop("Mismatch between fit result and reference data.")
  }
  
  # if there is only one water ref amp, extend if needed, eg for fMRS
  if ((length(w_amp) == 1) & (nrow(fit_result$res_tab) > 1)) {
    w_amp <- rep(w_amp, nrow(fit_result$res_tab)) 
  }
  
  fit_result$res_tab$w_amp <- w_amp
  
  amp_cols <- fit_result$amp_cols
  ws_cols <- 6:(5 + amp_cols * 2)
  
  fit_result$res_tab[, ws_cols] <- fit_result$res_tab[, ws_cols] / w_amp
  
  fit_result
}

#' Scale fitted amplitudes to a ratio of signal amplitude.
#' @param fit_result a result object generated from fitting.
#' @param name the signal name to use as a denominator (usually, "tCr" or 
#' "tNAA").
#' @param use_mean_value scales the result by the mean of the signal when set to
#' TRUE.
#' @return a \code{fit_result} object with a rescaled results table.
#' @export
scale_amp_ratio <- function(fit_result, name, use_mean_value = FALSE) {
  
  if (!(name %in% colnames(fit_result$res_tab))) {
    print(name)
    print(colnames(fit_result$res_tab))
    stop("Ratio denominator not found.")
  }
  
  # check if res_tab_unscaled exists, and if not create it
  if (is.null(fit_result$res_tab_unscaled)) {
    fit_result$res_tab_unscaled <- fit_result$res_tab
  } else {
    fit_result$res_tab <- fit_result$res_tab_unscaled
  }
  
  ratio_amp <- as.numeric(fit_result$res_tab[[name]])
  
  if (use_mean_value) ratio_amp <- mean(ratio_amp)
  
  amp_cols <- fit_result$amp_cols
  ws_cols <- 6:(5 + amp_cols * 2)
  
  fit_result$res_tab[, ws_cols] <- fit_result$res_tab[, ws_cols] / ratio_amp
  
  fit_result
}

#' Scale fitted amplitudes to a ratio of signal amplitude.
#' @param fit_result a result object generated from fitting.
#' @param value the number use as a denominator.
#' @return a \code{fit_result} object with a rescaled results table.
#' @export
scale_amp_ratio_value <- function(fit_result, value) {
  
  # check if res_tab_unscaled exists, and if not create it
  if (is.null(fit_result$res_tab_unscaled)) {
    fit_result$res_tab_unscaled <- fit_result$res_tab
  } else {
    fit_result$res_tab <- fit_result$res_tab_unscaled
  }
  
  ratio_amp <- value
  
  amp_cols <- fit_result$amp_cols
  ws_cols <- 6:(5 + amp_cols * 2)
  
  fit_result$res_tab[, ws_cols] <- fit_result$res_tab[, ws_cols] / ratio_amp
  
  fit_result
}

get_corr_factor <- function(te, tr, B0, gm_vol, wm_vol, csf_vol) {
  # Correction factor calculated according to the method of Gasparovic et al
  # (MRM 55:1219-1226 2006)
  # see online docs for references to these numbers
  
  if (B0 == 1.5) {
    t1_gm    <- 1.304 # Gasparovic et al, page 1223
    t2_gm    <- 0.093 # Gasparovic et al, page 1223
    t1_wm    <- 0.660 # Gasparovic et al, page 1223
    t2_wm    <- 0.073 # Gasparovic et al, page 1223
    t1_csf   <- 2.39  # Ibrahim et al, Abstract
    t2_csf   <- 0.23  # Ibrahim et al, Abstract
    t1_metab <- 1.153 # Gasparovic et al, page 1223
                      # (1.28+1.09+1.09)/3
    t2_metab <- 0.347 # Gasparovic et al, page 1223
                      # (0.34+0.35+0.35)/3
  } else if ((B0 == 3.0) | (B0 == 2.9)) {
    t1_gm    <- 1.331  # Wansapura et al, Table 7
    t2_gm    <- 0.110  # Wansapura et al, Table 2
    t1_wm    <- 0.832  # Wansapura et al, Table 7
    t2_wm    <- 0.0796 # Wansapura et al, Table 2
    t1_csf   <- 3.817  # Lu et at, Discussion
    t2_csf   <- 0.503  # Piechnik et al, Table 1
    t1_metab <- 1.317  # Mlynarik et al, Table 1 
                       # (1.47+1.46+1.30+1.35+1.24+1.08)/6
    t2_metab <- 0.207  # Mlynarik et al, Table 2
                       # (247+152+207+295+156+187)/6000
  } else if (B0 == 7.0) {
    t1_gm    <- 2.132 # Rooney et al, Table 1
    t2_gm    <- 0.050 # Bartha et al, Table 1, LASER
    t1_wm    <- 1.220 # Rooney et al, Table 1
    t2_wm    <- 0.055 # Bartha et al, Table 1, LASER
    t1_csf   <- 4.425 # Rooney et al, Table 1
    t2_csf   <- 1.050 # Spijkerman et al, supp. materials S3, 1x1x4
    t1_metab <- 1.583 # Li et al, Table 1
                      # (1.24+1.78+1.73)/3
    t2_metab <- 0.141 # Li et al, Table 1
                      # (131+121+170)/3000
  } else {
    warning("Error. Relaxation values not available for this field strength. Assuming values for 3 Telsa.")
  }
  
  # MR-visible water densities
  gm_vis  <- 0.78
  wm_vis  <- 0.65
  csf_vis <- 0.97
  
  # molal concentration (moles/gram) of MR-visible water
  water_conc <- 55510.0
  
  # fractions of water attributable to GM, WM and CSF
  f_gm  <- gm_vol * gm_vis / 
          (gm_vol * gm_vis + wm_vol * wm_vis + csf_vol * csf_vis)
  
  f_wm  <- wm_vol * wm_vis / 
          (gm_vol * gm_vis + wm_vol * wm_vis + csf_vol * csf_vis)
  
  f_csf <- csf_vol * csf_vis / 
          (gm_vol * gm_vis + wm_vol * wm_vis + csf_vol * csf_vis)
  
  # Relaxation attenuation factors
  R_h2o_gm  <- exp(-te / t2_gm)    * (1.0 - exp(-tr / t1_gm))
  R_h2o_wm  <- exp(-te / t2_wm)    * (1.0 - exp(-tr / t1_wm))
  R_h2o_csf <- exp(-te / t2_csf)   * (1.0 - exp(-tr / t1_csf))
  R_metab   <- exp(-te / t2_metab) * (1.0 - exp(-tr / t1_metab))
  
  corr_factor <- ((f_gm * R_h2o_gm + f_wm * R_h2o_wm + f_csf * R_h2o_csf) / 
                 ((1 - f_csf) * R_metab)) * water_conc
  
  return(corr_factor)
}

#' Convert default LCM/TARQUIN concentration scaling to molal units with partial 
#' volume correction.
#' @param fit_result a \code{fit_result} object to apply partial volume 
#' correction.
#' @param p_vols a numeric vector of partial volumes expressed as percentages.
#' For example, a voxel containing 100% white matter tissue would use : 
#' p_vols = c(WM = 100, GM = 0, CSF = 0).
#' @param te the MRS TE.
#' @param tr the MRS TR.
#' @return a \code{fit_result} object with a rescaled results table.
#' @export
scale_amp_molar2molal_pvc <- function(fit_result, p_vols, te, tr){
  
  # check if res_tab_unscaled exists, and if not create it
  if (is.null(fit_result$res_tab_unscaled)) {
    fit_result$res_tab_unscaled <- fit_result$res_tab
  } else {
    fit_result$res_tab <- fit_result$res_tab_unscaled
  }
  
  B0 <- round(fit_result$data$ft / 42.58e6,1)
  corr_factor <- get_corr_factor(te, tr, B0, p_vols[["GM"]], p_vols[["WM"]],
                                 p_vols[["CSF"]])
  
  amp_cols <- fit_result$amp_cols
  default_factor <- 35880 * 0.7
  fit_result$res_tab$GM_vol <- p_vols[["GM"]]
  fit_result$res_tab$WM_vol <- p_vols[["WM"]]
  fit_result$res_tab$CSF_vol <- p_vols[["CSF"]]
  
  if ("Other" %in% names(p_vols)) {
    fit_result$res_tab$Other_vol <- p_vols[["Other"]]
  }
  
  # append tables with %GM, %WM, %CSF and %Other
  pvc_cols <- 6:(5 + amp_cols * 2)
  fit_result$res_tab[, pvc_cols] <- fit_result$res_tab[, pvc_cols] /
                                    default_factor * corr_factor
  return(fit_result)
}
