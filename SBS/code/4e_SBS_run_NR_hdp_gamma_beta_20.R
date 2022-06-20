# How to run:
# $ nice Rscript SBS/code/4e_SBS_run_NR_hdp_gamma_beta_20.R >& SBS/raw_results/NR_hdp_gamma_beta_20/log &

basedir <- "mSigHdp_paper_sup_files_x1" 
if (basename(getwd()) != basedir) {
  stop("Please run from top level directory, ", basedir)
}

# Set global variables ---------------------------------------------------------
GLOBAL.gamma.alpha <- 1  # This will be used inside mSigHdp::SetupAndPosterior;
                         # alpha is also called the shape parameter
GLOBAL.gamma.beta  <- 20 # This will be used inside mSigHdp::SetupAndPosterior;
                         # beta is also called the rate parameter
                         
burnin.iterations  <- 5000 * 20
CPU.cores          <- 20
num.child.process  <- 20
# Guessed number of raw clusters
start_K            <- 46

home_for_run       <- paste0("./SBS/raw_results/NR_hdp_gamma_beta_", 
                             GLOBAL.gamma.beta)
home_for_data      <- "./SBS/input"

# Names of data sets
# dataset_names <- c("Noiseless", "Moderate", "Realistic")
dataset_names <- c("Realistic")

# Specify 5 seeds used in software running
seeds_in_use <- c(145879) # , 200437, 310111, 528401, 1076753)

# Run mSigHdp -----------------------------------------------------------------
# Install and load package versions to test Nicola Roberts's algorithms 
source("common_code/generic_run_NR_hdp.R")
