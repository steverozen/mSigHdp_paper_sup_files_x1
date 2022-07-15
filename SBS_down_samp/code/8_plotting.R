# Please run this script from the top directory
if (basename(getwd()) != "mSigHdp_paper_sup_files_x1") {
  stop("Please run from top level directory, mSigHdp_paper_sup_files_x1")
}

home_for_data <- "./SBS_down_samp/input/"
home_for_summary <- "./SBS_down_samp/summary/"
plot.meta.info <- paste("SBS_down_samp",
                        Sys.Date(), 
                        "down-sampled from 'Realistic' data set with size = 30; gamma.beta = 20, burnin = 100k")
dataset_names <- c("1k", "3k", "5k", "10k")
tool_names <- c("mSigHdp", "SigProfilerExtractor")

source("common_code/main_text_plotting_down_samp.R")
