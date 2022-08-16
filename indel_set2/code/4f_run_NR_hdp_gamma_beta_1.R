# How to run:
# $ nice Rscript indel_2/code/4f_run_NR_hdp_gamma_beta_1.R <seed> >>& indel_2/raw_results/NR_hdp_gb_1.results/log &

basedir <- "mSigHdp_paper_sup_files_x1" 
if (basename(getwd()) != basedir) {
  stop("Please run from top level directory, ", basedir)
}

message(Sys.time(), " running ", paste(commandArgs(), collapse = " "))

args <- commandArgs(trailingOnly = TRUE)

if (length(args) > 0) {
  seeds_in_use <- args
} else {
  seeds_in_use <- c(145879, 200437, 310111, 528401, 1076753)
}

message(Sys.time(), " running on seed ", seeds_in_use)

# Set global variables ---------------------------------------------------------
GLOBAL.gamma.alpha <- 1  # This will be used inside mSigHdp::SetupAndPosterior;
                         # alpha is also called the shape parameter
GLOBAL.gamma.beta  <- 1  # This will be used inside mSigHdp::SetupAndPosterior;
                         # beta is also called the rate parameter;
                         # for selection of 1 see page 132 of 
                         # https://www.repository.cam.ac.uk/bitstream/handle/1810/275454/Roberts-2018-PhD.pdf,
                         # and also page 161
                         
burnin.iterations  <- 5000 * 6
CPU.cores          <- 20
num.child.process  <- 20
# Guessed number of raw clusters
start_K            <- 26

home_for_run       <- paste0("./indel_2/raw_results/NR_hdp_gb_", 
                             GLOBAL.gamma.beta, ".results/")
home_for_data      <- "./indel_2/input"

# Names of data sets
dataset_names <- c("Realistic", "Noiseless")


# Run mSigHdp -----------------------------------------------------------------
# Install and load package versions to test Nicola Roberts's algorithms 
source("common_code/generic_run_NR_hdp.R")
