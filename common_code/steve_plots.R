library(data.table)
library(tibble)
library(magrittr)
library(dplyr)
library(beeswarm)

generic_beeswarm_fig <-
  function(tt, approach.to.use, sbs.or.indel, file.name.prefix) {

  set1 <- paste0(sbs.or.indel, "_set1")
  set2 <- paste0(sbs.or.indel, "_set2")
  t1 <- filter(tt, Noise_level == "Realistic")
  t2 <-  filter(t1, Approach %in% approach.to.use)
  xx <- filter(t2, Data_set %in% c(set1, set2))

  xxs <- split(xx, xx$Approach)
  xxs2 <- xxs[approach.to.use]
  xx.comp     <- lapply(xxs2, pull, "Composite")
  xx.tpr      <- lapply(xxs2, pull, "TPR")
  xx.ppv      <- lapply(xxs2, pull, "PPV")
  xx.sim      <- lapply(xxs2, pull, "aver_Sim_TP_only")
  xx.data.set <- unlist(lapply(xxs2, pull, "Data_set"))

  col <- ifelse(xx.data.set == set1, "red", "blue")
  pch <- ifelse(xx.data.set == set1, 16, 17)
  
  grDevices::cairo_pdf(
    filename = paste0(file.name.prefix, sbs.or.indel, ".pdf"),
    height = 9)
  par(mfrow = c(2,2), mar = c(9, 4, 4, 2) + 0.1)
  
  beeswarm(x = xx.comp, las = 2, ylab = "Composite measure", 
           pwpch = pch, pwcol = col,
           main = paste0(sbs.or.indel, "; red = set1, blue = set2"))
  beeswarm(x = xx.ppv, las = 2,  ylab = "PPV", 
           pwpch = pch, pwcol = col)
  beeswarm(x = xx.tpr, las = 2, ylab = "TPR", 
           pwpch = pch, pwcol = col)
  beeswarm(x = xx.sim, las = 2, ylab = "Cosine similarity", 
           pwpch = pch, pwcol = col)
  grDevices::dev.off()
}

main_text_SBS_fig <- function(tt) {
  stopifnot(tibble::is_tibble(tt))
  approach.to.use <- 
    c("mSigHdp_ds_3k",
      "mSigHdp",
      "SigProfilerExtractor",
      "NR_hdp_gb_20",
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
      "signeR",
      "SignatureAnalyzer"     )
  
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


main_text_indel_fig(tt)
main_text_SBS_fig(tt)
downsample_indel_fig(tt)
