basedir <- "mSigHdp_paper_sup_files_x1" 
if (basename(getwd()) != basedir) {
  stop("Please run from top level directory, ", basedir)
}


library(data.table)
library(tibble)
library(magrittr)
library(dplyr)
library(beeswarm)

split_by_approach_and_pull <- function(vv, approaches.to.use) {
  xxs     <- split(vv, vv$Approach)
  
  # This makes sure that the elements of xx2 are in the same order as 
  # the elments of approaches.to.use, which should be in the order 
  # we want for columns of the eventual beeswarm graph.
  xxs2    <- xxs[approaches.to.use] 
  
  comp <- lapply(xxs2, pull, "Composite")
  tpr  <- lapply(xxs2, pull, "TPR")
  ppv  <- lapply(xxs2, pull, "PPV")
  sim  <- lapply(xxs2, pull, "aver_Sim_TP_only")
  return(list(split = xxs2, comp = comp, tpr = tpr, ppv = ppv, sim =sim))
}

four_beeswarms <- function(ww, main, col, pch, filename,
                           mfrow = c(2,2),
                           legend.fn = NULL) {
  grDevices::cairo_pdf(
    filename = filename,
    height = 9, 
    onefile = TRUE)
  par(mfrow = mfrow, mar = c(9, 4, 4, 2) + 0.1)
  
  beeswarm(x = ww$comp, las = 2, ylab = "Composite measure", 
           pwpch = pch, pwcol = col,
           main = main)
  
  if (!is.null(legend.fn)) { # Not working, not sure why 2022 09 01
    # browser()
    legend.fn()
    legend(x = "top",
           legend = paste0("set", 1:2),
           col    = c("red",  "blue"),
           pch    = c(16,     17))
  }
  beeswarm(x = ww$ppv, las = 2,  ylab = "PPV", 
           pwpch = pch, pwcol = col)
  beeswarm(x = ww$tpr, las = 2, ylab = "TPR", 
           pwpch = pch, pwcol = col)
  beeswarm(x = ww$sim, las = 2, ylab = "Cosine similarity", 
           pwpch = pch, pwcol = col)
  grDevices::dev.off()
  
}

generic_4_beeswarm_fig <-
  function(tt, 
           approaches.to.use, # character vector of names of approaches
           sbs.or.indel, 
           file.name.prefix,
           legend.fn = NULL) {

  set1 <- paste0(sbs.or.indel, "_set1")
  set2 <- paste0(sbs.or.indel, "_set2")
  t1 <- filter(tt, Noise_level == "Realistic")
  xx <- filter(t1, Data_set %in% c(set1, set2))

  ww <- split_by_approach_and_pull(xx, approaches.to.use)
  xx.data.set <- unlist(lapply(ww$split, pull, "Data_set"))

  col <- ifelse(xx.data.set == set1, "red", "blue")
  pch <- ifelse(xx.data.set == set1, 16, 17)
  
  four_beeswarms(ww, 
                 main = paste0(sbs.or.indel, "; red = set1, blue = set2"),
                 col,
                 pch,
                 filename = paste0(file.name.prefix, sbs.or.indel, ".pdf"),
                 legend.fn = legend.fn)
}


downsample_indel_fig <- function(tt) {
  approaches <- c("mSigHdp", 
                  # "mSigHdp_ds_non_hyper", 
                  "mSigHdp_ds_10k", 
                  "mSigHdp_ds_5k",
                  "mSigHdp_ds_3k", 
                  "mSigHdp_ds_1k",  
                  "mSigHdp_ds_500"
                  )
  generic_4_beeswarm_fig(tt, approaches, "indel", "draft_downsampling_fig_")
  
}

