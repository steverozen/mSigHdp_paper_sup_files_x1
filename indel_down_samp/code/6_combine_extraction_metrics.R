# Code from Steve Rozen, 2021 01 24
# Analyses for Liu Mo's paper, "mSigHdp: hierarchical Dirichlet processes
# in mutational signature extraction, Liu et al."
#
# This code assembles run-level results that are in individual .csv files
# into one large tibble - all_results.csv,
# and stats_by_approach_and_data_set.csv - 
# at the level of approach and data set

# Please run this script from the top directory
if (basename(getwd()) != "mSigHdp_paper_sup_files_x1") {
  stop("Please run from top level directory, mSigHdp_paper_sup_files_x1")
}

# 0. Install and load dependencies --------------------------------------------

library(data.table)
library(dplyr)
library(readr)
library(tibble)



# 1. Combine all extraction measures ------------------------------------------

myread <- function(ff) as_tibble(fread(ff)[ , -1])

# These are the files to be logically "cbind"ed
gtSigs <- paste0("ID",c(1:6,8,9,11,13,14))
nSigs <- length(gtSigs)


home <- "./indel_down_samp/summary/top_level_summary/"

fff <- c("PPV.csv",
         "TPR.csv",
         "averCosSim.csv",
         "NumSigsExtracted.csv",
         "falseNeg.csv",
         "falsePos.csv")

dd <- lapply(paste0(home, "/", fff), myread)

# Clean up all csv files after reading
unlink(paste0(home, "/*.csv"))


# Check to make sure the rows in all the files were
# for the same approach, data-set, and run
com <- dd[[1]]
## Check the 1st, 3rd and 4th columns in the files.
for (ii in c(1, 3:4)) {
  cat(
    all(
      unlist(
        lapply(dd, function(xx, col) all(com[ ,  col] == xx[ , col]), ii))),
    "\n")
}

# Make one big tibble (cc)
cc <- dd[[1]]
for (ii in 2:length(dd)) {
  cc2 <- full_join(cc, dd[[ii]])
  cc <- cc2
}

# Make the column names more user-friendly
ccc <- cc[ , c(3, 4, 1, 2, 5:ncol(cc))]
colnames(ccc) <- c("Approach",
                   "Down_samp_level",
                   "Run",
                   "PPV",
                   "TPR",
                   "aver_Sim_TP_only",
                   "N_sigs",
                   "FN",
                   "FP")
# Add Composite Measure after column "Run".
ccc <- ccc %>% 
  mutate(Composite = PPV + TPR + aver_Sim_TP_only,
         .after = aver_Sim_TP_only)

readr::write_csv(ccc, paste0(home, "/../all_results.csv"))




# 2. Summarize extraction measures by software packages and data set ----------
# This is Main Table 2.

ccc_sub <- ccc %>% select(-c(N_sigs, FN, FP))

by.approach.and.data.set <- ccc_sub %>%
  group_by(Down_samp_level, Approach) %>%
  summarise_at(.vars = colnames(ccc_sub)[4:ncol(ccc_sub)], .funs = c(mean, sd))

# Name-fixing function for summary tibbles with two-statistics (mean, sd)
fix.names <- function(nn) {
  vv <- sub("(.*)_fn1", "mean(\\1)", x = nn, perl = TRUE)
  sub("(.*)_fn2", "sd(\\1)", x = vv, perl = TRUE)
}

# Name-fixing function for summary tibbles with three-statistics (mean, median sd)
fix.names.3stats <- function(nn) {
  vv <- sub("(.*)_fn1", "mean(\\1)", x = nn, perl = TRUE)
  ww <- sub("(.*)_fn2", "median(\\1)", x = vv, perl = TRUE)
  sub("(.*)_fn3", "sd(\\1)", x = ww, perl = TRUE)
}


colnames(by.approach.and.data.set) <- fix.names(colnames(by.approach.and.data.set))

# Only keep standard deviation of composite measure,
# and remove standard deviation of all other measures.
by.approach.and.data.set <- by.approach.and.data.set[, -(7:9)]

# Keep only 3 significant digits
by.approach.and.data.set <- 
  by.approach.and.data.set %>% 
  as.data.frame() %>%
  format(digits = 3L, nsmall = 2L)

readr::write_csv(by.approach.and.data.set, 
                 paste0(home, "/../stats_by_approach_and_data_set.csv"))



# 3. Delete folders "top_level_summary" and "toolwise_summary", ---------------
# as they are already included in "all_results.csv".

unlink(paste0(home, "/../toolwise_summary"), recursive = T)
unlink(home, recursive = T)