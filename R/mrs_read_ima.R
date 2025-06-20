read_ima <- function(fraw, verbose = FALSE, extra) {
  
  tags <- list(ascii_hdr = "0029,1120", spec_data = "7FE1,1010")
  res  <- dicom_reader(fraw, tags)
  
  vars <- read_siemens_txt_hdr(res$ascii_hdr, "vd", verbose)
  
  # works for CMRR MPRESS, but not CMRR sLASER
  if (!vars$rm_oversampling) vars$N <- vars$N * 2
  
  # calculate expected size of data points
  data_size <- vars$x_pts * vars$y_pts * vars$z_pts * vars$N * 2
  
  # note that for scans where oversampling is not removed there are actually
  # twice the number of points in the DICOM tag. However these points seem to
  # be garbage making this mode useless as half the time-domain data is lost.
  
  raw_pts <- readBin(res$spec_data, what = "double", n = data_size, size = 4L)
  
  # make complex
  data <- raw_pts[c(TRUE, FALSE)] + 1i * raw_pts[c(FALSE, TRUE)]
  
  data <- array(data, dim = c(vars$N, 1, 1, vars$z_pts, vars$y_pts, vars$x_pts, 
                              1))
  
  data <- aperm(data, c(7, 5, 6, 4, 3, 2, 1))
  
  # freq domain vector vector
  freq_domain <- rep(FALSE, 7)

  # get the resolution and geom info
  paras <- calc_siemens_paras(vars, TRUE)
  
  if (startsWith(toupper(vars$seq_fname), "%CUSTOMERSEQ%\\SVS_SLASER")) {
    vars$te <- vars$te1 + vars$te2 + vars$te3
  }
  
  if (startsWith(toupper(vars$seq_fname), "%CUSTOMERSEQ%\\DKD_SVS_SLASER")) {
    vars$te <- vars$te1 + vars$te2 + vars$te3
  }
  
  meta <- list(EchoTime = vars$te,
               FlipAngle = vars$flip_ang,
               SequenceName = vars$seq_fname,
               ChemicalShiftReference = 4.7 + vars$delta_freq,
               NumberOfTransients = vars$averages,
               Manufacturer = "Siemens")
  
  if (toupper(vars$seq_fname) == "%SIEMENSSEQ%\\SVS_SE") {
    meta <- append(meta, list(PulseSequenceType = "press"))
  }
  
  if (toupper(vars$seq_fname) == "%SIEMENSSEQ%\\SVS_ST") {
    meta <- append(meta, list(PulseSequenceType = "steam"))
  }
  
  if (startsWith(toupper(vars$seq_fname), "%CUSTOMERSEQ%\\SVS_SLASER")) {
    meta <- append(meta, list(PulseSequenceType = "slaser",
                              TE1 = vars$te1,
                              TE2 = vars$te2,
                              TE3 = vars$te3))
  }
  
  if (startsWith(toupper(vars$seq_fname), "%CUSTOMERSEQ%\\DKD_SVS_SLASER")) {
    meta <- append(meta, list(PulseSequenceType = "slaser",
                              TE1 = vars$te1,
                              TE2 = vars$te2,
                              TE3 = vars$te3))
  }
  
  if (vars$rm_oversampling) meta <- append(meta, list(fid_filt_dist = TRUE))
  
  mrs_data <- mrs_data(data = data, ft = vars$ft, resolution = paras$res,
                       ref = paras$ref, nuc = paras$nuc,
                       freq_domain = freq_domain, affine = paras$affine,
                       meta = meta, extra = extra)
  
  return(mrs_data)
}

