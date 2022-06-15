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
old_SBS_home <- "SBS/input/Realistic"
SBS_home <- "SBS_down_samp/input"
dir.create(SBS_home, showWarnings = FALSE, recursive = TRUE)
# Threshold values
thres_vals <- c(1000, 3000, 5000, 10000, 20000)
dataset_names <- c("1k", "3k", "5k", "10k", "20k")
names(dataset_names) <- as.character(thres_vals)
for (thres_val in thres_vals) {
  dataset_path <- 
    file.path(SBS_home, 
              dataset_names[as.character(thres_val)])
  if (!dir.exists(dataset_path)) 
    dir.create(dataset_path, recursive = T)
  
  # Down-sample original exposure ---------------------------------------------
  spec <- ICAMS::ReadCatalog(
    file = paste0(old_SBS_home, "/ground.truth.syn.catalog.csv"),
    ref.genome = "GRCh37",
    region = "genome",
    catalog.type = "counts")
  exp <- mSigAct::ReadExposure(
    paste0(old_SBS_home, "/ground.truth.syn.exposures.csv"))
  exp_sum <- colSums(exp)
  # Print the number of samples with mutations smaller than thres_val
  which(exp_sum <= thres_val) %>% length() %>% print()
  down_exp_sum <- sapply(exp_sum, down_sample_func, thres = thres_val)
  
  down_factor <- down_exp_sum / exp_sum
  
  # Export down-sampled exposure ----------------------------------------------
  down_exp <- (t(exp) * down_factor) %>% t() %>% as.data.frame()
  foo <- sapply(down_exp, round)
  foo <- foo %>% as.data.frame()
  # Check
  if (FALSE) {
    # Expects to be TRUE
    all.equal(dimnames(exp), dimnames(down_exp))
    # The difference between each element in two dfs is less than 1
    (foo - down_exp) %>% range()
  }
  dimnames(foo) <- dimnames(exp)
  down_exp <- foo
  rm(foo)
  mSigAct::WriteExposure(
    exposure = down_exp,
    file = paste0(dataset_path, "/ground.truth.syn.exposures.csv"))
  
  # Export down-sampled catalog -----------------------------------------------
  down_spec <-(t(spec) * down_factor) %>% t() %>% as.data.frame()
  foo <- sapply(down_spec, round)
  foo <- foo %>% as.data.frame()
  # Check
  if (FALSE) {
    # Expects to be TRUE
    all.equal(dimnames(spec), dimnames(down_spec))
    # The difference between each element in two dfs is less than 1
    (foo - down_spec) %>% range()
  }
  dimnames(foo) <- dimnames(spec)
  down_spec <- ICAMS::as.catalog(foo, ref.genome = "GRCh37",
                                 region = "genome",
                                 catalog.type = "counts")
  rm(foo)
  ICAMS::WriteCatalog(
    down_spec,
    file = paste0(dataset_path, "/ground.truth.syn.catalog.csv"))
  # Export ICAMS-formatted SBS spectra to SigPro tsv format 
  ICAMS:::ConvertCatalogToSigProfilerFormat(
    down_spec,
    file = paste0(dataset_path, "/ground.truth.syn.catalog.tsv"),
    sep = "\t")
  
  # Copy ground-truth signature file ------------------------------------------
  old_sig_path <- paste0(old_SBS_home, "/ground.truth.syn.sigs.csv")
  file.copy(from = old_sig_path,
            to = dataset_path,
            copy.date = TRUE)
  sigs <- ICAMS::ReadCatalog(
    old_sig_path,
    ref.genome = "GRCh37",
    region = "genome",
    catalog.type = "counts.signature")
  # Export ICAMS-formatted SBS signatures to SigPro tsv format 
  ICAMS:::ConvertCatalogToSigProfilerFormat(
    sigs,
    file = paste0(dataset_path, "/ground.truth.syn.sigs.tsv"),
    sep = "\t")
}
