# Small calculations cited in the text

library(data.table)
library(tidyr)
library(MASS)


outpath <- function(filename) {
  file.path("output_for_paper", filename)
}

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
s7x <- tidyr::pivot_longer(s7, 
                           cols = c("mSigHdp", "SigProfilerExtractor"),
                           names_to = "Approach",
                           values_to = "num_seeds_with_miss")
# s7x <- dplyr::mutate(s7x, found_in_all = num_seeds_with_miss == 0)
s7x.indel <- dplyr::filter(s7x, grepl("indel", dataset_name))
s7x.sbs <- dplyr::filter(s7x, grepl("SBS", dataset_name))
sup_table_s7_sbs_for_rlm <- dplyr::mutate(s7x.sbs, num_seeds_with_hit = 5 - num_seeds_with_miss)
data.table::fwrite(sup_table_s7_sbs_for_rlm, outpath("sup_table_s7_sbs_for_rlm.csv"))

# slm <- lm(num_seeds_with_hit ~ sigs_prev_prop + Approach + dataset_name, data = sup_table_s7_sbs_for_rlm)
# lsm <- summary(slm)$coefficients
# lsmt <- lsm[ , 3]
# 2*pt(-abs(lsmt), df = nrow(sup_table_s7_sbs_for_rlm) - 4)
# 
# rr <- 
#  robust::lmRob(
#    num_seeds_with_hit ~ sigs_prev_prop + as.factor(Approach) + as.factor(dataset_name), 
#    data = sup_table_s7_sbs_for_rlm)

sbsr <- MASS::rlm(num_seeds_with_hit ~ sigs_prev_prop + Approach + 
                    dataset_name, data = sup_table_s7_sbs_for_rlm)
rm   <- summary(sbsr)
rmc  <- rm$coefficients
rmp  <- 2*pt(-abs(rmc[ , 3]), df = nrow(sup_table_s7_sbs_for_rlm) - 4)
coef <- data.frame(cbind(rmc, p = rmp))
sup_table_s7_coef <- cbind(Variable = rownames(coef), coef)
openxlsx::write.xlsx(sup_table_s7_coef, file = outpath("sup_table_s7_coef.xlsx"))

# NUmbers for the secion on indel results

load("output_for_paper/supplementary_table_s4.Rdata")
# mSigHdp and sig pro for indel datas
dplyr::filter(supplementary_table_s4,
              Approach %in% c("mSigHdp", "SigProfilerExtractor") &
                Data_set %in% c("indel_set1", "indel_set2") &
                Noise_level == "Realistic") %>%
  dplyr::group_by(Approach) %>%
  dplyr::mutate(med.fp = median(FP), avg.fp = mean(FP)) -> examine.indels



