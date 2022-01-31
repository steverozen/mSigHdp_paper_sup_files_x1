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

if (!requireNamespace("mSigAct", quietly = TRUE) ||
  packageVersion("mSigAct") < "2.2.0") {
  remotes::install_github(
    repo = "steverozen/mSigAct",
    ref = "v2.2.0-branch"
  )
}

# Restart R after installing the new packages
.rs.restartR()

source("./common_code/data_gen_utils.R")

library(dplyr)
library(ggpubr)
library(gridExtra)
library(mSigAct)

# Read in signature exposure file from realistic synthetic data
exposure_sbs_file <- "SBS/input/Realistic/ground.truth.syn.exposures.csv"
exposure_indel_file <- "indel/input/Realistic/ground.truth.syn.exposures.csv"
exposure_sbs <- mSigAct::ReadExposure(exposure_sbs_file)
exposure_indel <- mSigAct::ReadExposure(exposure_indel_file)

# Get the signature activity information
sig_activity_sbs <- get_sig_activity(exposure_sbs)
sig_activity_indel <- get_sig_activity(exposure_indel)
sig_activity_all <- rbind(sig_activity_sbs, sig_activity_indel)

output_home <- "other_analyses/missed_sig_analysis/output"
write.csv(
  x = sig_activity_all,
  file = file.path(output_home, "sig_activity_in_realistic_data.csv"),
  row.names = FALSE
)

# Investigate the signatures failed to discover by SigProfilerExtractor and
# mSigHdp
sigs_missed_sigpro <- c(
  paste0("SBS", c(5, 12, 29, 41, 16, 38, 22, 35)),
  paste0("ID", c(5, 11, 13))
)
sigs_missed_msighdp <- c("SBS7a", "SBS7b", "SBS35")

sig_activity_sbs$missed_by_sigpro <-
  factor(sig_activity_sbs$sig_id %in% sigs_missed_sigpro,
    levels = c(TRUE, FALSE)
  )

sig_activity_sbs$missed_by_msighdp <-
  factor(sig_activity_sbs$sig_id %in% sigs_missed_msighdp,
    levels = c(TRUE, FALSE)
  )

p1 <-
  ggpubr::ggboxplot(sig_activity_sbs,
    x = "missed_by_sigpro", y = "sig_prop",
    color = "missed_by_sigpro", palette = c("#FAA691", "#000000"),
    ylab = "Signature proportion",
    xlab = "SBS signature missed by SigProfilerExtractor",
    add = "jitter"
  ) +
  ggpubr::stat_compare_means(
    method = "wilcox.test",
    label.x = 1.5, label.y = 1
  ) +
  ggplot2::theme(legend.position = "none")


p2 <-
  ggpubr::ggboxplot(sig_activity_sbs,
    x = "missed_by_msighdp", y = "sig_prop",
    color = "missed_by_msighdp", palette = c("#00CC00", "#000000"),
    ylab = "Signature proportion",
    xlab = "SBS signature missed by mSigHdp",
    add = "jitter"
  ) +
  ggpubr::stat_compare_means(
    method = "wilcox.test",
    label.x = 1.5, label.y = 1
  ) +
  ggplot2::theme(legend.position = "none")

output_home2 <- "other_analyses/missed_sig_analysis"
ggplot_to_pdf(
  plot_objects = list(p1, p2),
  file = file.path(output_home2, "missed_sig_in_realistic_data.pdf"),
  nrow = 2, ncol = 1,
  width = 8.2677, height = 11.6929, units = "in"
)
grDevices::dev.off()
