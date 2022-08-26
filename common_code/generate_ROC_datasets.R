basedir <- "mSigHdp_paper_sup_files_x1" 
if (basename(getwd()) != basedir) {
  stop("Please run from top level directory, ", basedir)
}

spike.in.sig <- "SBS35"

which.set <- "SBS_set1/input/Realistic"
exposures <- mSigTools::read_exposure(
  file.path(which.set, "ground.truth.syn.exposures.csv"))
signatures <- ICAMS::ReadCatalog(
  file.path(which.set, "ground.truth.syn.sigs.csv"))
spectra <- ICAMS::ReadCatalog(
  file.path(which.set, "ground.truth.syn.catalog.csv"))

with.sig <- which(exposures[spike.in.sig, ] > 0)

with.sig.exp <- (exposures[spike.in.sig, with.sig])

mean.exp <- mean(with.sig.exp)
sd.exp   <- sd(with.sig.exp)
spectra.no.target.sig <- spectra[ , - with.sig]

# create 100 partial spectra of spike.in.sig according to mean.exp and sd.exp 

spike.sig.profile <- signatures[ , spike.in.sig, drop = FALSE]

set.seed(1066)
sig.counts <- rnorm(n = 108, mean = mean.exp, sd = sd.exp)
low.counts <- which(sig.counts < 100)

sig.counts <- sig.counts[-low.counts]

# Partial spectru due to the spiked in signature
spike.partial.spectra <- round(spike.sig.profile %*% sig.counts)

# Nanhai, how do you recommend we add noise to the spike.partial.spectra? 
 

one_spike_set <- function(num.spiked, out.file.name) {
  
  indices.to.spike  <- # num.spiked column indices of spectra.no.target.sig 
    sample(x = ncol(spectra.no.target.sig), size = num.spiked, replace = FALSE)
  
  new.spectra <- spectra.no.target.sig
  
  partial.spectra.indices.to.use <- # num.spiked column indices of spike.partial.spectra
    sample(x = ncol(spike.partial.spectra), size = num.spiked, replace = FALSE)
  
  new.spectra[  , indices.to.spike] <- 
    new.spectra[ , indices.to.spike] + 
    spike.partial.spectra[, partial.spectra.indices.to.use]
  
  ICAMS::WriteCatalog(new.spectra, out.file.name)
  
  return(new.spectra)
}

s100 <- one_spike_set(100, "ROC_SBS_100.csv")
s50  <- one_spike_set(50, "ROC_SBS_50.csv")
s30  <- one_spike_set(30, "ROC_SBS_30.csv")
s20  <- one_spike_set(20, "ROC_SBS_20.csv")
s10  <- one_spike_set(10, "ROC_SBS_10.csv")
s5   <- one_spike_set(5,  "ROC_SBS_5.csv")

