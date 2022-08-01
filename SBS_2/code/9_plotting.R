# Please run this script from the top directory
if (basename(getwd()) != "mSigHdp_paper_sup_files_x1") {
  stop("Please run from top level directory, mSigHdp_paper_sup_files_x1")
}

home_for_data <- "./SBS_2/input/"
home_for_summary <- "./SBS_2/summary/"
plot.meta.info <- paste("SBS_2",
                        Sys.Date(), 
                        "Realistic size = 30; gamma.beta = 20, burnin = 100k")
if (FALSE) {
  tool_names <- c("mSigHdp", "SigProfilerExtractor",
                  "SignatureAnalyzer", "signeR")
} else {
  tool_names <- c("SigProfilerExtractor",
                 "SignatureAnalyzer", "signeR")
}

source("common_code/plotting.R")
