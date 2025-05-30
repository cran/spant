# constructor for mrs_data
mrs_data <- function(data, ft, resolution, ref, nuc, freq_domain, affine,
                     meta, extra) {
  
  mrs_data <- list(data = data, ft = ft, resolution = resolution, ref = ref,
                   nuc = nuc, freq_domain = freq_domain, affine = affine,
                   meta = meta, extra = extra)
  
  class(mrs_data) <- "mrs_data"
  return(mrs_data)
}

#' Read MRS data from the filesystem.
#' @param path file name or directory containing the MRS data.
#' @param format string describing the data format. Must be one of the 
#' following : "spar_sdat", "rda", "dicom", "twix", "pfile", "list_data",
#' "paravis", "dpt", "lcm_raw", "rds", "nifti", "varian", "jmrui_txt". If not 
#' specified, the format will be guessed from the filename extension, or will
#' be assumed to be a Siemens ima dynamic data if the path is a directory.
#' @param ft transmitter frequency in Hz (required for list_data format).
#' @param fs sampling frequency in Hz (required for list_data format).
#' @param ref reference value for ppm scale (required for list_data format).
#' @param n_ref_scans override the number of water reference scans detected in
#' the file header (GE p-file only).
#' @param full_fid export all data points, including those before the start
#' of the FID (default = FALSE), TWIX format only.
#' @param omit_svs_ref_scans remove any reference scans sometimes saved in
#' SVS twix data (default = TRUE).
#' @param verbose print data file information (default = FALSE).
#' @param extra an optional data frame to provide additional variables for use
#' in subsequent analysis steps, eg id or grouping variables.
#' @param fid_filt_dist indicate if the data has a distorted FID due to a 
#' brick-wall filter being used to downsample the data. Default is to auto
#' detect this from the data, but TRUE or FALSE options can be given to override
#' detection.
#' @return MRS data object.
#' @examples
#' fname <- system.file("extdata", "philips_spar_sdat_WS.SDAT", package = "spant")
#' mrs_data <- read_mrs(fname)
#' print(mrs_data)
#' @export
read_mrs <- function(path, format = NULL, ft = NULL, fs = NULL, ref = NULL,
                     n_ref_scans = NULL, full_fid = FALSE,
                     omit_svs_ref_scans = TRUE, verbose = FALSE,
                     extra = NULL, fid_filt_dist = NULL) {
  
  # glob the input and check the result is sane
  path <- Sys.glob(path)
  
  if (length(path) == 0) stop("Error, read_mrs file not found.")
  
  if (length(path) > 1) {
    return(lapply(path, read_mrs, format = format, ft = ft, fs = fs, ref = ref,
                  n_ref_scans = n_ref_scans, full_fid = full_fid,
                  omit_svs_ref_scans = omit_svs_ref_scans, verbose = verbose,
                  extra = extra, fid_filt_dist = fid_filt_dist))
  }
  
  if (!file.exists(path)) stop("Error, read_mrs file does not exist.")
  
  if (dir.exists(path)) {
    res <- read_ima_dyn_dir(dir = path, extra = extra, verbose = verbose)
    if (!is.null(fid_filt_dist)) res$meta$fid_filt_dist <- fid_filt_dist
    return(res)
  }
  
  # try and guess the format from the filename extension
  if (is.null(format)) format <- guess_mrs_format(path) 
  
  if (format == "spar_sdat") {
    res <- read_spar_sdat(path, extra)
  } else if (format == "rda") {
    res <- read_rda(path, extra)
  } else if (format == "dicom") {
    res <- read_dicom(path, verbose, extra)
  } else if (format == "twix") {
    res <- read_twix(path, verbose, full_fid, omit_svs_ref_scans, extra)
  } else if (format == "pfile") {
    res <- read_pfile(path, n_ref_scans, verbose, extra)
  } else if (format == "list_data") {
    if (is.null(ft)) stop("Please specify ft parameter for list_data format")
    if (is.null(fs)) stop("Please specify fs parameter for list_data format")
    if (is.null(ref)) stop("Please specify ref parameter for list_data format")
    res <- read_list_data(path, ft, fs, ref, extra)
  } else if (format == "dpt") {
    res <- read_mrs_dpt(path, extra)
  } else if (format == "jmrui_txt") {
    res <- read_mrs_jmrui_txt(path, extra)
  } else if (format == "paravis") {
    res <- read_paravis_raw(path, extra)
  } else if (format == "lcm_raw") {
    if (is.null(ft)) stop("Please specify ft parameter for lcm_raw format")
    if (is.null(fs)) stop("Please specify fs parameter for lcm_raw format")
    if (is.null(ref)) stop("Please specify ref parameter for lcm_raw format")
    res <- read_lcm_raw(path, ft, fs, ref, extra)
  } else if (format == "rds") {
    mrs_data <- readRDS(path)
    mrs_data$extra <- extra
    if (!inherits(mrs_data, "mrs_data")) stop("rds file is not mrs_data format")
    res <- mrs_data
  } else if (format == "nifti") {
    res <- read_mrs_nifti(path, extra, verbose)
  } else if (format == "varian") {
    res <- read_varian(path, extra)
  } else {
    stop("Unrecognised file format.")
  }
  
  if (!is.null(fid_filt_dist)) {
    if (identical(class(res), c("list", "mrs_data"))) {
      res$metab$meta$fid_filt_dist <- fid_filt_dist
      if (!is.null(res$ref)) res$ref$meta$fid_filt_dist <- fid_filt_dist
      if (!is.null(res$ref_ecc)) res$ref_ecc$meta$fid_filt_dist <- fid_filt_dist
    } else {
      res$meta$fid_filt_dist <- fid_filt_dist
    }
  }
  return(res)
}

