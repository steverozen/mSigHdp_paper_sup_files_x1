library(mSigTools)
library(PCAWG7)
library(dplyr)
library(gtools)
library(xlsx)

sbs_exp1 <-
  mSigTools::read_exposure(file = "SBS_set1/input/Realistic/ground.truth.syn.exposures.csv")
sbs_exp2 <-
  mSigTools::read_exposure(file = "SBS_set2/input/Realistic/ground.truth.syn.exposures.csv")

indel_exp1 <-
  mSigTools::read_exposure(file = "indel_set1/input/Realistic/ground.truth.syn.exposures.csv")
indel_exp2 <-
  mSigTools::read_exposure(file = "indel_set2/input/Realistic/ground.truth.syn.exposures.csv")

get_sig_prop <- function(exp1, exp2) {
  get_prop <- function(exposure, identifier) {
    prop <-
      apply(X = exposure, MARGIN = 1, FUN = function(x) {
        length(x[x > 0]) / length(x)
      })
    df <- as.data.frame(t(prop))
    rownames(df) <- identifier
    return(df)
  }
  all_prop1 <- get_prop(exposure = exp1, identifier = "all_set1")
  all_prop2 <- get_prop(exposure = exp2, identifier = "all_set2")

  exp_by_type1 <-
    PCAWG7::SplitPCAWGMatrixByTumorType(exp1)
  exp_by_type2 <-
    PCAWG7::SplitPCAWGMatrixByTumorType(exp2)

  cancer_types1 <-
    gsub(pattern = "SP.Syn.", replacement = "", x = names(exp_by_type1))
  cancer_types2 <-
    gsub(pattern = "SP.Syn.", replacement = "", x = names(exp_by_type2))
  cancer_types_diff <- setdiff(cancer_types2, cancer_types1)

  cancer_types <- c(cancer_types1, cancer_types_diff)

  prop_list <- list(all_prop1, all_prop2)

  for (cancer_type in cancer_types) {
    if (!cancer_type %in% cancer_types_diff) {
      exp1_samples <-
        grep(pattern = cancer_type, x = colnames(exp1), value = TRUE)
      exp2_samples <-
        grep(pattern = cancer_type, x = colnames(exp2), value = TRUE)
      exp_type1 <- exp1[, exp1_samples]
      exp_type2 <- exp2[, exp2_samples]
      exp_type1 <- exp_type1[rowSums(exp_type1) > 0, , drop = FALSE]
      exp_type2 <- exp_type2[rowSums(exp_type2) > 0, , drop = FALSE]
      prop1 <- get_prop(exposure = exp_type1, identifier = paste0(cancer_type, "_set1"))
      prop2 <- get_prop(exposure = exp_type2, identifier = paste0(cancer_type, "_set2"))
      prop_list <- c(prop_list, list(prop1, prop2))
    } else {
      exp2_samples <-
        grep(pattern = cancer_type, x = colnames(exp2), value = TRUE)
      exp_type2 <- exp2[, exp2_samples]
      exp_type2 <- exp_type2[rowSums(exp_type2) > 0, , drop = FALSE]
      prop2 <- get_prop(exposure = exp_type2, identifier = paste0(cancer_type, "_set2"))
      prop_list <- c(prop_list, list(prop2))
    }
  }

  prop_df <- do.call(dplyr::bind_rows, prop_list)
  prop_df2 <- as.data.frame(t(prop_df))
  prop_df3 <- prop_df2[gtools::mixedsort(x = rownames(prop_df2)), , drop = FALSE]
  return(prop_df3)
}

sbs_sig_prop <- get_sig_prop(exp1 = sbs_exp1, exp2 = sbs_exp2)
indel_sig_prop <- get_sig_prop(exp1 = indel_exp1, exp2 = indel_exp2)

sig_prop_df <- rbind(sbs_sig_prop, indel_sig_prop)
xlsx::write.xlsx(sig_prop_df,
  file = "common_code/sig_prop_analysis/syn_data_sig_prop.xlsx", showNA = FALSE
)
