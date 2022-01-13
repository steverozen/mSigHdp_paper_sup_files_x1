# Please run this script from the top directory
if (basename(getwd()) != "Liu_et_al_Sup_Files") {
  stop("Please run from top level directory, Liu_et_al_Sup_Files")
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

# 2. Copy and shorten the names of folders and files under input/raw ----------

old_SBS_home <- "SBS/input/raw"
SBS_home <- "SBS/input"
dir.create(SBS_home, showWarnings = FALSE, recursive = TRUE)

# Shortening the names of folders
old_dataset_names <-
  c("PCAWG.SBS96.syn.exposures.no.noise",
    "PCAWG.SBS96.syn.exposures.noisy.neg.binom.size.30",
    "PCAWG.SBS96.syn.exposures.noisy.neg.binom.size.100")
dataset_names <- c("Noiseless", "Realistic", "Moderate")
for (ii in seq_along(dataset_names)) {
  if (!file.exists(file.path(SBS_home, dataset_names[ii]))) {
    file.copy(from = paste0(old_SBS_home, "/", old_dataset_names[ii]),
              to = SBS_home,
              recursive = TRUE,
              copy.date = TRUE)
    file.rename(from = paste0(SBS_home, "/", old_dataset_names[ii]),
                to = paste0(SBS_home, "/", dataset_names[ii]))
  }
}

# Delete the input/raw folder
unlink(x = old_SBS_home, recursive = TRUE)

# Shortening the names of csv files.
file_names <- c(
  "ground.truth.syn.catalog",
  "ground.truth.syn.exposures",
  "ground.truth.syn.sigs"
)
for (dn in dataset_names) {
  home_dir <- paste0(SBS_home, "/", dn)
  old_file_names <- list.files(path = home_dir, pattern = "\\.csv$")
  for (fn in file_names) {
    old_fn <- old_file_names[grepl(fn, old_file_names)]
    file.rename(from = paste0(home_dir, "/", old_fn),
                to = paste0(home_dir, "/", fn, ".csv"))
  }
}

# 3. Export ICAMS-formatted SBS catalog to SigPro tsv format ------------------

for (dn in dataset_names) {
  spectra <- ICAMS::ReadCatalog(
    paste0(SBS_home, "/", dn, "/ground.truth.syn.catalog.csv")
  )
  ICAMS:::ConvertCatalogToSigProfilerFormat(
    spectra,
    file = paste0(SBS_home, "/", dn, "/ground.truth.syn.catalog.tsv"),
    sep = "\t")
}
