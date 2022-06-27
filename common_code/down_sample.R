# This file should be sourced from
# common_code/down_sample.Rmd
###########################################################################

#' Down sampling one positive integer value.
down_sample_one_val <- function(x, thres = 1000L) {
  if (x <= thres) {
    return(x)
  } else {
    return(ceiling(min(x, thres + 3000 * log10(x/thres))))
  }
}


#' Down-sampling a set of mutational spectra
#' 
#' @param spec Input spectra. Expects an ICAMS spectra catalog object
#' @param exp Input exposure matrix imported by \code{mSigAct::ReadExposure()}
#' @param thres_val Value of minimum number to start down-sampling
#' Used for argument \code{thres} for function \code{down_sample_one_val}
#' 
#' @importFrom magrittr %>%
down_samp <- function(spec, exp, thres_val) {
  
  exp_sum <- colSums(exp)
  # Print the number of samples with mutations smaller than thres_val
  which(exp_sum <= thres_val) %>% length() %>% print()
  down_exp_sum <- sapply(exp_sum, down_sample_one_val, thres = thres_val)
  down_factor <- down_exp_sum / exp_sum
  
  # Generate down-sampled exposure --------------------------------------------
  down_exp <- (t(exp) * down_factor) %>% t() %>% as.data.frame()
  foo <- sapply(down_exp, round)
  foo <- foo %>% as.data.frame()
  dimnames(foo) <- dimnames(exp)
  down_exp <- foo
  rm(foo)
  mSigAct::WriteExposure(
    exposure = down_exp,
    file = paste0(dataset_path, "/ground.truth.syn.exposures.csv"))
  
  # Generate down-sampled spectra ---------------------------------------------
  down_spec <-(t(spec) * down_factor) %>% t() %>% as.data.frame()
  foo <- sapply(down_spec, round)
  foo <- foo %>% as.data.frame()
  dimnames(foo) <- dimnames(spec)
  down_spec <- ICAMS::as.catalog(foo, ref.genome = "GRCh37",
                                 region = "genome",
                                 catalog.type = "counts")
  rm(foo)
  
  # Return down-sampled exposures and spectra ---------------------------------
  retval <- list(down_exp = down_exp, down_spec = down_spec)
}