read_mrs_nifti <- function(fname, extra, verbose) {
  
  fname_low <- tolower(fname)
  
  # check the file extension is sensible
  if (!stringr::str_ends(fname_low, ".nii.gz") &
      !stringr::str_ends(fname_low, ".nii")) {
    stop("filename argument must end in .nii.gz or .nii")
  }
  
  # check file exists
  if (!file.exists(fname)) {
    cat(fname)
    stop("File not found.")
  } 
  
  # read the nifti file
  nii_data <- RNifti::readNifti(fname)
  
  # get the dimensions
  pixdim <- nii_data$pixdim
  
  # read array values 
  data <- nii_data[]
  
  # add any missing dimensions
  if (length(dim(data)) < 6) {
    zero_dims <- rep(1, 6 - length(dim(data)))
    dim(data) <- c(dim(data), zero_dims)
  }
  
  # reorder the dimensions
  # NIFTI default dimension ordering is X, Y, Z, FID, coil, dynamic, indirect
  # spant default dimension ordering is (dummy,) X, Y, Z, dynamic, coil, FID 
  data <- aperm(data, c(1, 2, 3, 6, 5, 4)) 
  
  # add a dummy dimension
  dim(data) <- c(1, dim(data))
  
  ext_char <- RNifti::extension(readNifti(fname), 44, "character")
  
  if (is.null(ext_char)) stop("NIfTI extension header for MRS not found.")
  
  # if sidecar exists read json_data from here, otherwise use nifti header
  # construct path
  json_fname <- sub('\\.gz$', '', fname) 
  json_fname <- sub('\\.nii$', '', json_fname) 
  json_fname <- paste0(json_fname, ".json")
  
  if (file.exists(json_fname)) {
    if (verbose) {
      message("JSON sidecar found, reading metadata from here.")
    }
    json_data <- jsonlite::fromJSON(json_fname)
  } else {
    if (verbose) {
      message("JSON sidecar not found, reading metadata from NIfTI header.")
    }
    json_data <- jsonlite::fromJSON(ext_char)
  }
  
  if (!is.null(json_data$dim_5)) {
    if (json_data$dim_5 != "DIM_COIL") warning("Unsupported NIfTI MRS dimension 5.")
  }
  
  if (!is.null(json_data$dim_6)) {
    if (json_data$dim_6 != "DIM_DYN") warning("Unsupported NIfTI MRS dimension 6.")
  }
  
  if (!is.null(json_data$dim_7)) warning("Unsupported NIfTI MRS dimension 7.")
  
  # read voxel dimensions, dwell time and time between dynamic scans
  res <- c(NA, pixdim[2], pixdim[3], pixdim[4], pixdim[6], NA, pixdim[5])
  
  # affine and position information
  xform_mat <- RNifti::xform(nii_data)
  col_vec <- xform_mat[1:3, 1] / sum(xform_mat[1:3, 1] ^ 2) ^ 0.5 * c(-1, -1, 1)
  row_vec <- xform_mat[1:3, 2] / sum(xform_mat[1:3, 2] ^ 2) ^ 0.5 * c(-1, -1, 1)
  sli_vec <- crossprod_3d(row_vec, col_vec)
  pos_vec <- xform_mat[1:3, 4] * c(-1, -1, 1)
  affine  <- xform_mat
  
  attributes(affine) <- list(dim = dim(affine))
  
  # freq domain vector vector
  freq_domain <- rep(FALSE, 7)

  # if (is.null(json_data$EchoTime)) {
  #   te <- json_data$EchoTime
  # } else {
  #   te <- json_data$EchoTime / 1e3
  # }
  
  ft <- json_data$SpectrometerFrequency * 1e6
  
  # read the nucleus
  nuc <- json_data$ResonantNucleus
  
  
  if (is.null(json_data$ChemicalShiftOffset)) {
    # TODO get default ref from a lookup table of defaults depending on "nuc"
    # when value isn't found
    ref <- def_ref()
  } else {
    ref <- json_data$ChemicalShiftOffset
  }
  
  # get all metadata
  meta <- json_data
  
  # remove any data that is explicitly part of the mrs_data structure
  meta$SpectrometerFrequency <- NULL
  meta$ResonantNucleus       <- NULL
  
  # remove any metadata that is directly derived from the mrs_data structure
  meta$SpectralWidth          <- NULL
  meta$NumberOfSpectralPoints <- NULL
  meta$AcquisitionVoxelSize   <- NULL
  meta$ChemicalShiftOffset    <- NULL
  meta$RepetitionTime         <- NULL
  
  # meta$NumberOfTransients <- NULL
  
  mrs_data <- mrs_data(data = data, ft = ft, resolution = res, ref = ref,
                       nuc = nuc, freq_domain = freq_domain, affine = affine,
                       meta = meta, extra = extra)
  
  return(mrs_data)
}