# Small calculations cited in the text

library(data.table)
library(tidyr)
library(MASS)


# Ratio of number of mutations in downsample(SBS_set2) / downsample(SBS_set1) 

sset1 <- ICAMS::ReadCatalog("SBS_set1/input/Realistic/ground.truth.syn.catalog.csv")
sset2 <- ICAMS::ReadCatalog("SBS_set2/input/Realistic/ground.truth.syn.catalog.csv")

count_sset1 <- sum(sset1)
count_sset2 <- sum(sset2)
(count_sset1 + count_sset2) / 1e6

count_sset2 / count_sset1
sum(mSigHdp::downsample_spectra(sset2, downsample_threshold = 3000)[[1]]) /
  sum(mSigHdp::downsample_spectra(sset1, downsample_threshold = 3000)[[1]])

# Statistics for for Supplementary Table S7

s7 <- fread("common_code/missed_sig_analysis/missed_sig_analysis.csv")
s7x <- tidyr::pivot_longer(s7, cols = c("mSigHdp", "SigProfilerExtractor"), names_to = "Approach", values_to = "num_seeds_with_miss")
# s7x <- dplyr::mutate(s7x, found_in_all = num_seeds_with_miss == 0)
s7x.indel <- dplyr::filter(s7x, grepl("indel", dataset_name))
s7x.sbs <- dplyr::filter(s7x, grepl("SBS", dataset_name))
s7x.sbs <- dplyr::mutate(s7x.sbs, num_seeds_with_hit = 5 - num_seeds_with_miss)

slm <- lm(num_seeds_with_hit ~ sigs_prev_prop + Approach + dataset_name, data = s7x.sbs)
lsm <- summary(slm)$coefficients
lsmt <- lsm[ , 3]
2*pt(-abs(lmst), df = 106)

sbsr <- MASS::rlm(num_seeds_with_hit ~ sigs_prev_prop + Approach + dataset_name, data = s7x.sbs)
rm <- summary(sbsr)
rmt <- rm$coefficients[ , 3]
2*pt(-abs(rmt), df = 106)

rr <- robust::lmRob(num_seeds_with_hit ~ sigs_prev_prop + as.factor(Approach) + as.factor(dataset_name), data = s7x.sbs)