#' Read a directory containing Siemens MRS IMA files and combine along the coil
#' dimension. Note that the coil ID is inferred from the sorted file name and
#' should be checked when consistency is required between two directories.
#' @param dir data directory path.
#' @param extra an optional data frame to provide additional variables for use
#' in subsequent analysis steps, eg id or grouping variables.
#' @param verbose output extra information to the console.
#' @return mrs_data object.
#' @export
read_ima_coil_dir <- function(dir, extra = NULL, verbose = FALSE) {
  
  # check the directory exists
  if (!dir.exists(dir)) stop("Error read_ima_coil_dir directory was not found.")
  
  # check it contains some files
  files <- list.files(dir, full.names = TRUE)
  if (length(files) == 0) stop("Error, read_ima_coil_dir files not found.")
  
  #warning("coil ordering is based on file name only.")
  
  files <- sort(files)
  mrs_list <- lapply(files, read_mrs, format = "dicom", verbose = verbose,
                     extra = extra)
  mrs_data <- append_coils(mrs_list)
  return(mrs_data)
}

#' Read a directory containing Siemens MRS IMA files and combine along the
#' dynamic dimension. Note that the coil ID is inferred from the sorted file
#' name and should be checked when consistency is required.
#' @param dir data directory path.
#' @param extra an optional data frame to provide additional variables for use
#' in subsequent analysis steps, eg id or grouping variables.
#' @param verbose output extra information to the console.
#' @return mrs_data object.
#' @export
read_ima_dyn_dir <- function(dir, extra = NULL, verbose = FALSE) {
  
  # check the directory exists
  if (!dir.exists(dir)) stop("Error read_ima_dyn_dir directory was not found.")
  
  # check it contains some files
  files <- list.files(dir, full.names = TRUE)
  if (length(files) == 0) stop("Error, read_ima_dyn_dir files not found.")
  
  files <- sort(files)
  mrs_list <- lapply(files, read_mrs, format = "dicom", verbose = verbose,
                     extra = extra)
  
  mrs_data <- append_dyns(mrs_list)
  
  # deal with CMRR reference scans if needed
  seq_name_upper <- toupper(mrs_data$meta$SequenceName)
  if (startsWith(seq_name_upper, "%CUSTOMERSEQ%\\SVS_SLASER") |
      startsWith(seq_name_upper, "%CUSTOMERSEQ%\\DKD_SVS_SLASER")) {
    if (mrs_data$meta$NumberOfTransients == Ndyns(mrs_data)) {
      return(mrs_data)
    } else if (mrs_data$meta$NumberOfTransients * 2 == Ndyns(mrs_data)) {
      return(mrs_data)
    } else {
      return(extract_dkd_wref_scans(mrs_data))
    }
  } else {
    return(mrs_data)
  }
}

extract_dkd_wref_scans <- function(mrs_data) {
  
  full_n  <- Ndyns(mrs_data)
  metab_n <- mrs_data$meta$NumberOfTransients
  ref_n   <- full_n - metab_n
  metab_inds <- (ref_n / 2 + 1):(full_n - ref_n / 2)
  metab <- get_dyns(mrs_data, metab_inds)
  
  ref_inds_start <- 1:(ref_n / 2)
  ref_inds_end   <- ((full_n - ref_n / 2) + 1):full_n
  
  # water ecc inds
  ref_ecc_inds <- c(ref_inds_start[1:(ref_n / 4)],
                    ref_inds_end[1:(ref_n / 4)])
  ref_ecc <- get_dyns(mrs_data, ref_ecc_inds)
  ref_ecc <- set_Ntrans(ref_ecc, Ndyns(ref_ecc))
  ref_ecc$meta$ChemicalShiftReference <- NULL
  
  # water scaling inds
  ref_inds <- c(ref_inds_start[((ref_n / 4) + 1):(ref_n / 2)],
                ref_inds_end[((ref_n / 4) + 1):(ref_n / 2)])
  ref <- get_dyns(mrs_data, ref_inds)
  ref <- set_Ntrans(ref, Ndyns(ref))
  ref$meta$ChemicalShiftReference <- NULL
  
  out <- list(metab = metab, ref = ref, ref_ecc = ref_ecc)
  
  class(out) <- c("list", "mrs_data")
  
  return(out)
}
