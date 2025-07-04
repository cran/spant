#' Robust Alignment to a Target Spectrum (RATS).
#' 
#' @param mrs_data MRS data to be corrected.
#' @param ref optional MRS data to use as a reference, the mean of all dynamics
#' is used if this argument is not supplied.
#' @param xlim optional frequency range to perform optimisation, set to NULL
#' to use the full range.
#' @param max_shift maximum allowable frequency shift in Hz.
#' @param p_deg polynomial degree used for baseline modelling. Negative values
#' disable baseline modelling.
#' @param sp_N number of spline functions, note the true number will be sp_N +
#' sp_deg.
#' @param sp_deg degree of spline functions.
#' @param max_t truncate the FID when longer than max_t to reduce time taken,
#' set to NULL to use the entire FID.
#' @param basis_type may be one of "poly" or "spline".
#' @param rescale_output rescale the bl_matched_spec and bl output to improve
#' consistency between dynamic scans.
#' @param phase_corr apply phase correction (in addition to frequency). TRUE by
#' default.
#' @param ret_corr_only return the corrected mrs_data object only.
#' @param zero_freq_shift_t0 perform a linear fit to the frequency shifts and
#' set the (linearly modeled) shift to be 0 Hz for the first dynamic scan.
#' @param list_mean_ref is ref is not specified and a list is provided, use the
#' list mean scan as reference. Otherwise use the mean of each list element as
#' it's own reference.
#' @param remove_freq_outliers remove dynamics based on their frequency shift.
#' @param freq_outlier_thresh threshold to remove frequency outliers.
#' @param remove_phase_outliers remove dynamics based on their phase shift.
#' @param phase_outlier_thresh threshold to remove phase outliers.
#' @param remove_amp_outliers remove dynamics based on their amplitude change.
#' @param amp_outlier_thresh threshold to remove amplitude outliers.
#' @return a list containing the corrected data; phase and shift values in units
#' of degrees and Hz respectively.
#' @export
rats <- function(mrs_data, ref = NULL, xlim = c(4, 0.5), max_shift = 20,
                 p_deg = 2, sp_N = 2, sp_deg = 3, max_t = 0.2,
                 basis_type = "poly", rescale_output = TRUE,
                 phase_corr = TRUE, ret_corr_only = TRUE,
                 zero_freq_shift_t0 = FALSE, list_mean_ref = TRUE,
                 remove_freq_outliers = FALSE, freq_outlier_thresh = 3,
                 remove_phase_outliers = FALSE, phase_outlier_thresh = 3,
                 remove_amp_outliers = FALSE, amp_outlier_thresh = 3) {
  
  if (inherits(mrs_data, "list")) {
    
    # take the mean over the list and dataset if ref is not given 
    if (is.null(ref) & list_mean_ref) {
      ref <- mean_mrs_list(mrs_data)
      ref <- mean(ref, na.rm = TRUE)
    } 
    
    res <- lapply(mrs_data, rats, ref = ref, xlim = xlim, max_shift = max_shift,
                  p_deg = p_deg, sp_N = sp_N, sp_deg = sp_deg, max_t = max_t,
                  basis_type = basis_type, rescale_output = rescale_output,
                  phase_corr = phase_corr, ret_corr_only = ret_corr_only,
                  zero_freq_shift_t0 = zero_freq_shift_t0,
                  list_mean_ref = list_mean_ref,
                  remove_freq_outliers = remove_freq_outliers,
                  freq_outlier_thresh = freq_outlier_thresh,
                  remove_phase_outliers = remove_phase_outliers,
                  phase_outlier_thresh = phase_outlier_thresh,
                  remove_amp_outliers = remove_amp_outliers,
                  amp_outlier_thresh = amp_outlier_thresh)
    
    return(res)
  }
  
  # move mrs_data to the time-domain
  if (is_fd(mrs_data)) mrs_data <- fd2td(mrs_data)
   
  t <- seconds(mrs_data)
  
  # truncate the FID to improve speed 
  mrs_data_mod <- mrs_data
  if (!is.null(max_t)) {
    pts <- sum(t < max_t)
    t <- t[1:pts]
    mrs_data_mod$data <- mrs_data_mod$data[,,,,,,1:pts, drop = FALSE]
  }
  
  # align to mean if ref is not given
  if (is.null(ref)) ref <- mean(mrs_data, na.rm = TRUE)
  
  if (!is.null(max_t)) {
    # move ref to the time-domain
    if (is_fd(ref)) ref <- fd2td(ref)
    ref$data <- ref$data[,,,,,,1:pts, drop = FALSE]
  }
  
  # move ref back to the freq-domain
  if (!is_fd(ref)) ref <- td2fd(ref)
  
  # ref_mod is in the fd 
  ref_mod <- crop_spec(ref, xlim)
  ref_data <- as.complex(ref_mod$data)
  inds <- get_seg_ind(ppm(mrs_data_mod), xlim[1], xlim[2]) 
  
  if (basis_type == "poly") {
    if (p_deg == 0) {
      basis <- rep(1, length(inds))
    } else if (p_deg > 0) {
      basis <- cbind(rep(1, length(inds)), stats::polym(1:length(inds),
                                                        degree = p_deg))
    } else {
      basis <- NULL
    }
  } else if (basis_type == "spline") {
    basis <- bbase(length(inds), sp_N, sp_deg)
  } else{
    stop("I don't belong here.")
  }
  
  # optimisation step
  res <- apply_mrs(mrs_data_mod, 7, optim_rats, ref_data, t, inds, basis, 
                   max_shift, data_only = TRUE)
  
  phases <- Re(res[,,,,,,1, drop = FALSE])
  shifts <- Re(res[,,,,,,2, drop = FALSE])
  amps   <- Re(res[,,,,,,3, drop = FALSE])
  
  corr_spec <- ref_mod
  corr_spec$data <- res[,,,,,,4:(length(inds) + 3), drop = FALSE]
  bl_spec <- ref_mod
  bl_spec$data <- res[,,,,,,(length(inds) + 4):(2 * length(inds) + 3),
                      drop = FALSE]
  
  corr_dims <- dim(shifts)
  
  if (zero_freq_shift_t0)  {
    if (length(shifts) > 2) {
      shifts <- shifts - mean(shifts[1:3])
    } else {
      shifts <- shifts - shifts[1]
    }
  }
  
  if (remove_freq_outliers) {
    
    # model frequency drift
    x <- 0:(length(shifts) - 1)
    shift_fit <- as.numeric(stats::predict(stats::lm(as.numeric(shifts) ~ x)))
    
    if (remove_freq_outliers) {
      res <- as.numeric(shifts) - shift_fit
      res_med <- stats::median(res)
      res_mad <- stats::mad(res)
      upper_lim_freq <- res_mad * freq_outlier_thresh
      bad_freqs <- Mod(res - res_med) > upper_lim_freq
    }
  }
  
  if (remove_phase_outliers) {
      phases_med <- stats::median(phases)
      phases_mad <- stats::mad(phases)
      upper_lim_phases <- phases_mad * phase_outlier_thresh
      bad_phases <- Mod(as.numeric(phases - phases_med)) > upper_lim_phases
  }
  
  if (remove_amp_outliers) {
      amps_med <- stats::median(amps)
      amps_mad <- stats::mad(amps)
      upper_lim_amps <- amps_mad * amp_outlier_thresh
      bad_amps <- Mod(as.numeric(amps - amps_med)) > upper_lim_amps
  }
  
  # apply to original data
  t_orig <- rep(seconds(mrs_data), each = Nspec(mrs_data))
  t_array <- array(t_orig, dim = dim(mrs_data$data))
  shift_array <- array(shifts, dim = dim(mrs_data$data))
  
  if (!phase_corr) phases <- 0
  
  phase_array <- array(phases, dim = dim(mrs_data$data))
  mod_array   <- exp(2i * pi * t_array * shift_array + 1i * phase_array * 
                     pi / 180)
  mrs_data$data <- mrs_data$data * mod_array
 
  # maintain original intensities for bl_matched_spec and bl output
  if (!rescale_output) {
    corr_spec <- scale_mrs_amp(corr_spec, 1 / amps)
    bl_spec   <- scale_mrs_amp(bl_spec,   1 / amps)
  }
  
  if (remove_amp_outliers) mrs_data <- mask_dyns(mrs_data, bad_amps)
  if (remove_freq_outliers) mrs_data <- mask_dyns(mrs_data, bad_freqs)
  if (remove_phase_outliers) mrs_data <- mask_dyns(mrs_data, bad_phases)
  
  # results
  res <- list(corrected = mrs_data, phases = -phases, shifts = -shifts,
              amps = amps, bl_matched_spec = corr_spec, bl = -bl_spec)
  
  if (ret_corr_only) {
    return(res$corrected)
  } else {
    return(res)
  }
}

