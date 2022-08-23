# false_negative_by_signature_prevalence.R

# This script is used to generate Supp Table S4 in 
# Liu et al. (2022) - the signatures failed to be extracted by:
#
# (1) mSigHdp (2) mSigHdp_ds_3k (3) SigProfilerExtractor
#
# ranked by the rareness of these mutational signatures in 4 data sets:
#
# - indel set 1
# - indel set 2
# - SBS set 1
# - SBS set 2
#
# The table will also show how many runs have the programs failed
# to extract the signature.


# Please run this script from the top-level directory
if (basename(getwd()) != "mSigHdp_paper_sup_files_x1") {
  stop("Please run from top level directory, mSigHdp_paper_sup_files_x1")
}


# 1. Install and load dependencies --------------------------------------------
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}
if (!requireNamespace("ICAMS", quietly = TRUE)) {
    remotes::install_github("steverozen/ICAMS", ref = "v3.0.5-branch")
}
if (!requireNamespace("mSigTools", quietly = TRUE)) {
  remotes::install_github("steverozen/mSigTools", ref = "v1.0.0-branch")
}
require(dplyr)
require(ICAMS)
require(mSigTools)


# 2. Specify global variables -------------------------------------------------
folder_names <- 
  paste0(rep(c("indel", "SBS"), 2), 
         "_set", 
         rep(c(1L, 2L), each = 2))
tool_names <- c("mSigHdp", "SigProfilerExtractor")

source("common_code/all.seeds.R")
seeds_in_use <- all.seeds()


# 3. Rank ground-truth signature by rareness ----------------------------------
ls_dfs <- list()
for (fn in folder_names) {
  home_for_data <- paste0(fn, "/input")
  home_for_run <- paste0(fn, "/raw_results")
  # Import exposure matrix
  exp <- mSigTools::read_exposure(
    file = paste0(home_for_data, "/Realistic/ground.truth.syn.exposures.csv")
  )
  # Fetch signature names
  sigs <- rownames(exp)
  num_tumors <- ncol(exp)
  # Calculate "rareness" of each ground-truth signature
  #
  # Here, rareness of a ground-truth signature is quantified by
  # the number and the proportion of synthetic tumors
  # with exposure to the signature.
  sigs_prev <- rep(-Inf, length(sigs))
  names(sigs_prev) <- sigs
  for (sig in sigs) {
    sigs_prev[sig] <- which(exp[sig,] >= 1) %>% length()
  }
  sigs_prev <- sort(sigs_prev, decreasing = T)
  sigs_prev_prop <- sigs_prev / num_tumors
  # Organize results into a data frame.
  ls_dfs[[fn]] <- data.frame(sigs = names(sigs_prev), 
                             sigs_prev = sigs_prev,
                             sigs_prev_prop = sigs_prev_prop)
}

# 3. Check whether each tool can extract each signature for all runs ----------
for(fn in folder_names){
  for (tn in tool_names) {
    mat <- matrix(data = 0, nrow = nrow(ls_dfs[[fn]]), ncol = 1)
    colnames(mat) <- tn
    ls_dfs[[fn]] <- data.frame(ls_dfs[[fn]], mat)
  }
}

for (fn in folder_names) {
  home_for_data <- paste0(fn, "/input")
  home_for_run <- paste0(fn, "/raw_results")
  
  for (tn in tool_names) {
    for (sig in ls_dfs[[fn]]$sigs) {
      # Count the number of runs which failed to extract the ground-truth sig
      # Expect to be 0~5.
      num_runs_w_fn <- 0
      for (seed_in_use in seeds_in_use) {
        tmp_match <- utils::read.csv(
          paste0(home_for_run, "/", tn, ".results/Realistic/seed.",
                 seed_in_use, "/summary/match.ex.to.gt.csv"))
        all_true_pos_sigs <- tmp_match$ref.sig
        if ((sig %in% all_true_pos_sigs) == FALSE) {
          num_runs_w_fn <- num_runs_w_fn + 1
        }
      }
      ls_dfs[[fn]][sig, tn] <- num_runs_w_fn
    }
  }
}  


# 4. Add comments -------------------------------------------------------------
for(fn in folder_names){
    ls_dfs[[fn]] <- data.frame(ls_dfs[[fn]], Remarks = "")
}


for (fn in folder_names) {
  df <- ls_dfs[[fn]]
  for (sig in rownames(df)) {
    comment <- ""
    for(tn in tool_names) {
      num_runs_w_fn <- df[sig, tn]
      if(num_runs_w_fn > 0 & num_runs_w_fn < 5) {
        comment <- 
          paste0(comment, "Signature missed by ", tn,
                 " in ", num_runs_w_fn," runs; ")
      } else if (num_runs_w_fn == 5) {
        comment <- 
          paste0(comment, "Signature missed by ", tn,
                 " in all 5 runs; ")
      }
    }
    df[sig, "Remarks"] <- comment
  }
  ls_dfs[[fn]] <- df
}

# 5. Output tables ------------------------------------------------------------
combined_df <- do.call(rbind, ls_dfs)

utils::write.csv(combined_df, 
                 file = paste0("common_code/missed_sig_analysis/missed_sig_analysis.csv"))



