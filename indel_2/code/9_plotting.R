# Please run this script from the top directory
if (basename(getwd()) != "mSigHdp_paper_sup_files_x1") {
  stop("Please run from top level directory, mSigHdp_paper_sup_files_x1")
}

home_for_data <- "./indel_2/input/"
home_for_summary <- "./indel_2/summary/"
plot.meta.info <- paste("indel_2",
                        Sys.Date(), 
                        "Realistic size = 10; gamma.beta = 50, burnin = 30k")
tool_names <- c("mSigHdp", "SigProfilerExtractor",
                "SignatureAnalyzer", "signeR")

source("common_code/main_text_plotting.R")