optim_rats <- function(x, ref, t, inds, basis, max_shift) {
  
  # masked spectra are special case
  if (is.na(x[1])) {
    res <- c(NA, NA, NA, rep(NA, 2 * length(inds)))
    return(res)
  }
  
  # optim step
  res <- stats::optim(c(0), rats_obj_fn, gr = NULL, x, ref, t, inds, basis, 
               method = "Brent", lower = -max_shift, upper = max_shift)
  
  # find the phase
  shift <- res$par[1]
  x <- x * exp(2i * pi * shift * t)
  x <- ft_shift(x)
  x <- x[inds]
  
  if (is.null(basis)) {
    basis_mod <- x
    ahat <- unname(qr.solve(basis_mod, ref))
    yhat <- basis_mod * ahat
  } else {
    basis_mod <- cbind(x, basis)
    ahat <- unname(qr.solve(basis_mod, ref))
    yhat <- basis_mod %*% ahat
    bl   <- basis_mod %*% c(0, ahat[2:length(ahat)])
  }
  
  res <- c(Arg(ahat[1]) * 180 / pi, res$par, Mod(ahat[1]), yhat, bl)
  return(res)
}

rats_obj_fn <- function(par, x, ref, t, inds, basis) {
  shift <- par[1]
  x <- x * exp(2i * pi * shift * t)
  x <- ft_shift(x)
  x <- x[inds]
  
  if (is.null(basis)) {
    basis_mod <- x
  } else {
    basis_mod <- cbind(x, basis)
  }
  
  # use ginv
  #inv_basis <- ginv(basis)
  #ahat <- inv_basis %*% ref
  
  # use qr
  ahat <- qr.solve(basis_mod, ref)
  
  if (is.null(basis)) {
    yhat <- basis_mod * ahat
  } else {
    yhat <- basis_mod %*% ahat
  }
  
  res <- c(Re(yhat), Im(yhat)) - c(Re(ref), Im(ref))
  
  sum(res ^ 2)
}

