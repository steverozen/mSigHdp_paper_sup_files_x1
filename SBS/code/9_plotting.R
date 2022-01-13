# Please run this script from the top directory
if (basename(getwd()) != "Liu_et_al_Sup_Files") {
  stop("Please run from top level directory, Liu_et_al_Sup_Files")
}

home_for_data <- "./SBS/input/"
home_for_summary <- "./SBS/summary/"
plot.meta.info <- paste("SBS",
                        Sys.Date(), 
                        "Realistic size = 30; gamma.beta = 20, burnin = 100k")

source("common_code/main_text_plotting.R")
