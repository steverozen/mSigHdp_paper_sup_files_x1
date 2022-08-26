spike.in.sig <- "SBS38"

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

# create 100 partial spectra of sig according to mean.exp and sd.exp and
# add noise
# 
# select 100 tumors to add the spectra to
#
# (spike100)
# 
# Remove additional spectra from 50 the tumors
#
# (spike50)
#
# Remove add ... etc etc.