#' Corrected zero order phase and chemical shift offset in 1H MRS data from the
#' brain.
#' @param mrs_data MRS data to be corrected.
#' @param mean_ref apply the phase and offset of the mean spectrum to all
#' others. Default is FALSE.
#' @param ret_corr_only return the corrected data only.
#' @return corrected MRS data.
#' @export
phase_ref_1h_brain <- function(mrs_data, mean_ref = FALSE,
                               ret_corr_only = TRUE) {
  
  if (inherits(mrs_data, "list")) {
    return(lapply(mrs_data, phase_ref_1h_brain, mean_ref = mean_ref,
                  ret_corr_only = ret_corr_only))
  }
  
  ref <- sim_resonances(acq_paras = mrs_data, freq = c(2.01, 3.03, 3.22),
                        amp = 1, lw = 4, lg = 0)
  
  p_deg <- 3
  xlim  <- c(4, 1.9)
 
  if (mean_ref) {
    mean_mrs_data <- mean(mrs_data)
    res <- rats(mean_mrs_data, ref, xlim = xlim, p_deg = p_deg,
                ret_corr_only = FALSE)
    
    phase <- as.numeric(res$phases)
    shift <- as.numeric(res$shifts)
    
    mrs_corr <- phase(mrs_data, -phase)
    mrs_corr <- shift(mrs_corr, -shift, units = "hz")
    
    res$corrected <- mrs_corr
  } else {
    res <- rats(mrs_data, ref, xlim = xlim, p_deg = p_deg,
                ret_corr_only = FALSE)
  }
  
  if (ret_corr_only) {
    return(res$corrected) 
  } else {
    return(res)
  }
}