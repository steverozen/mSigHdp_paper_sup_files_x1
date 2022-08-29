# Please run this script from the top-level directory
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

# 2. Export ICAMS-formatted SBS catalog to tsv format -------------------------
# supported by SigProfilerExtractor -------------------------------------------
SBS_home <- "ROC_SBS35_30_1066/input"

for (dn in dataset_names) {
  spectra <- ICAMS::ReadCatalog(
    paste0(SBS_home, "/", dn, "/ground.truth.syn.catalog.csv")
  )
  ICAMS:::ConvertCatalogToSigProfilerFormat(
    spectra,
    file = paste0(SBS_home, "/", dn, "/ground.truth.syn.catalog.tsv"),
    sep = "\t")
}

for (dn in dataset_names) {
  sigs <- ICAMS::ReadCatalog(
    paste0(SBS_home, "/", dn, "/ground.truth.syn.sigs.csv")
  )
  ICAMS:::ConvertCatalogToSigProfilerFormat(
    sigs,
    file = paste0(SBS_home, "/", dn, "/ground.truth.syn.sigs.tsv"),
    sep = "\t")
}
