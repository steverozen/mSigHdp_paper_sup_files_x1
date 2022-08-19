# Please run this script from the top directory
if (basename(getwd()) != "Liu_et_al_Sup_Files") {
  stop("Please run from top level directory, Liu_et_al_Sup_Files")
}

#################################################################
##                 Install dependency packages                 ##
#################################################################
pkg_names <- c("remotes", "dplyr", "ggpubr", "gridExtra")
is_installed <- pkg_names %in% rownames(installed.packages())
if (any(!is_installed)) {
  install.packages(pkg_names[!is_installed])
}

if (!requireNamespace("cosmicsig", quietly = TRUE)) {
  remotes::install_github(repo = "Rozen-Lab/cosmicsig", ref = "v1.0.7-branch")
}

if (!requireNamespace("ICAMS", quietly = TRUE)) {
  remotes::install_github("steverozen/ICAMS", ref = "v3.0.5-branch")
}

if (!requireNamespace("PCAWG7", quietly = TRUE) ||
    packageVersion("PCAWG7") < "0.1.3") {
  remotes::install_github(
    repo = "steverozen/PCAWG7",
    ref = "v0.1.3-branch"
  )
}

if (!requireNamespace("mSigAct", quietly = TRUE) ||
    packageVersion("mSigAct") < "2.2.0") {
  remotes::install_github(
    repo = "steverozen/mSigAct",
    ref = "v2.2.0-branch"
  )
}

if (!requireNamespace("SynSigGen", quietly = TRUE) ||
    packageVersion("SynSigGen") < "1.1.1") {
  remotes::install_github(
    repo = "steverozen/SynSigGen",
    ref = "1.1.1-branch"
  )
}

# Restart R after installing the new packages
.rs.restartR()

source("./common_code/data_gen_utils.R")

library(dplyr)
library(ggpubr)
library(gridExtra)
library(cosmicsig)
library(ICAMS)
library(PCAWG7)
library(mSigAct)
library(SynSigGen)

# Get the real exposure for tumors from nine cancer types: "Breast-AdenoCA",
# "ColoRect-AdenoCA", "Eso-AdenoCA", "Kidney-RCC", "Liver-HCC", "Lung-AdenoCA",
# "Ovary-AdenoCA", "Skin-Melanoma", "Stomach-AdenoCA"
real_exposure_sbs_file <-
  "./other_analyses/noise_selection/data/SBS_real_exposure.csv"
real_exposure_sbs <- mSigAct::ReadExposure(file = real_exposure_sbs_file)
sigs_sbs <- cosmicsig::COSMIC_v3.2$signature$GRCh37$SBS96

# Get the real tumor spectra from the nine cancer types
real_spectra_sbs <-
  PCAWG7::spectra$PCAWG$SBS96[, colnames(real_exposure_sbs)]

real_distance_sbs <- get_distance(
  spectra = real_spectra_sbs,
  exposure = real_exposure_sbs,
  sigs = sigs_sbs,
  group = "real"
)

# Add noise to noiseless synthetic data with different negative-binomial size
# parameter
dir_noiseless_sbs <- "./SBS/input/Noiseless/"
noiseless_data_sbs <- get_syn_data_info(dir = dir_noiseless_sbs)
seed <- 658220

nb_sizes_sbs <- c(100, 50, 40, 30, 20, 10)
noise_data_sbs <- generate_noisy_data(
  seed = seed,
  exposure = noiseless_data_sbs$exposure,
  sigs = noiseless_data_sbs$sigs,
  nb_sizes = nb_sizes_sbs
)
syn_distance_sbs <-
  get_multiple_syn_distances(list_of_syn_data = noise_data_sbs)

all_distance_sbs <-
  do.call(dplyr::bind_rows, c(list(real_distance_sbs), syn_distance_sbs))

plot_objects_sbs <-
  create_boxplots(
    distance_df = all_distance_sbs,
    data_type = "SBS", ylim = c(0, 0.2)
  )

ggplot_to_pdf(
  plot_objects = plot_objects_sbs,
  file = "./other_analyses/noise_selection/SBS_noise_selection.pdf",
  nrow = 2, ncol = 1,
  width = 8.2677, height = 11.6929, units = "in"
)