# try and guess the format from the filename extension
guess_mrs_format <- function(fname) {
  fname_low <- tolower(fname)
  if (stringr::str_ends(fname_low, "\\.nii\\.gz")) {
    format <- "nifti"
  } else if (stringr::str_ends(fname_low, "\\.nii")) {
    format <- "nifti"
  } else if (stringr::str_ends(fname_low, "\\.rda")) {
    format <- "rda"
  } else if (stringr::str_ends(fname_low, "\\.ima")) {
    format <- "dicom"
  } else if (stringr::str_ends(fname_low, "\\.dcm")) {
    format <- "dicom"
  } else if (stringr::str_ends(fname_low, "\\.spar")) {
    format <- "spar_sdat"
  } else if (stringr::str_ends(fname_low, "\\.sdat")) {
    format <- "spar_sdat"
  } else if (stringr::str_ends(fname_low, "\\.7")) {
    format <- "pfile"
  } else if (stringr::str_ends(fname_low, "\\.7\\.anon")) {
    format <- "pfile"
  } else if (stringr::str_ends(fname_low, "\\.list")) {
    format <- "list_data"
  } else if (stringr::str_ends(fname_low, "\\.data")) {
    format <- "list_data"
  } else if (stringr::str_ends(fname_low, "\\.dat")) {
    format <- "twix"
  } else if (stringr::str_ends(fname_low, "\\.dpt")) {
    format <- "dpt"
  } else if (stringr::str_ends(fname_low, "\\.rds")) {
    format <- "rds"
  } else if (stringr::str_ends(fname_low, "\\.raw")) {
    format <- "lcm_raw"
  } else if (stringr::str_ends(fname_low, "\\.txt")) {
    format <- "jmrui_txt"
  } else if (basename(fname_low) == "fid") {
    format <- "varian"
  } else {
    # if all else fails, assume DICOM
    format <- "dicom"
  }
  return(format)
}

