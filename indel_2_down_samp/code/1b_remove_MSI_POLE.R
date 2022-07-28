# Import prerequisites --------------------------------------------------------
require(ICAMS)
require(magrittr)
require(mSigAct)


# Define paths ----------------------------------------------------------------
dir_input <- "indel_2/input/Realistic/"
dir_down_samp <- "indel_2_down_samp/input/10k/"
dir_non_hyper <- "indel_2_down_samp/input/non_hyper/"
if(!dir.exists(dir_non_hyper)) dir.create(dir_non_hyper, recursive = T)



# Check which spectra are down-sampled when thres = 10k -----------------------
spec_list <- list()
spec_list$no_down_samp <- 
  ICAMS::ReadCatalog("indel_2/input/Realistic/ground.truth.syn.catalog.csv")
spec_list[["10k"]] <- 
  ICAMS::ReadCatalog("indel_2_down_samp/input/10k/ground.truth.syn.catalog.csv")

spec_sum <- list()
spec_sum$no_down_samp <- spec_list$no_down_samp %>% colSums()
spec_sum[["10k"]] <- spec_list[["10k"]] %>% colSums()

all.equal(spec_sum$no_down_samp, spec_sum$`10k`)
which(spec_sum$no_down_samp != spec_sum$`10k`) %>% length # 25 spectra

# identifiers of hyper-mutated spectra
ids_hyper <- which(spec_sum$no_down_samp != spec_sum$`10k`) %>% names()
# Differences before and after down-sampling
bar <- spec_sum$no_down_samp - spec_sum$`10k`
bar[ids_hyper]


# Export exposure and spectra, with hypermutators removed ------------------------
gt_exp <- mSigAct::ReadExposure(
  paste0(dir_input, "/ground.truth.syn.exposures.csv"))
gt_spec <- spec_list$no_down_samp
ids_non_hyper <- setdiff(colnames(gt_exp), ids_hyper)
exp_non_hyper <- gt_exp[, ids_non_hyper]
spec_non_hyper <- gt_spec[, ids_non_hyper]

ICAMS::WriteCatalog(
  spec_non_hyper, 
  paste0(dir_non_hyper, "/ground.truth.syn.catalog.csv"))
mSigAct::WriteExposure(
  exp_non_hyper,
  paste0(dir_non_hyper, "/ground.truth.syn.exposures.csv"))
file.copy(
  paste0(dir_input, "/ground.truth.syn.sigs.csv"),
  paste0(dir_non_hyper, "/ground.truth.syn.sigs.csv")
)

# Export SigPro-formatted ground-truth spectra and sigs -----------------------
ICAMS:::ConvertCatalogToSigProfilerFormat(
  spec_non_hyper,
  file = paste0(dir_non_hyper, "/ground.truth.syn.catalog.tsv"),
  sep = "\t")

sigs <- ICAMS::ReadCatalog(
  paste0(dir_non_hyper, "/ground.truth.syn.sigs.csv")
)
ICAMS:::ConvertCatalogToSigProfilerFormat(
  sigs,
  file = paste0(dir_non_hyper, "/ground.truth.syn.sigs.tsv"),
  sep = "\t")
