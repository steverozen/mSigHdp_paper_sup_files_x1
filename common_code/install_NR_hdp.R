# Install and load package versions to test Nicola Roberts's algorithms 

if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

# Always install the version of hdpx and mSigHdp with the Nicola
# Roberts algorithm for combining raw clusters into signatures
hdpx.version <- "0.1.5.0099"
if (system.file(package = "hdpx") != "") {
  if (packageVersion("hdpx") != hdpx.version) {
    remove.packages("hdpx")
    remotes::install_github("steverozen/hdpx", ref = "NR-version-plus-fixes")
  }
} else {
  remotes::install_github("steverozen/hdpx", ref = "NR-version-plus-fixes")
}
message("hdpx version ", packageVersion("hdpx"))
stopifnot(packageVersion("hdpx") == hdpx.version)

mSigHdp.version <- "0.0.0.9019"
if (system.file(package = "mSigHdp") != "") {
  if (packageVersion("mSigHdp") != mSigHdp.version) {
    remove.packages("mSigHdp")
    remotes::install_github(repo = "steverozen/mSigHdp", 
                            ref = "for-NR-version-plus-fixes")
  }
} else {
  remotes::install_github(repo = "steverozen/mSigHdp", 
                          ref = "for-NR-version-plus-fixes")
}
message("mSigHdp version ", packageVersion("mSigHdp"))
stopifnot(packageVersion("mSigHdp") == mSigHdp.version)