#' Write MRS data object to file.
#' @param mrs_data object to be written to file, or list of mrs_data objects.
#' @param fname one or more filenames to output.
#' @param format string describing the data format. Must be one of the 
#' following : "nifti", "dpt", "lcm_raw", "rds". If not specified, the format
#' will be guessed from the filename extension.
#' @param force set to TRUE to overwrite any existing files.
#' @export
write_mrs <- function(mrs_data, fname, format = NULL, force = FALSE) {
  
  # check if any files already exist
  if (!force) {
    if (any(file.exists(fname))) {
      stop("One or more files already exist. Use the  force argment to
            overwrite")
    }
  }
  
  if (inherits(mrs_data, "list")) {
    if (length(fname) != length(mrs_data)) {
      stop("Number of datasets and filenames differ.")
    }
    
    # invisible stops unwanted console output
    return(invisible(mapply(write_mrs, mrs_data = mrs_data, fname = fname, 
           MoreArgs = list(format = format, force = force),
           SIMPLIFY = FALSE)))
  }
  
  if (!inherits(mrs_data, "mrs_data")) stop("data object is not mrs_data format")
  
  # try and guess the format from the filename extension
  if (is.null(format)) format <- guess_mrs_format(fname) 
  
  if (format == "dpt") {
    write_mrs_dpt_v2(fname, mrs_data)
  } else if (format == "lcm_raw") {
    write_mrs_lcm_raw(fname, mrs_data)
  } else if (format == "nifti") {
    write_mrs_nifti(mrs_data, fname)
  } else if (format == "rds") {
    write_mrs_rds(fname, mrs_data)
  } else {
    stop("Unrecognised file format.")
  }
}
 
read_mrs_dpt <- function(fname, extra) {
  header <- utils::read.table(fname, nrows = 15, as.is = TRUE)
  
  # Check dpt version number
  dpt_ver <- header$V2[1]
  if (dpt_ver != "3.0") {
    stop("Error, dangerplot version is not supported (!=3.0).")
  }
  
  N <- as.integer(header$V2[2])
  fs <- as.double(header$V2[3])
  ft <- as.double(header$V2[4])
  phi0 <- as.double(header$V2[5])
  phi1 <- as.double(header$V2[6])
  ref <- as.double(header$V2[7])
  te <- as.double(header$V2[8])
  rows <- as.integer(header$V2[9])
  cols <- as.integer(header$V2[10])
  slices <- as.integer(header$V2[11])
  pix_sp <- header$V2[12]
  
  if (pix_sp == "Unknown") {
    row_dim <- NA
    col_dim <- NA
  } else {
    row_dim <- as.double(strsplit(pix_sp, "\\\\")[[1]][1])
    col_dim <- as.double(strsplit(pix_sp, "\\\\")[[1]][2])
  }
  slice_dim_str <- header$V2[13]
  if (slice_dim_str == "Unknown") {
    slice_dim <- NA
  } else {
    slice_dim <- as.double(slice_dim_str)
  }
  
  if (header$V2[14] == "Unknown") {
    IOP <- NA
  } else {
    IOP <- as.double(strsplit(header$V2[14], "\\\\")[[1]])
  }
  
  if (header$V2[15] == "Unknown") {
    IPP <- NA
  } else {
    IPP <- as.double(strsplit(header$V2[15], "\\\\")[[1]])
  }
  
  if (!is.na(IOP[1])) {
    row_vec <- IOP[1:3]
    col_vec <- IOP[4:6]
  } else {
    row_vec <- NA  
    col_vec <- NA  
  }
  pos_vec <- IPP
  sli_vec <- crossprod_3d(row_vec, col_vec)
  
  # read the data points  
  raw_data <- utils::read.table(fname, skip = 16, as.is = TRUE)
  raw_data_cplx <- raw_data$V1 + raw_data$V2 * 1i
  # construct the data array
  data_arr <- as.array(raw_data_cplx)
  
  # TODO - special case for Philips fMRS
  # (ws,w), x, y, z, t, coil, spec
  dim(data_arr) <- c(1, N, rows, cols, slices, 1, 1)
  data_arr = aperm(data_arr,c(1, 4, 3, 5, 6, 7, 2))
  
  if (dim(data_arr)[2] > 1 && dim(data_arr)[3] == 1) {
    warning("Data is 1D, assuming dynamic MRS format.")
    data_arr = aperm(data_arr,c(1, 5, 3, 4, 2, 6, 7))
  }
  
  # resolution information
  # x, y, z, t, coil, spec
  res <- c(NA, row_dim, col_dim, slice_dim, 1, NA, 1 / fs)
  
  # freq domain vector vector
  freq_domain <- rep(FALSE, 7)
  
  # defaults
  nuc <- def_nuc()
  
  mrs_data <- mrs_data(data = data_arr, ft = ft, resolution = res, ref = ref,
                       nuc = nuc, freq_domain = freq_domain, affine = NULL,
                       meta = NULL, extra = extra)
  
  return(mrs_data)
}

#' Read MRS data using the TARQUIN software package.
#' @param fname the filename containing the MRS data.
#' @param fname_ref a second filename containing reference MRS data.
#' @param format format of the MRS data. Can be one of the following:
#' siemens, philips, ge, dcm, dpt, rda, lcm, varian, bruker, jmrui_txt.
#' @param id optional ID string.
#' @param group optional group string.
#' @return MRS data object.
#' @examples
#' fname <- system.file("extdata","philips_spar_sdat_WS.SDAT",package="spant")
#' \dontrun{
#' mrs_data <- read_mrs_tqn(fname, format="philips")
#' }
#' @export
read_mrs_tqn <- function(fname, fname_ref = NA, format, id = NA, group = NA) {
  # check the input file exists
  if (!file.exists(fname)) {
    print(fname)
    stop("Error, above input file does not exist.")    
  }
  
  # specify some temp file names
  ws_fname <- tempfile()
  ws_fname <- gsub(' ', '" "', ws_fname) # this is for spaces on windows
  w_fname <- tempfile()
  w_fname <- gsub(' ', '" "', w_fname) # this is for spaces on windows
  fname <- gsub(' ', '" "', fname) # this is for spaces on windows
  cmd = paste(getOption("spant.tqn_cmd"), "--input", fname, "--format", format,
                        "--write_raw_v3", ws_fname, "--write_raw_w_v3",
                        w_fname, "--rw_only", "true","--dyn_av","none", 
                        "--dyn_av_w", "none") #,"2>&1")
  
  if (!is.na(fname_ref)) {
    if (!file.exists(fname_ref)) {
      print(fname_ref)
      stop("Error, above input file does not exist.")    
    }
    cmd = paste(cmd, "--input_w", fname_ref)
  }
  
  #cmd = as.character(cat(cmd))
  #print(class(cmd))
  #print(cmd)
  res = system(cmd, intern = TRUE)
  
  if (!file.exists(ws_fname)) {
    print(res)
    print(cmd)
    stop("Error loading data with above TARQUIN command.")
  }
  
  main <- read_mrs_dpt(ws_fname)
  
  if (is.na(id)) {
    id = fname
  }
  
  main$fname = fname
  main$fname_ref = fname_ref
  main$id = id
  main$group = group
  
  if (file.exists(w_fname)) {
    ref <- read_mrs_dpt(w_fname)
    #main$data <- comb_metab_ref(main, ref)
    #main$data <- abind::abind(main$data, ref$data, along=1)
    return(list(metab = main, ref = ref))
  } else {
    return(main)
  }
}

write_mrs_dpt_v2 <- function(fname, mrs_data) {
  sig <- mrs_data$data[1, 1, 1, 1, 1, 1,]
  N <- length(sig)
  fs <- 1 / mrs_data$resolution[7]
  ft <-  mrs_data$ft
  ref <- mrs_data$ref
  te <- mrs_data$meta$te
  sink(fname)
  cat("Dangerplot_version\t2.0\n")
  cat(paste("Number_of_points\t", N, "\n", sep = ""))
  cat(paste("Sampling_frequency\t", fs, "\n", sep = ""))
  cat(paste("Transmitter_frequency\t", ft, "\n", sep = ""))
  cat("Phi0\t0.0\n")
  cat("Phi1\t0.0\n")
  cat(paste("PPM_reference\t", ref, "\n", sep = ""))
  cat(paste("Echo_time\t", te, "\n", sep = ""))
  cat("Real_FID\tImag_FID\n")
  for (n in 1:N) {
    cat(paste(format(Re(sig[n]), scientific = TRUE), "\t", format(Im(sig[n]),
              scientific = TRUE), '\n', sep = ""))
  }
  sink()
}

write_mrs_lcm_raw <- function(fname, mrs_data, id = NA) {
  sig <- mrs_data$data[1, 1, 1, 1, 1, 1,]
  N <- length(sig)
  sink(fname)
  cat(" $NMID\n")
  if (is.na(id)) id <- fname
  cat(paste(" ID='", id, "', FMTDAT='(2E15.6)'\n", sep = ""))
  cat(" VOLUME=1\n")
  cat(" TRAMP=1\n")
  cat(" $END\n")
  for (n in 1:N) {
    cat(" ")
    cat(noquote(formatC(c(Re(sig[n]), Im(sig[n])), width = 14, format = "E",
                          digits = 6)))
    cat("\n")
  }
  sink()
}

write_mrs_rds <- function(fname, mrs_data) {
  if (!inherits(mrs_data, "mrs_data")) {
    stop("data object is not mrs_data format")
  }
  saveRDS(mrs_data, fname)
}