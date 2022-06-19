# Install and load package versions to test Nicola Roberts's algorithms 

if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

# Always install the version of hdpx and mSigHdp with the Nicola
# Roberts algorithm for combining raw clusters into signatures
if (requireNamespace("hdpx", quietly = TRUE)) {
  if (packageVersion("hdpx") != "0.1.5.0099") {
    remove.package("hdpx")
    remotes::install_github("steverozen/hdpx", ref = "NR-version-plus-fixes")
  }
} else {
  remotes::install_github("steverozen/hdpx", ref = "NR-version-plus-fixes")
}
stopifnot(packageVersion("hdpx") == "0.1.5.0099")

if (requireNamespace("mSigHdp")) {
  if (packageVersion("mSigHdp") != "0.0.0.9015") {
    remove.packages("mSigHdp")
    remotes::install_github(repo = "steverozen/mSigHdp", 
                            ref = "for-NR-version-with-fixes")
  }
} else {
  remotes::install_github(repo = "steverozen/mSigHdp", 
                          ref = "for-NR-version-with-fixes")
}
stopifnot(packageVersion("mSigHdp") == "0.0.0.9015")

# ICAMS is installed when installing mSigHdp
require(ICAMS)
require(hdpx)
require(mSigHdp)
