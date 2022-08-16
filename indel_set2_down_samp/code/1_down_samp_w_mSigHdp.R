# Please run this script from the top directory
if (basename(getwd()) != "mSigHdp_paper_sup_files_x1") {
  stop("Please run from top level directory, mSigHdp_paper_sup_files_x1")
}

# 1. Install and load dependencies --------------------------------------------
if (!requireNamespace("magrittr", quietly = TRUE)) {
  install.packages("magrittr")
}
if ((!requireNamespace("ICAMS", quietly = TRUE)) ||
    (packageVersion("ICAMS") < "3.0.6")) {
  remotes::install_github("steverozen/ICAMS", ref = "v3.0.6-branch")
}
if ((!requireNamespace("mSigHdp", quietly = TRUE)) ||
    (packageVersion("mSigHdp") < "2.0.1.10")) {
  remotes::install_github("steverozen/mSigHdp", ref = "master")
}
require(magrittr)
require(ICAMS)
# Require mSigHdp to downsample exposure
require(mSigHdp)


# 2. Copy and shorten the names of folders and files under input/raw ----------
old_indel_home <- "indel_2/input/Realistic"
indel_home <- "indel_2_down_samp/input"
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
  
  # Down-sample original spectra ----------------------------------------------
  spec <- ICAMS::ReadCatalog(
    file = paste0(old_indel_home, "/ground.truth.syn.catalog.csv"),
    ref.genome = "GRCh37",
    region = "genome",
    catalog.type = "counts")
  retval <- mSigHdp::downsample_spectra(spec, thres_val)
  down_spec <- retval$down_spec
  down_factor <- retval$down_factor
  
  # Export down-sampled spectra -----------------------------------------------
  # Export spectra to ICAMS formatted csv file
  ICAMS::WriteCatalog(
    down_spec,
    file = paste0(dataset_path, "/ground.truth.syn.catalog.csv"))
  # Export ICAMS-formatted indel spectra to SigPro tsv format 
  ICAMS:::ConvertCatalogToSigProfilerFormat(
    down_spec,
    file = paste0(dataset_path, "/ground.truth.syn.catalog.tsv"),
    sep = "\t")
  
  
  # Down-sample original exposure ---------------------------------------------
  exp <- mSigAct::ReadExposure(
    paste0(old_indel_home, "/ground.truth.syn.exposures.csv"))
  down_exp <- (t(exp) * down_factor) %>% t() %>% as.data.frame()
  foo <- sapply(down_exp, round)
  foo <- foo %>% as.data.frame()
  dimnames(foo) <- dimnames(exp)
  down_exp <- foo
  rm(foo)
  
  # Export down-sampled exposure ----------------------------------------------
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
