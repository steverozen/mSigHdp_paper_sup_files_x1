# Please run this script from the top directory
if (basename(getwd()) != "mSigHdp_paper_sup_files_x1") {
  stop("Please run from top level directory, mSigHdp_paper_sup_files_x1")
}

home_for_data <- "./indel_2_down_samp/input/"
home_for_summary <- "./indel_2_down_samp/summary/"
plot.meta.info <- paste("indel_2_down_samp",
                        Sys.Date(), 
                        "down-sampled from 'Realistic' data set with size = 10; gamma.beta = 50, burnin = 30k")
dataset_names <- c("1k", "3k", "5k", "10k", "non_hyper")
tool_names <- "mSigHdp"

source("common_code/main_text_plotting_down_samp.R")