downsample_SBS_fig <- function(tt) {
  approaches <- c("mSigHdp",
                  "mSigHdp_ds_10k",
                  "mSigHdp_ds_5k",
                  "mSigHdp_ds_3k",
                  "mSigHdp_ds_1k"
  )
  generic_4_beeswarm_fig(tt, approaches, "SBS", "draft_downsampling_fig_")
  
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


# Start here
SBS35_detect <- function(tt) {
  spike.in.counts <- c(5L, 10L, 20L, 30L, 50L)  # , 100L) # No data for this yet
  data.sets <-paste0("ROC_SBS35_", spike.in.counts, "_1066")
  data.set.2.count <- spike.in.counts
  names(data.set.2.count) <- data.sets
  tt1 <- dplyr::filter(tt, Data_set %in% data.sets)
  tt2 <- dplyr::filter(tt1, Noise_level == "Realistic")
  tt3 <- dplyr::filter(tt2, 
                       Approach %in% c("mSigHdp_ds_3k",
                                       "SigProfilerExtractor"))
  FNs <- dplyr::pull(tt3, FN.sigs)
  SBS35.found <- unlist(lapply(FNs, function(zz) !any(grepl("SBS35", zz, fixed = TRUE))))
  tt4 <- mutate(tt3, SBS35.found = SBS35.found)
  tt5 <- tt4[ , c("Data_set", "Approach", "Run", "SBS35.found", "FN.sigs")]
  group_by(tt5, Data_set, Approach) %>% 
    summarise(avg.found = mean(SBS35.found), .groups = "drop") -> tt6

  tt7 <- mutate(tt6, spike.in.count = data.set.2.count[Data_set])
  to.plot <- split(tt7, tt7$spike.in.count)
  to.plot <- to.plot[as.character(spike.in.counts)]
  to.plot2 <- lapply(to.plot, pull, avg.found)
  to.plot2.app <- unlist(lapply(to.plot, pull, Approach))
    
  col <- ifelse(to.plot2.app == "mSigHdp_ds_3k", "blue", "red")

  pch <- ifelse(to.plot2.app == "mSigHdp_ds_3k", 16, 17)

  grDevices::cairo_pdf(
    filename = "draft_sensitivity.pdf",
    height = 4, 
    onefile = TRUE)
  # Better to change to a groupd box plot
  beeswarm(x = to.plot2, las = 2, 
           ylab = "Proportion with SBS35 detected", 
           xlab = "Number of samples with SBS35",
           pwpch = pch, pwcol = col)
  dev.off()
  
  invisible(to.plot)
  
}


main_text_cpu <- function(sbs.or.indel, approaches.to.use) {
  uu <- data.table::fread("cpu_time_by_seed.csv")
  data.sets <- paste0(sbs.or.indel, "_set", c(1, 2))
  uu1 <- filter(uu, Noise_level == "Realistic" & Data_set %in% data.sets & Approach %in% approaches.to.use)
  uu2 <- mutate(uu1, CPU.days = CPU_time / (60 * 60 * 24))
  # browser()
  to.plot <- split(uu2, uu2$Approach)
  to.use <- which(approaches.to.use %in% names(to.plot))
  approaches.to.use <- approaches.to.use[to.use]
  to.plot <- to.plot[approaches.to.use]
  to.plot2 <- lapply(to.plot, pull, CPU.days)
  
  xx.data.set <- unlist(lapply(to.plot, pull, "Data_set"))
  
  col <- ifelse(xx.data.set == data.sets[1], "red", "blue")
  pch <- ifelse(xx.data.set == data.sets[1], 16, 17)
  

  beeswarm(x      = to.plot2, 
           las    = 2, 
           ylab   = "CPU days", 
           # xlab = "Approach",
           main   = sbs.or.indel,
           pwpch  = pch, pwcol = col)
  
  legend(x = "top",
         legend = paste0(sbs.or.indel, "_set", 1:2),
         col    = c("red",  "blue"),
         pch    = c(16,     17))

}

set1_set2_legend <- function(sbs.or.indel) {
  legend(x = "top",
         legend = paste0(sbs.or.indel, "_set", 1:2),
         col    = c("red",  "blue"),
         pch    = c(16,     17))
}

all_figs_this_file <- function(tt) {
  # tt should be the output of summarize_all_level1_dirs in file summarize_level1_dirs.R
  
  
  main.text.SBS.approaches <- 
    c("mSigHdp_ds_3k",
      "mSigHdp",
      "SigProfilerExtractor",
      "NR_hdp_gb_20",
      "NR_hdp_gb_1",
      "signeR",
      "SignatureAnalyzer")
  
  generic_4_beeswarm_fig(tt, main.text.SBS.approaches, "SBS", "draft_main_text_fig_",
                         legend.fn = function() { set1_set2_legend("SBS")})
  
  
  main.text.indel.approaches <- 
    c("mSigHdp",
      "SigProfilerExtractor",
      "NR_hdp_gb_50", 
      "NR_hdp_gb_1",
      "SignatureAnalyzer",
      "signeR")
  
  generic_4_beeswarm_fig(tt, main.text.indel.approaches, "indel",  "draft_main_text_fig_")
  
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
  SBS35_detect(tt)
  
  grDevices::cairo_pdf(
    filename = "draft_CPU_time.pdf",
    height   = 14,
    width    = 7, 
    onefile = TRUE)
  par(mfrow = c(2, 1), mar = c(9, 4, 4, 2) + 0.1)
  main_text_cpu("SBS",   main.text.SBS.approaches)

  main_text_cpu("indel", main.text.indel.approaches)
  dev.off()
}

all_figs_this_file(all.results.fixed) # computed in summarize_level1_dirs.R
