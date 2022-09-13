# Install mSigHdp and hdpx version used by this paper,
#  except Nicola Roberts' original hdp package.
#
# NOTE: To run Nicola Roberts' algorithm, please use
# common_code/install_NR_hdp.R
# common_code/generic_run_NR_hdp.R

if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

hdpx.version <- "1.0.5"
if (system.file(package = "hdpx") != "") {
  # Re-install if hdpx fails to be loaded, 
  # or its version does not match hdpx.version
  if (!requireNamespace("hdpx", quietly = TRUE) ||
      packageVersion("hdpx") != hdpx.version) {
    remove.packages("hdpx")
    remotes::install_github(
      "steverozen/hdpx", 
      ref = paste0("v", hdpx.version, "-branch"))
  }
} else {
  # Install directly if not been installed
  remotes::install_github(
    "steverozen/hdpx", 
    ref = paste0("v", hdpx.version, "-branch"))
}
message("hdpx version ", packageVersion("hdpx"))
stopifnot(packageVersion("hdpx") == hdpx.version)

mSigHdp.version <- "2.1.0"
# Re-install if mSigHdp fails to be loaded, 
# or its version does not match mSigHdp.version
if (system.file(package = "mSigHdp") != "") {
  if (!requireNamespace("mSigHdp", quietly = TRUE) || 
      packageVersion("mSigHdp") != mSigHdp.version) {
    remove.packages("mSigHdp")
    remotes::install_github(
      repo = "steverozen/mSigHdp", 
      ref = paste0("v", mSigHdp.version, "-branch"))
  }
} else {
  # Install directly if not been installed
  remotes::install_github(
    repo = "steverozen/mSigHdp", 
    ref = paste0("v", mSigHdp.version, "-branch"))
}
message("mSigHdp version ", packageVersion("mSigHdp"))
stopifnot(packageVersion("mSigHdp") == mSigHdp.version)
