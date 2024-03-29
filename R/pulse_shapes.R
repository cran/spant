#' Generate a gaussian pulse shape.
#' @param angle pulse angle in degrees.
#' @param n number of points to generate.
#' @param trunc percentage truncation factor.
#' @export
get_guassian_pulse <- function(angle, n, trunc = 1) {
  T = 1
  t <- seq(from = -T / 2, to = T / 2, length.out = n)
  beta <- -log(trunc / 100)
  B <- exp(-beta * (2 * t / T) ^ 2)
  B <- B / sum(B) * pi * angle / 180
  B
}

#' Read a .pta formatted pulse file compatible with Siemens PulseTool.
#' @param fname pta formatted pulse file path.
#' @return pulse waveform and header.
#' @export
read_pulse_pta <- function(fname) {
  con <- file(fname, "r")
  header <- utils::read.table(con, nrows = 8, sep = ":", strip.white = TRUE)
  suppressWarnings(header$V3 <- as.numeric(header$V2))
  is_txt <- is.na(header$V3)
  header_txt <- stats::setNames(as.list(header$V2[is_txt]), header$V1[is_txt])
  header_num <- stats::setNames(as.list(header$V3[!is_txt]), header$V1[!is_txt])
  header_out <- c(header_txt, header_num)
  pulse  <- utils::read.table(con)
  close(con)
  pulse  <- pulse[, 1:2]
  colnames(pulse) <- c("mag", "pha")
  return(list(data = pulse, header = header_out))
}

#' Read an ASCII formatted pulse file.
#' @param fname ASCII formatted pulse file path. 
#' @param deg2rad convert phase values stored in degrees to radians.
#' @return pulse waveform and header.
#' @export
read_pulse_ascii <- function(fname, deg2rad = TRUE) {
  data <- utils::read.table(fname, col.names = c("mag", "pha"))
  
  if (deg2rad) data$pha <- data$pha * pi / 180
  
  return(list(data = data, header = NULL))
}

#' Write an ASCII formatted pulse file.
#' @param pulse pulse data object.
#' @param path file path for export.
#' @export
write_pulse_ascii <- function(pulse, path) {
  utils::write.table(pulse$data, path, row.names = FALSE, col.names = FALSE)
}

#' Read a Bruker formatted pulse file
#' @param fname Bruker formatted pulse file path.
#' @return pulse waveform and header.
#' @export
read_pulse_bruker <- function(fname) {
  lines <- readLines(fname, warn = FALSE)
  
  headerN <- which(startsWith(lines, "##XYPOINTS"))
  
  pulse <- utils::read.table(text = lines, sep = ",", skip = headerN)
  
  colnames(pulse) <- c("mag", "pha")
  header_out <- utils::read.table(text = lines, nrows = (headerN - 1),
                                  sep = "=", comment.char = "")
  
  pulse$pha <- pulse$pha / 180 * pi
  
  return(list(data = pulse, header = header_out))
}