# Please run this script from the top directory
if (basename(getwd()) != "mSigHdp_paper_sup_files_x1") {
  stop("Please run from top level directory, mSigHdp_paper_sup_files_x1")
}

# 1. Install and load dependencies --------------------------------------------
if (!requireNamespace("magrittr", quietly = TRUE)) {
  install.packages("magrittr")
}
if (!requireNamespace("ICAMS", quietly = TRUE)) {
  remotes::install_github("steverozen/ICAMS", ref = "v3.0.5-branch")
}
require(magrittr)
require(ICAMS)
# Source script to downsample exposure
source("common_code/down_sample.R")


# 2. Copy and shorten the names of folders and files under input/raw ----------
old_indel_home <- "indel/input/Realistic"
indel_home <- "indel_down_samp/input"
dir.create(indel_home, showWarnings = FALSE, recursive = TRUE)
# Threshold values
thres_vals <- c(500, 1000, 3000, 5000, 10000)
dataset_names <- c("500", "1k", "3k", "5k", "10k")
names(dataset_names) <- as.character(thres_vals)
for (thres_val in thres_vals) {
  dataset_path <- 
    file.path(indel_home, 
              dataset_names[as.character(thres_val)])
  if (!dir.exists(dataset_path)) 
    dir.create(dataset_path, recursive = T)
  
  # Down-sample original signature and exposure -------------------------------
  spec <- ICAMS::ReadCatalog(
    file = paste0(old_indel_home, "/ground.truth.syn.catalog.csv"),
    ref.genome = "GRCh37",
    region = "genome",
    catalog.type = "counts")
  exp <- mSigAct::ReadExposure(
    paste0(old_indel_home, "/ground.truth.syn.exposures.csv"))
  retval <- down_samp(spec, exp, thres_val)
  down_spec <- retval$down_spec
  down_exp <- retval$down_exp
  
  # Export down-sampled spectra and exposure ----------------------------------
  # Export spectra to ICAMS formatted csv file
  ICAMS::WriteCatalog(
    down_spec,
    file = paste0(dataset_path, "/ground.truth.syn.catalog.csv"))
  # Export ICAMS-formatted indel spectra to SigPro tsv format 
  ICAMS:::ConvertCatalogToSigProfilerFormat(
    down_spec,
    file = paste0(dataset_path, "/ground.truth.syn.catalog.tsv"),
    sep = "\t")
  # Export down-sampled exposure
  mSigAct::WriteExposure(
    exposure = down_exp,
    file = paste0(dataset_path, "/ground.truth.syn.exposures.csv"))
  
  # Copy ground-truth signature file ------------------------------------------
  old_sig_path <- paste0(old_indel_home, "/ground.truth.syn.sigs.csv")
  file.copy(from = old_sig_path,
            to = dataset_path,
            copy.date = TRUE)
  sigs <- ICAMS::ReadCatalog(
    old_sig_path,
    ref.genome = "GRCh37",
    region = "genome",
    catalog.type = "counts.signature")
  # Export ICAMS-formatted indel signatures to SigPro tsv format 
  ICAMS:::ConvertCatalogToSigProfilerFormat(
    sigs,
    file = paste0(dataset_path, "/ground.truth.syn.sigs.tsv"),
    sep = "\t")
}
