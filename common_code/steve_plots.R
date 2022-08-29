basedir <- "mSigHdp_paper_sup_files_x1" 
if (basename(getwd()) != basedir) {
  stop("Please run from top level directory, ", basedir)
}


library(data.table)
library(tibble)
library(magrittr)
library(dplyr)
library(beeswarm)

split_by_approach_and_pull <- function(vv, approach.to.use) {
  xxs     <- split(vv, vv$Approach)
  xxs2    <- xxs[approach.to.use]
  comp <- lapply(xxs2, pull, "Composite")
  tpr  <- lapply(xxs2, pull, "TPR")
  ppv  <- lapply(xxs2, pull, "PPV")
  sim  <- lapply(xxs2, pull, "aver_Sim_TP_only")
  return(list(split = xxs2, comp = comp, tpr = tpr, ppv = ppv, sim =sim))
}

four_beeswarms <- function(ww, main, col, pch, filename, mfrow = c(2,2)) {
  grDevices::cairo_pdf(
    filename = filename,
    height = 9, 
    onefile = TRUE)
  par(mfrow = mfrow, mar = c(9, 4, 4, 2) + 0.1)
  
  beeswarm(x = ww$comp, las = 2, ylab = "Composite measure", 
           pwpch = pch, pwcol = col,
           main = main)
  beeswarm(x = ww$ppv, las = 2,  ylab = "PPV", 
           pwpch = pch, pwcol = col)
  beeswarm(x = ww$tpr, las = 2, ylab = "TPR", 
           pwpch = pch, pwcol = col)
  beeswarm(x = ww$sim, las = 2, ylab = "Cosine similarity", 
           pwpch = pch, pwcol = col)
  grDevices::dev.off()
  
}

generic_beeswarm_fig <-
  function(tt, approach.to.use, sbs.or.indel, file.name.prefix) {

  set1 <- paste0(sbs.or.indel, "_set1")
  set2 <- paste0(sbs.or.indel, "_set2")
  t1 <- filter(tt, Noise_level == "Realistic")
  xx <- filter(t1, Data_set %in% c(set1, set2))

  ww <- split_by_approach_and_pull(xx, approach.to.use)
  xx.data.set <- unlist(lapply(ww$split, pull, "Data_set"))

  col <- ifelse(xx.data.set == set1, "red", "blue")
  pch <- ifelse(xx.data.set == set1, 16, 17)
  
  four_beeswarms(ww, 
                 main = paste0(sbs.or.indel, "; red = set1, blue = set2"),
                 col,
                 pch,
                 filename = paste0(file.name.prefix, sbs.or.indel, ".pdf"))
}

main_text_SBS_fig <- function(tt) {
  stopifnot(tibble::is_tibble(tt))
  approach.to.use <- 
    c("mSigHdp_ds_3k",
      "mSigHdp",
      "SigProfilerExtractor",
      "NR_hdp_gb_20",
      "NR_hdp_gb_1",
      "signeR",
      "SignatureAnalyzer" # "NR_HDP_gb_1 is not present yet
    )
  
  generic_beeswarm_fig(tt, approach.to.use, "SBS", "draft_main_text_fig_")
}


main_text_indel_fig <- function(tt) {
  stopifnot(tibble::is_tibble(tt))
  approach.to.use <- 
    c("mSigHdp",
      "SigProfilerExtractor",
      "NR_hdp_gb_50", 
      "NR_hdp_gb_1",
      "SignatureAnalyzer",
      "signeR")
  
  generic_beeswarm_fig(tt, approach.to.use, "indel",  "draft_main_text_fig_")
}
# c("mSigHdp", "NR_hdp_gb_1", "NR_hdp_gb_50", "SignatureAnalyzer",  "signeR", "SigProfilerExtractor", "mSigHdp_ds_10k", "mSigHdp_ds_1k",  "mSigHdp_ds_3k", "mSigHdp_ds_500", "mSigHdp_ds_5k", "mSigHdp_ds_non_hyper" )

# SBS downsampling methods


downsample_indel_fig <- function(tt) {
  approaches <- c("mSigHdp", 
                  # "mSigHdp_ds_non_hyper", 
                  "mSigHdp_ds_10k", 
                  "mSigHdp_ds_5k",
                  "mSigHdp_ds_3k", 
                  "mSigHdp_ds_1k",  
                  "mSigHdp_ds_500"
                  )
  generic_beeswarm_fig(tt, approaches, "indel", "draft_downsampling_fig_")
  
}

downsample_SBS_fig <- function(tt) {
  approaches <- c("mSigHdp",
                  "mSigHdp_ds_10k",
                  "mSigHdp_ds_5k",
                  "mSigHdp_ds_3k",
                  "mSigHdp_ds_1k"
  )
  generic_beeswarm_fig(tt, approaches, "SBS", "draft_downsampling_fig_")
  
}


noise_level_fig <- function(tt, indel.or.sbs, approach) {

  # filter by approach and by indel_set1
  # split by approach, color by noise level
  data.set = paste0(indel.or.sbs, "_set1")
  tt1 <- dplyr::filter(tt, Data_set == data.set)
  ww <- split_by_approach_and_pull(tt1, approach)
  xx.noise.level <- unlist(lapply(ww$split, pull, "Noise_level"))
  
  # Color by noise
  col <- ifelse(xx.noise.level == "Realistic", "red",
                ifelse(xx.noise.level == "Moderate", "violet", "blue"))
  
  pch <- ifelse(xx.noise.level == "Realistic", 16,
                ifelse(xx.noise.level == "Moderate", 17, 18))
  
  four_beeswarms(
    ww,
    main = paste0(indel.or.sbs, "\nred = Realistic, violet = Moderate, blue = Noiseless"),
    col,
    pch,
    filename = paste0(indel.or.sbs, "_noise.pdf"),
    mfrow = c(2, 1))

}


all_figs_this_file <- function(tt) {
  # tt should be the output of summarize_all_level1_dirs in file summarize_level1_dirs.R
  
  noise_level_fig(tt, "indel",approach = c("mSigHdp",
                                           "SigProfilerExtractor",
                                           "SignatureAnalyzer",
                                           "signeR")) # Order of SA and signeR are reversed between indel and SBS
  
  
  noise_level_fig(tt, "SBS",approach = c("mSigHdp_ds_3k",
                                         "mSigHdp",
                                         "SigProfilerExtractor",
                                         "signeR",
                                         "SignatureAnalyzer"))
  main_text_indel_fig(tt)
  main_text_SBS_fig(tt)
  downsample_indel_fig(tt)
  downsample_SBS_fig(tt)
}

all_figs_this_file(all.results.fixed) # computed in summarize_level1_dirs.R
