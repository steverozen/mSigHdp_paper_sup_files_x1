# Small calculations cited in the text

library(data.table)
library(tidyr)

# Ratio of number of mutations in downsample(SBS_set2) / downsample(SBS_set1) 

sset1 <- ICAMS::ReadCatalog("SBS_set1/input/Realistic/ground.truth.syn.catalog.csv")
sset2 <- ICAMS::ReadCatalog("SBS_set2/input/Realistic/ground.truth.syn.catalog.csv")
sum(sset2) / sum(sset1)
sum(mSigHdp::downsample_spectra(sset2, downsample_threshold = 3000)[[1]]) /
  sum(mSigHdp::downsample_spectra(sset1, downsample_threshold = 3000)[[1]])

# Statistics for for Table S7

s7 <- fread("common_code/missed_sig_analysis/missed_sig_analysis.csv")
s7x <- pivot_longer(s7, cols = c("mSigHdp", "SigProfilerExtractor"), names_to = "Approach", values_to = "num_seeds_with_miss")
s7x <- dplyr::mutate(s7x, found_in_all = num_seeds_with_miss == 0)
s7x.indel <- dplyr::filter(s7x, grepl("indel", dataset_name))
s7x.sbs <- dplyr::filter(s7x, grepl("SBS", dataset_name))

sbsm <- glm(num_seeds_with_miss ~ sigs_prev_prop + Approach + dataset_name, data = s7x.sbs)


sbsr <- rlm(num_seeds_with_miss ~ sigs_prev_prop + Approach + dataset_name, data = s7x.sbs)
summary(sbsr)$sigma

only.found <- dplyr::filter(s7x.sbs, found_in_all)
wilcox.test(sigs_prev_prop ~ Approach, data = only.found)
# p = 0.1248
# Double check:
ms <- dplyr::filter(only.found, Approach == "mSigHdp")
sp <- dplyr::filter(only.found, Approach == "SigProfilerExtractor")
wilcox.test(ms$sigs_prev_prop, sp$sigs_prev_prop)
