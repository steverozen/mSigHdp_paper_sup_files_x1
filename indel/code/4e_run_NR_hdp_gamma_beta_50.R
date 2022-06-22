# How to run:
# $ nice Rscript indel/code/4e_run_NR_hdp_gamma_beta_50.R <seed> >& indel/raw_results/NR_hdp_gamma_beta_50/log &

basedir <- "mSigHdp_paper_sup_files_x1" 
if (basename(getwd()) != basedir) {
  stop("Please run from top level directory, ", basedir)
}

message(Sys.time(), " running ", paste(commandArgs(), collapse = " "))

args <- commandArgs(trailingOnly = TRUE)


if (TRUE) {
seeds_in_use <- args 
} else {
seeds_in_use <- args[2]

home_for_run <- args[1]
}
stop("update the qsub scripts for this")

message(Sys.time(), " running on seed ", seeds_in_use)

# Set global variables ---------------------------------------------------------
GLOBAL.gamma.alpha <- 1  # This will be used inside mSigHdp::SetupAndPosterior;
                         # alpha is also called the shape parameter
GLOBAL.gamma.beta  <- 50 # This will be used inside mSigHdp::SetupAndPosterior;
                         # beta is also called the rate parameter
burnin.iterations  <- 5000 * 6
CPU.cores          <- 20
num.child.process  <- 20
# Guessed number of raw clusters
start_K            <- 22

home_for_run       <- paste0("./indel/raw_results/NR_hdp_gamma_beta_", 
                             GLOBAL.gamma.beta)
home_for_data      <- "./indel/input"

# Names of data sets
# dataset_names <- c("Noiseless", "Moderate", "Realistic")
dataset_names <- c("Realistic")



# Run mSigHdp -----------------------------------------------------------------
# Install and load package versions to test Nicola Roberts's algorithms 
source("common_code/generic_run_NR_hdp.R")
