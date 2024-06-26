#' Generate trapezoidal regressors.
#' @param onset stimulus onset in seconds.
#' @param duration stimulus duration in seconds.
#' @param trial_type string label for the stimulus.
#' @param mrs_data mrs_data object for timing information.
#' @param rise_t time to reach a plateau from baseline in seconds.
#' @param fall_t time to fall from plateau level back to baseline in seconds.
#' @param exp_fall model an exponential fall instead of linear.
#' @param exp_fall_power exponential fall power.
#' @param smo_sigma standard deviation of Gaussian smoothing kernel in seconds.
#' Set to NULL to disable (default behavior).
#' @param match_tr match the output to the input mrs_data.
#' @param dt timing resolution for internal calculations.
#' @param normalise normalise the response function to have a maximum value of 
#' one.
#' @return trapezoidal regressor data frame.
#' @export
gen_trap_reg <- function(onset, duration, trial_type = NULL, mrs_data = NULL,
                         rise_t = 0, fall_t = 0, exp_fall = FALSE,
                         exp_fall_power = 1, smo_sigma = NULL, match_tr = TRUE,
                         dt = 0.01, normalise = FALSE) {
  
  if (is.null(mrs_data)) {
    seq_tr   <- 2
    N_scans  <- 800
    mrs_data <- sim_resonances()
    mrs_data <- set_tr(mrs_data, seq_tr)
    mrs_data <- set_Ntrans(mrs_data, N_scans)
    mrs_data <- rep_dyn(mrs_data, N_scans)
  }
                         
  if (is.na(tr(mrs_data)) | is.null(tr(mrs_data))) {
    stop("TR not set, use set_tr function to set the repetition time.")
  }
  
  if (is.na(Ntrans(mrs_data)) | is.null(Ntrans(mrs_data))) {
    stop("Number of transients not set, use set_Ntrans function to set the 
         number of transients.")
  }
  
  if (is.null(trial_type)) trial_type <- rep("stim", length(onset))
  
  # check everything is the right length 
  input_lengths <- c(length(onset), length(duration), length(trial_type))
  if (length(unique(input_lengths)) != 1) {
    print(input_lengths)
    stop("Stim length input error.")
  }
  
  # make a time scale with dt seconds resolution for the duration of the scan
  # time
  n_trans   <- mrs_data$meta$NumberOfTransients
  TR        <- tr(mrs_data)
  n_dyns    <- Ndyns(mrs_data)
  t_fine    <- seq(from = 0, to = n_trans * TR - TR, by = dt)
  end       <- onset + duration
  
  stim_frame <- data.frame(onset, end, trial_type)
  
  trial_types  <- unique(trial_type)
  trial_type_n <- length(trial_types)
  
  if (match_tr) {
    empty_mat <- matrix(NA, nrow = n_dyns, ncol = trial_type_n + 1)
  } else {
    empty_mat <- matrix(NA, nrow = length(t_fine), ncol = trial_type_n + 1)
  }
  
  output_frame <- data.frame(empty_mat)
  colnames(output_frame) <- c("time", trial_types)
  
  # time for a 95% reduction
  if (exp_fall) lambda <- -fall_t ^ exp_fall_power / log(0.05)
    
  # loop over trial types
  for (m in 1:trial_type_n) {
    stim_fine <- rep(0, length(t_fine))
    stim_bool <- rep(FALSE, length(t_fine))
    
    # filter out the stim of interest
    stim_frame_trial <- stim_frame[(stim_frame$trial_type == trial_types[m]),]
    
    # loop over stims of the same trial type
    for (n in 1:length(stim_frame_trial$onset)) {
      stim_seg <- t_fine > stim_frame$onset[n] & t_fine <= stim_frame$end[n]
      stim_bool[stim_seg] <- TRUE
    }
    
    last_val <- 0
    for (n in 1:length(stim_fine)) {
      
      if (stim_bool[n]) {
        new_val <- last_val + dt / rise_t
      } else {
        if (exp_fall) {
          t <- (-lambda * log(last_val)) ^ (1 / exp_fall_power) + dt
          new_val <- exp(-(t ^ exp_fall_power / lambda))
          # new_val <-  last_val - dt / lambda * last_val ^ 2
          # new_val <-  last_val - dt / lambda * last_val
      } else {
          new_val <- last_val - dt / fall_t
        }
      }
      
      if (new_val > 1) new_val <- 1
      if (new_val < 0) new_val <- 0
      
      stim_fine[n] <- new_val
      
      last_val <- new_val
    }
    
    if (!is.null(smo_sigma)) {
      # generate a 1D Gaussian kernel 
      gaus_ker  <- mmand::gaussianKernel(smo_sigma / dt)
      stim_fine <- mmand::morph(stim_fine, gaus_ker, operator = "*",
                                merge = "sum")
    }
    
    if (normalise) stim_fine <- stim_fine / max(stim_fine)
    
    t_acq    <- seq(from = 0, by = TR, length.out = n_trans)
    stim_acq <- stats::approx(t_fine, stim_fine, t_acq, method='linear')$y
    
    if (normalise) stim_acq <- stim_acq / max(stim_acq)
   
    # correct for missmatch between n_trans and n_dyns due to temporal averaging 
    if (n_trans != n_dyns) {
      if (n_trans%%n_dyns != 0) stop("Dynamics and transients do not match")
      
      block_size <- n_trans / n_dyns
      
      t_acq    <- colMeans(matrix(t_acq, nrow = block_size))
      stim_acq <- colMeans(matrix(stim_acq, nrow = block_size))
    }
    
    if (match_tr) {
      if (m == 1) output_frame[, 1] <- t_acq
      output_frame[, (1 + m)] <- stim_acq
    } else {
      if (m == 1) output_frame[, 1] <- t_fine
      output_frame[, (1 + m)] <- stim_fine
    }
  }
  
  return(output_frame)
}

#' Generate BOLD regressors.
#' @param onset stimulus onset in seconds.
#' @param duration stimulus duration in seconds.
#' @param trial_type string label for the stimulus.
#' @param mrs_data mrs_data object for timing information.
#' @param match_tr match the output to the input mrs_data.
#' @param dt timing resolution for internal calculations.
#' @param normalise normalise the response function to have a maximum value of 
#' one.
#' @return BOLD regressor data frame.
#' @export
gen_bold_reg <- function(onset, duration = NULL, trial_type = NULL,
                         mrs_data = NULL, match_tr = TRUE, dt = 0.1,
                         normalise = FALSE) {
  
  # create a dummy dataset if not specified
  if (is.null(mrs_data)) {
    seq_tr   <- 2
    N_scans  <- 800
    mrs_data <- sim_resonances()
    mrs_data <- set_tr(mrs_data, seq_tr)
    mrs_data <- set_Ntrans(mrs_data, N_scans)
    mrs_data <- rep_dyn(mrs_data, N_scans)
  }
  
  if (is.null(duration)) duration <- rep(dt, length(onset))
  
  # set the minimum duration to dt * 1.1
  min_dur <- dt * 1.1
  duration[duration < min_dur] <- min_dur
  
  if (is.na(tr(mrs_data)) | is.null(tr(mrs_data))) {
    stop("TR not set, use set_tr function to set the repetition time.")
  }
  
  if (is.na(Ntrans(mrs_data)) | is.null(Ntrans(mrs_data))) {
    stop("Number of transients not set, use set_Ntrans function to set the 
         number of transients.")
  }
  
  if (is.null(trial_type)) trial_type <- rep("stim_bold", length(onset))
  
  # check everything is the right length 
  input_lengths <- c(length(onset), length(duration), length(trial_type))
  if (length(unique(input_lengths)) != 1) stop("Stim length input error.")
  
  # make a time scale with dt seconds resolution for the duration of the scan
  # time
  n_trans   <- mrs_data$meta$NumberOfTransients
  TR        <- tr(mrs_data)
  n_dyns    <- Ndyns(mrs_data)
  t_fine    <- seq(from = 0, to = n_trans * TR, by = dt)
  end       <- onset + duration
  
  stim_frame   <- data.frame(onset, end, trial_type, duration)
  
  trial_types  <- unique(trial_type)
  trial_type_n <- length(trial_types)
  
  if (match_tr) {
    empty_mat <- matrix(NA, nrow = n_dyns, ncol = trial_type_n + 1)
  } else {
    empty_mat <- matrix(NA, nrow = length(t_fine), ncol = trial_type_n + 1)
  }
  
  output_frame <- data.frame(empty_mat)
  colnames(output_frame) <- c("time", trial_types)
  
  resp_fn   <- gen_hrf(res_t = dt)$hrf
    
  for (m in 1:trial_type_n) {
    stim_fine <- rep(0, length(t_fine))
    
    # filter out the stim of interest
    stim_frame_trial <- stim_frame[(stim_frame$trial_type == trial_types[m]),]
    
    for (n in 1:length(stim_frame_trial$onset)) {
      index_bool <- t_fine >= stim_frame_trial$onset[n] & 
                    t_fine < stim_frame_trial$end[n]
      index <- which(index_bool)
      
      # only use one point if an impulse
      if (stim_frame_trial$duration[n] == min_dur) index <- index[1]
      
      stim_fine[index] <- 1
    }
    
    stim_fine <- stats::convolve(stim_fine, rev(resp_fn), type = 'open')
    stim_fine <- stim_fine[1:length(t_fine)]
    
    if (normalise) stim_fine <- stim_fine / max(stim_fine)
    
    t_acq    <- seq(from = 0, by = TR, length.out = n_trans)
    stim_acq <- stats::approx(t_fine, stim_fine, t_acq, method='linear')$y
    
    # if (normalise) stim_acq <- stim_acq / max(stim_acq)
    
    if (n_trans != n_dyns) {
      if (n_trans%%n_dyns != 0) stop("Dynamics and transients do not match")
      
      block_size <- n_trans / n_dyns
      
      t_acq    <- colMeans(matrix(t_acq, nrow = block_size))
      stim_acq <- colMeans(matrix(stim_acq, nrow = block_size))
    }
    
    if (match_tr) {
      if (m == 1) output_frame[, 1] <- t_acq
      output_frame[, (1 + m)] <- stim_acq
    } else {
      if (m == 1) output_frame[, 1] <- t_fine
      output_frame[, (1 + m)] <- stim_fine
    }
    
  }
  
  return(output_frame)
}

#' Generate regressors by convolving a specified response function with a
#' stimulus.
#' @param onset stimulus onset in seconds.
#' @param duration stimulus duration in seconds.
#' @param trial_type string label for the stimulus.
#' @param mrs_data mrs_data object for timing information.
#' @param resp_fn a data frame specifying the response function to be convolved.
#' @param match_tr match the output to the input mrs_data.
#' @param normalise normalise the response function to have a maximum value of 
#' one.
#' @return BOLD regressor data frame.
#' @export
gen_conv_reg <- function(onset, duration = NULL, trial_type = NULL,
                         mrs_data = NULL, resp_fn, match_tr = TRUE,
                         normalise = FALSE) {
  
  # create a dummy dataset if not specified
  if (is.null(mrs_data)) {
    seq_tr   <- 2
    N_scans  <- 800
    mrs_data <- sim_resonances()
    mrs_data <- set_tr(mrs_data, seq_tr)
    mrs_data <- set_Ntrans(mrs_data, N_scans)
    mrs_data <- rep_dyn(mrs_data, N_scans)
  }
  
  dt <- resp_fn[2, 1] - resp_fn[1, 1]
  
  if (is.null(duration)) duration <- rep(0, length(onset))
  
  # set the minimum duration to dt * 1.1
  min_dur <- dt * 1.1
  duration[duration < min_dur] <- min_dur
  
  if (is.na(tr(mrs_data)) | is.null(tr(mrs_data))) {
    stop("TR not set, use set_tr function to set the repetition time.")
  }
  
  if (is.na(Ntrans(mrs_data)) | is.null(Ntrans(mrs_data))) {
    stop("Number of transients not set, use set_Ntrans function to set the 
         number of transients.")
  }
  
  if (is.null(trial_type)) trial_type <- rep("stim_conv", length(onset))
  
  # check everything is the right length 
  input_lengths <- c(length(onset), length(duration), length(trial_type))
  if (length(unique(input_lengths)) != 1) {
    print(input_lengths)
    stop("Stim length input error.")
  }
  
  # make a time scale with dt seconds resolution for the duration of the scan
  # time
  n_trans   <- mrs_data$meta$NumberOfTransients
  TR        <- tr(mrs_data)
  n_dyns    <- Ndyns(mrs_data)
  t_fine    <- seq(from = 0, to = n_trans * TR, by = dt)
  end       <- onset + duration
  
  stim_frame   <- data.frame(onset, end, trial_type, duration)
  
  trial_types  <- unique(trial_type)
  trial_type_n <- length(trial_types)
  
  if (match_tr) {
    empty_mat <- matrix(NA, nrow = n_dyns, ncol = trial_type_n + 1)
  } else {
    empty_mat <- matrix(NA, nrow = length(t_fine), ncol = trial_type_n + 1)
  }
  
  output_frame <- data.frame(empty_mat)
  colnames(output_frame) <- c("time", trial_types)
  
  resp_fn <- resp_fn[,2] 
    
  for (m in 1:trial_type_n) {
    stim_fine <- rep(0, length(t_fine))
    
    # filter out the stim of interest
    stim_frame_trial <- stim_frame[(stim_frame$trial_type == trial_types[m]),]
    
    for (n in 1:length(stim_frame_trial$onset)) {
      index_bool <- t_fine >= stim_frame_trial$onset[n] & 
                    t_fine < stim_frame_trial$end[n]
      index <- which(index_bool)
      
      # only use one point if an impulse
      if (stim_frame_trial$duration[n] == min_dur) index <- index[1]
      stim_fine[index] <- 1
    }
    
    stim_fine <- stats::convolve(stim_fine, rev(resp_fn), type = 'open')
    stim_fine <- stim_fine[1:length(t_fine)]
    
    if (normalise) stim_fine <- stim_fine / max(stim_fine)
    
    t_acq    <- seq(from = 0, by = TR, length.out = n_trans)
    stim_acq <- stats::approx(t_fine, stim_fine, t_acq, method='linear')$y
    
    # if (normalise) stim_acq <- stim_acq / max(stim_acq)
    
    if (n_trans != n_dyns) {
      if (n_trans%%n_dyns != 0) stop("Dynamics and transients do not match")
      
      block_size <- n_trans / n_dyns
      
      t_acq    <- colMeans(matrix(t_acq, nrow = block_size))
      stim_acq <- colMeans(matrix(stim_acq, nrow = block_size))
    }
    
    if (match_tr) {
      if (m == 1) output_frame[, 1] <- t_acq
      output_frame[, (1 + m)] <- stim_acq
    } else {
      if (m == 1) output_frame[, 1] <- t_fine
      output_frame[, (1 + m)] <- stim_fine
    }
    
  }
  
  return(output_frame)
}

#' Generate impulse regressors.
#' @param onset stimulus onset in seconds.
#' @param trial_type string label for the stimulus.
#' @param mrs_data mrs_data object for timing information.
#' @return impulse regressors data frame.
#' @export
gen_impulse_reg <- function(onset, trial_type = NULL, mrs_data = NULL) {
  
  if (is.null(mrs_data)) {
    seq_tr   <- 2
    N_scans  <- 800
    mrs_data <- sim_resonances()
    mrs_data <- set_tr(mrs_data, seq_tr)
    mrs_data <- set_Ntrans(mrs_data, N_scans)
    mrs_data <- rep_dyn(mrs_data, N_scans)
  }
  
  if (is.na(tr(mrs_data)) | is.null(tr(mrs_data))) {
    stop("TR not set, use set_tr function to set the repetition time.")
  }
  
  if (is.na(Ntrans(mrs_data)) | is.null(Ntrans(mrs_data))) {
    stop("Number of transients not set, use set_Ntrans function to set the 
         number of transients.")
  }
  
  if (is.null(trial_type)) trial_type <- rep("stim_imp", length(onset))
  
  trial_types  <- unique(trial_type)
  trial_type_n <- length(trial_types)
  
  stim_frame <- data.frame(onset, trial_type)
 
  n_dyns    <- Ndyns(mrs_data)
  empty_mat <- matrix(NA, nrow = n_dyns, ncol = trial_type_n)
  
  output_frame <- data.frame(empty_mat)
  colnames(output_frame) <- c(trial_types)
    
  time <- dyn_acq_times(mrs_data)
  
  for (m in 1:trial_type_n) {
    stim <- rep(0, length(time))
    stim_frame_trial <- stim_frame[(stim_frame$trial_type == trial_types[m]),]
    for (n in 1:length(stim_frame_trial$onset)) {
      ind <- which.min(Mod(time - stim_frame_trial$onset[n]))
      stim[ind] <- 1
      if (Mod(stim_frame_trial$onset[n] - time[ind]) > 0.01) {
        warning("onset and output impulse differ by more than 10 ms")
      }
    }
    output_frame[, m] <- stim
  }
  output_frame <- cbind(time, output_frame)
  
  return(output_frame)
}

# gen double gamma model of hrf (as used in SPM) with 10ms resolution
# https://github.com/spm/spm12/blob/main/spm_hrf.m
gen_hrf <- function(end_t = 30, res_t = 0.01) {
  t_hrf <- seq(from = 0, to = end_t, by = res_t)
  a1 <- 6; a2 <- 16; b1 <- 1; b2 <- 1; c <- 1 / 6
  hrf <-     t_hrf ^ (a1 - 1) * b1 ^ a1 * exp(-b1 * t_hrf) / gamma(a1) -
         c * t_hrf ^ (a2 - 1) * b2 ^ a2 * exp(-b2 * t_hrf) / gamma(a2)
  hrf <- hrf / sum(hrf)
  return(list(hrf = hrf, t = t_hrf))
}

#' Perform a GLM analysis of dynamic MRS data in the spectral domain.
#' @param mrs_data single-voxel dynamics MRS data.
#' @param regressor_df a data frame containing temporal regressors to be applied
#' to each spectral datapoint.
#' @return list of statistical results.
#' @export
glm_spec <- function(mrs_data, regressor_df) {
  
  # warning, any column named time in regressor_df will be removed
  
  # needs to be a FD operation
  if (!is_fd(mrs_data)) mrs_data <- td2fd(mrs_data)
  
  mrs_mat <- Re(mrs_data2mat(mrs_data))
  
  # drop the time column if present
  regressor_df<- regressor_df[, !names(regressor_df) %in% c("time"),
                              drop = FALSE]
  
  lm_res_list <- vector("list", ncol(mrs_mat))
  for (n in 1:ncol(mrs_mat)) {
    lm_res_list[[n]] <- summary(stats::lm(mrs_mat[, n] ~ ., regressor_df))
  }
  
  # extract stats
  get_glm_stat <- function(x, name) x$coefficients[-1, name, drop = FALSE]
  
  beta_weight <- as.data.frame(t(as.data.frame(sapply(lm_res_list, get_glm_stat,
                                               "Estimate", simplify = FALSE))))
  p_value <- as.data.frame(t(as.data.frame(sapply(lm_res_list, get_glm_stat,
                                           "Pr(>|t|)", simplify = FALSE))))
  
  row.names(beta_weight) <- NULL
  row.names(p_value)     <- NULL
  
  ppm_sc      <-  ppm(mrs_data)
  beta_weight <-  cbind(ppm = ppm_sc, beta_weight)
  p_value_log <- -log10(p_value)
  p_value     <-  cbind(ppm = ppm_sc, p_value)
  p_value_log <-  cbind(ppm = ppm_sc, p_value_log)
  
  p_value_log_mrs <- mat2mrs_data(t(p_value_log[, -1]), fs = fs(mrs_data),
                                  ft = mrs_data$ft, ref = mrs_data$ref,
                                  nuc = mrs_data$nuc, fd = TRUE)
  
  p_value_mrs     <- mat2mrs_data(t(p_value[, -1]), fs = fs(mrs_data),
                                  ft = mrs_data$ft, ref = mrs_data$ref,
                                  nuc = mrs_data$nuc, fd = TRUE)
  
  beta_weight_mrs <- mat2mrs_data(t(beta_weight[, -1]), fs = fs(mrs_data),
                                  ft = mrs_data$ft, ref = mrs_data$ref,
                                  nuc = mrs_data$nuc, fd = TRUE)
  
  return(list(beta_weight = beta_weight, p_value = p_value,
              p_value_log = p_value_log, p_value_log_mrs = p_value_log_mrs,
              p_value_mrs = p_value_mrs, beta_weight_mrs = beta_weight_mrs,
              lm_res_list = lm_res_list))
}

#' Calculate the efficiency of a regressor data frame.
#' @param regressor_df input regressor data frame.
#' @param contrasts a vector of contrast values.
#' @export
calc_design_efficiency <- function(regressor_df, contrasts) {
  X   <- as.matrix(regressor_df[, -1])
  eff <- 1 / sum(diag(t(contrasts) %*% ginv(t(X) %*% X) %*% contrasts))
  return(eff)
}

#' Plot regressors as an image.
#' @param regressor_df input regressor data frame.
#' @export
plot_reg <- function(regressor_df) {
  time  <- regressor_df$time
  names <- colnames(regressor_df)[-1]
  X     <- t(regressor_df[, -1])
  graphics::image(y = time, z = X, col = viridisLite::viridis(128),
                  ylab = "Time (s)", axes = FALSE)
  graphics::axis(1, at=seq(0, 1, length = length(names)), labels = names)
  graphics::axis(2)
  graphics::box()
}

#' Append multiple regressor data frames into a single data frame.
#' @param ... input regressor data frames.
#' @return output regressor data frame.
#' @export
append_regs <- function(...) {
  df_list    <- list(...)
  time       <- df_list[[1]]$time
  df_list_nt <- lapply(df_list, subset, select = -time)
  output     <- do.call("cbind", df_list_nt)
  return(cbind(time, output)) 
}

#' Generate baseline regressor.
#' @param mrs_data mrs_data object for timing information.
#' @return a single baseline regressor with value of 1.
#' @export
gen_baseline_reg <- function(mrs_data) {
  time   <- dyn_acq_times(mrs_data)
  reg_df <- data.frame(time = time, baseline = rep(1, length(t)))
  return(reg_df)
}

#' Generate polynomial regressors.
#' @param mrs_data mrs_data object for timing information.
#' @param degree the degree of the polynomial.
#' @return polynomial regressors.
#' @export
gen_poly_reg <- function(mrs_data, degree) {
  time       <- dyn_acq_times(mrs_data)
  poly_mat   <- stats::poly(time, degree)
  scale_vals <- apply(Mod(poly_mat), 2, max)
  poly_mat   <- scale(poly_mat, center = FALSE, scale = scale_vals)
  reg_df     <- data.frame(time = time, poly = poly_mat)
  return(reg_df)
}

#' Create a BIDS directory and file structure from a list of mrs_data objects.
#' @param mrs_data_list list of mrs_data objects.
#' @param output_dir the base directory to create the BIDS structure.
#' @param runs number of runs per subject and session.
#' @param sessions number of sessions.
#' @param sub_labels optional labels for subject level identification.
#' @export
mrs_data_list2bids <- function(mrs_data_list, output_dir, runs = 1,
                               sessions = 1, sub_labels = NULL) {
  
  Nmrs <- length(mrs_data_list)
  
  # check the number of datasets can be cleanly divided by the number of runs
  # and sessions
  if ((Nmrs %% (runs * sessions)) != 0) stop("inconsistent number of datasets")
  
  Nsubs <- Nmrs / runs / sessions
  
  if (is.null(sub_labels)) sub_labels <- auto_pad_seq(1:Nsubs)
  
  if (Nsubs != length(sub_labels)) stop("inconsistent subject labels")
  
  sub_labels <- paste0("sub-", sub_labels)
  sub_labels <- rep(sub_labels, each = runs * sessions)
  
  if (sessions != 1) {
    ses_labels <- auto_pad_seq(1:sessions)
    ses_labels <- paste0("ses-", ses_labels)
    ses_labels <- rep(ses_labels, each = runs)
    ses_labels <- rep(ses_labels, Nsubs * sessions)
  }
  
  if (runs != 1) {
    run_labels <- auto_pad_seq(1:runs)
    run_labels <- paste0("run-", run_labels)
    run_labels <- rep(run_labels, runs * sessions * Nsubs)
  }
  
  # construct the directories
  if (sessions == 1) {
    dirs <- file.path(output_dir, sub_labels, "mrs")
  } else {
    dirs <- file.path(output_dir, sub_labels, ses_labels, "mrs")
  }
  
  # create the directories
  for (dir in dirs) dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  
  # construct the filenames
  fnames <- paste0(sub_labels)
  
  if (sessions != 1) fnames <- paste0(fnames, "_", ses_labels)
  
  if (runs != 1) fnames <- paste0(fnames, "_", run_labels)
  
  fnames <- paste0(fnames, "_svs.nii.gz")
  
  # construct the full path
  full_path <- file.path(dirs, fnames)
  
  # write the data
  for (n in 1:Nmrs) {
    write_mrs(mrs_data_list[[n]], fname = full_path[n], format = "nifti",
              force = TRUE) 
  }
}

auto_pad_seq <- function(x, min_pad = 2) {
  x_int <- sprintf("%d", x)
  pad_n <- max(nchar(x_int))
  if (pad_n < min_pad) pad_n <- min_pad
  fmt_string <- paste0("%0", pad_n, "d")
  return(sprintf(fmt_string, x))
}

#' Search for MRS data files in a BIDS filesystem structure.
#' @param path path to the directory containing the BIDS structure.
#' @return data frame containing full paths and information on each MRS file.
#' @export
find_bids_mrs <- function(path) {
  
  # find the "mrs" directories
  mrs_dirs <- dir(path, recursive = TRUE, include.dirs = TRUE, pattern = "mrs",
                  full.names = TRUE)
  
  # list all files in "mrs" directories
  mrs_paths <- list.files(mrs_dirs, full.names = TRUE)
  
  # remove any .json files
  mrs_paths <- grep(".json$", mrs_paths, invert = TRUE, value = TRUE)
  
  mrs_names <- basename(mrs_paths)
  mrs_names <- tools::file_path_sans_ext(tools::file_path_sans_ext(mrs_names))
  
  tags    <- strsplit(mrs_names, "_")
  tags_ul <- unlist(tags)
  
  sub <- grep("sub-", tags_ul, value = TRUE)
  sub <- substring(sub, 5)
  
  mrs_info <- data.frame(path = mrs_paths, sub = as.factor(sub))
  
  ses <- grep("ses-", tags_ul, value = TRUE)
  if (length(ses) != 0) {
    ses <- substring(ses, 5)
    mrs_info <- cbind(mrs_info, ses = as.factor(ses))
  }
  
  run <- grep("run-", tags_ul, value = TRUE)
  if (length(run) != 0) {
    run <- substring(run, 5)
    mrs_info <- cbind(mrs_info, run = as.factor(run))
  }
  
  suffix <- grep("-", tags_ul, value = TRUE, invert = TRUE)
  
  mrs_info <- cbind(mrs_info, suffix = as.factor(suffix))
 
  return(mrs_info) 
}