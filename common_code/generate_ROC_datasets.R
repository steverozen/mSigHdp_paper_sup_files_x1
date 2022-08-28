basedir <- "mSigHdp_paper_sup_files_x1" 
if (basename(getwd()) != basedir) {
  stop("Please run from top level directory, ", basedir)
}

library(ICAMS)
library(mSigTools)
library(fitdistrplus)
library(PCAWG7)

# Create 6 synthetic data set directories with names of the form
# ROC_<spike_sig_id>_<num_spiked_samples>_seed, along with the
# the input/Realistic/ground.truth.syn.catalog.csv file with the
# spiked synthetic signatures.

generate_spiked_data_sets <- function(
    spike.in.sig = "SBS35",
    which.set    = "SBS_set1/input/Realistic",
    exposures    = mSigTools::read_exposure(
      file.path(which.set, "ground.truth.syn.exposures.csv")),
    rand.seed    = 1066)
  {
  
  signatures = ICAMS::ReadCatalog(
    file.path(which.set, "ground.truth.syn.sigs.csv"))
  
  spectra <- ICAMS::ReadCatalog(
    file.path(which.set, "ground.truth.syn.catalog.csv"))
  
  spectra.no.target.sig <- spectra[ , -(which(exposures[spike.in.sig, ] > 0))]
  
  p7.exp <- PCAWG7::exposure$PCAWG$SBS96[spike.in.sig,  , drop = FALSE]
  ot.exp <- PCAWG7::exposure$other.genome$SBS96[spike.in.sig,  , drop = FALSE]
  with.sig.exp <- c(p7.exp[p7.exp > 0], ot.exp[ot.exp > 9])
  
  # Get maximum likelihood estimates of parameters from negative binomial
  # distribution
  fit <- fitdistrplus::mledist(with.sig.exp, distr = "nbinom")
  
  mu.exp <- fit$estimate[2]
  size.exp <- fit$estimate[1]
  
  spike.sig.profile <- signatures[ , spike.in.sig, drop = FALSE]
  
  set.seed(rand.seed)
  sig.counts <- stats::rnbinom(n = 120, size = size.exp, mu = mu.exp)
  low.counts <- which(sig.counts < 100)
  if (length(low.counts) > 0) {
    sig.counts <- sig.counts[-low.counts]
  }
  stopifnot(length(sig.counts) >= 100)
  sig.counts <- sig.counts[1:100]
  
  # Partial spectra due to the spiked in signature
  spike.partial.spectra <- round(spike.sig.profile %*% sig.counts)
  
  # Use the same dispersion parameter for adding noise to previous SBS data
  n.binom.size <- 30 
  
  noised.vec <-
    stats::rnbinom(n = length(spike.partial.spectra), 
                   size = n.binom.size, 
                   mu = spike.partial.spectra)
  
  # Turn the vector back into a matrix
  noisy.spike.partial.spectra <- 
    matrix(noised.vec, nrow = nrow(spike.partial.spectra))
  rownames(noisy.spike.partial.spectra) <- rownames(spike.partial.spectra)
  
  one_spike_set <- function(num.spiked) {
    
    indices.to.spike  <- # num.spiked column indices of spectra.no.target.sig 
      sample(x = ncol(spectra.no.target.sig),
             size = num.spiked, 
             replace = FALSE)
    message("Spiking ", length(indices.to.spike), " spectra")
    
    new.spectra <- spectra.no.target.sig
    
    partial.spectra.indices.to.use <- # num.spiked column indices of spike.partial.spectra
      sample(x = ncol(noisy.spike.partial.spectra),
             size = num.spiked, 
             replace = FALSE)
    
    new.spectra[  , indices.to.spike] <- 
      new.spectra[ , indices.to.spike] + 
      noisy.spike.partial.spectra[, partial.spectra.indices.to.use]
    
    
    out.dir.name <- paste0("ROC_", spike.in.sig, "_", num.spiked, "_", rand.seed)
    new.dir <- file.path(out.dir.name, "input", "Realistic")
    if (!dir.exists(new.dir)) {
      dir.create(new.dir, recursive = TRUE)
    }
    
    ICAMS::WriteCatalog(new.spectra,
                        file.path(new.dir, "ground.truth.syn.catalog.csv"))
    # Wu Yang, please add code to create sigpro input
    ICAMS::WriteCatalog(signatures, "ground.truth.syn.sigs.csv")
    
    cairo_pdf(file.path(new.dir, "spike_in_exposure_dist.pdf"))
    par(mfrow = c(2, 1))
    br <- seq(0, max(with.sig.exp, sig.counts + 200), by = 200)
    hist(with.sig.exp, breaks = br, main = "real exposures")
    hist(sig.counts, breaks = br, main = "synthetic exposures")
    dev.off()
    
    return(new.spectra)
  }
  
  spiked.counts <- c(100, 50, 30, 20, 10, 5)
  invisible(lapply(spiked.counts, one_spike_set))
}

generate_spiked_data_sets()
