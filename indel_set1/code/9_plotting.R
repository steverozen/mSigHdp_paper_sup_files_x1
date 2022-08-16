# Please run this script from the top directory
if (basename(getwd()) != "mSigHdp_paper_sup_files_x1") {
  stop("Please run from top level directory, mSigHdp_paper_sup_files_x1")
}

home_for_data <- "./indel/input/"
home_for_summary <- "./indel/summary/"
plot.meta.info <- paste("indel",
                        Sys.Date(), 
                        "Realistic size = 10; gamma.beta = 50, burnin = 30k")
# Note: mSigHdp_ds_10k is listed as the second program,
# becasue down-sampling makes mSigHdp to have WORSE
# extraction accuracy on data set SBS/Realistic.
tool_names <- c("mSigHdp", "mSigHdp_ds_5k",
                "SigProfilerExtractor",
                "SignatureAnalyzer", "signeR",
                "NR_hdp_gb_1", "NR_hdp_gb_50")

source("common_code/plotting.R")
