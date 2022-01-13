# Please run this script from the top directory
if (basename(getwd()) != "Liu_et_al_Sup_Files") {
  stop("Please run from top level directory, Liu_et_al_Sup_Files")
}

home_for_data <- "./indel/input/"
home_for_summary <- "./indel/summary/"
plot.meta.info <- paste("indel",
                        Sys.Date(), 
                        "Realistic size = 10; gamma.beta = 50, burnin = 30k")

source("common_code/main_text_plotting.R")
