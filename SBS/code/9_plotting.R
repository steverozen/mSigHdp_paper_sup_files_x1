# Please run this script from the top directory
if (basename(getwd()) != "mSigHdp_paper_sup_files_x1") {
  stop("Please run from top level directory, mSigHdp_paper_sup_files_x1")
}

home_for_data <- "./SBS/input/"
home_for_summary <- "./SBS/summary/"
plot.meta.info <- paste("SBS",
                        Sys.Date(), 
                        "Realistic size = 30; gamma.beta = 20, burnin = 100k")
# Note: mSigHdp_ds_10k is listed as the first program,
# becasue down-sampling makes mSigHdp to have the BEST
# extraction accuracy on data set SBS/Realistic.
if (FALSE) {
  tool_names <- c("mSigHdp_ds_10k", "mSigHdp",
                  "SigProfilerExtractor",
                  "SignatureAnalyzer", "signeR",
                  "NR_hdp_gb_1", "NR_hdp_gb_20")
} else {
  tool_names <- c("mSigHdp_ds_10k", "mSigHdp",
                  "SigProfilerExtractor",
                 "SignatureAnalyzer", "signeR",
                 "NR_hdp_gb_20")
}

source("common_code/plotting.R")
