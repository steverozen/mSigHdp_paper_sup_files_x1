# This file should be sourced from
# common_code/down_sample.Rmd
###########################################################################

down_sample_func <- function(x, thres = 1000L) {
  if (x <= thres) {
    return(x)
  } else {
    return(ceiling(min(x, thres + 3000 * log10(x/thres))))
  }
}