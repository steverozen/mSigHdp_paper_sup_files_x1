library(data.table)
library(tibble)
library(magrittr)
library(dplyr)

all_result_dirs <- function() {
  # Map from folder name to data set
  return(list(indel             = "indel_set1",
              indel_2           = "indel_set2",
              indel_down_samp   = "indel_set1",
              indel_2_down_samp = "indel_set2",
              SBS               = "SBS_set1",
              SBS_2             = "SBS_set2",
              SBS_down_samp     = "SBS_set1",
              SBS_2_down_samp   = "SBS_set2"))
}

one_top_level_dir <- function(dir.name, data.set) {
  # cat(dir.name, data.set, "\n")
  summary.file <- file.path(dir.name, "summary", "all_results.csv")
  dd <- data.table::fread(summary.file)
  cn <- colnames(dd)
  if (cn[2] == "Down_samp_level")  {
    new.approach <- apply(dd[ , c("Approach", "Down_samp_level")],
                          MARGIN = 1, paste, collapse = ".ds.")
    dd[ , "Approach"] <- new.approach
    dd[ , 2] <- "Realistic"
    colnames(dd)[2] <- "Noise_level"
  } else {
    stopifnot(cn[2] == "Noise_level")
  }
  dd[ , "Data_set"] <- data.set
  dd <- dd[ , c(11, 2, 1, 3:10)]
  return(dd)
}


main_text_SBS_or_indel_fig <- function(tt, approach.to.use, sbs.or.indel) {

  set1 <- paste0(sbs.or.indel, "_set1")
  set2 <- paste0(sbs.or.indel, "_set2")
  
  tt %>% filter(Noise_level == "Realistic") %>% 
    filter(Approach %in% approach.to.use) %>%
    filter(Data_set %in% c(set1, set2)) -> xx

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
    filename = paste0("draft_main_text_fig_", sbs.or.indel, ".pdf"),
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
    c("mSigHdp.ds.3k",
      "mSigHdp",
      "SigProfilerExtractor",
      "NR_hdp_gb_20",
      "signeR",
      "SignatureAnalyzer" # "NR_HDP_gb_1 is not present yet
    )
  
  main_text_SBS_or_indel_fig(tt, approach.to.use, "SBS")
}


main_text_indel_fig <- function(tt) {
  stopifnot(tibble::is_tibble(tt))
  approach.to.use <- 
    c("mSigHdp",
      "SigProfilerExtractor",
      # "NR_hdp_gb_20", # These are not in indel/summary/all_results.csv
      # "NR_HDP_gb_1",  # indel_2/summary/all_results.csv, even thought they were run
      "signeR",
      "SignatureAnalyzer"     )
  
  main_text_SBS_or_indel_fig(tt, approach.to.use, "indel")
}




top_level_analysis <- function() {
  all.dirs <- all_result_dirs()

  all.summaries <- lapply(names(all.dirs), 
                     function(dir.name) { 
                       one_top_level_dir(dir.name, all.dirs[[dir.name]]) })
  # Maybe add info from e.g.
  # indel/raw_results/mSigHdp.results/Realistic/seed.1076753/summary{other.results, "etc"}
  # There are problems - with 
  tt <- do.call(rbind, all.summaries)
  data.table::fwrite(tt, "all_results_by_seed.csv")
  invisible(tibble::as_tibble(tt))
}

if (T) {
  uu <- top_level_analysis()
  main_text_SBS_fig(uu)
  # main_text_indel_fig(uu)
}