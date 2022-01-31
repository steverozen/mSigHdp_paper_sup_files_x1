# Please run this script from the top directory
if (basename(getwd()) != "Liu_et_al_Sup_Files") {
  stop("Please run from top level directory, Liu_et_al_Sup_Files")
}

#################################################################
##                 Install dependency packages                 ##
#################################################################
pkg_names <- c("remotes", "dplyr")
is_installed <- pkg_names %in% rownames(installed.packages())
if (any(!is_installed)) {
  stop("Please install packages",
       paste(pkg_names[!is_installed], collapse = ", "))
}

if (!requireNamespace("mSigAct", quietly = TRUE) ||
  packageVersion("mSigAct") < "2.2.0") {
  stop("Please install mSigAct . v2.2.0:\n",
       "remotes::install_github(\"steverozen/mSigAct\", ref = \"v2.2.0-branch\"")
}

source("./common_code/data_gen_utils.R")

library(dplyr)
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

output_home <- "other_analyses/missed_sig_analysis"
write.csv(
  x = sig_activity_all,
  file = file.path(output_home, "sig_activity_in_realistic_data.csv"),
  row.names = FALSE
)

# Investigate the signatures failed to discover by SigProfilerExtractor and
# mSigHdp
false_negs_sigpro <- c(
  paste0("SBS", c(5, 12, 29, 41, 16, 38, 22, 35)),
  paste0("ID", c(5, 11, 13))
)
false_neg_msighdp <- c("SBS7a", "SBS7b", "SBS35")

sig_activity_sbs$missed_by_sigpro <- 
  sig_activity_sbs$sig_id %in% false_negs_sigpro


sig_activity_sbs$missed_by_msighdp <- 
  sig_activity_sbs$sig_id %in% false_neg_msighdp

write.csv(sig_activity_sbs, 
          file.path(output_home, "SBS_false_negs.csv"),
          row.names = FALSE)

cat(
  "SigPro SBS sigs FP, median proportion of tumors with sig = ",
  median(sig_activity_sbs[sig_activity_sbs$missed_by_sigpro, "sig_prop"]),
  "\n")

cat("SigPro SBS sigs TP, median proportion of tumors with sig = ",
    median(sig_activity_sbs[!sig_activity_sbs$missed_by_sigpro, "sig_prop"]),
    "\n")

wt <- wilcox.test(jitter(sig_prop) ~ missed_by_sigpro, data = sig_activity_sbs)
cat("Associated p value = ", wt$p.value, "\n")

cat("done\n")
