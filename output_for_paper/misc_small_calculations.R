# Small calculations cited in the text



sset1 <- ICAMS::ReadCatalog("SBS_set1/input/Realistic/ground.truth.syn.catalog.csv")
sset2 <- ICAMS::ReadCatalog("SBS_set2/input/Realistic/ground.truth.syn.catalog.csv")
sum(sset2) / sum(sset1)
sum(mSigHdp::downsample_spectra(sset2, downsample_threshold = 3000)[[1]]) /
  sum(mSigHdp::downsample_spectra(sset1, downsample_threshold = 3000)[[1]])
