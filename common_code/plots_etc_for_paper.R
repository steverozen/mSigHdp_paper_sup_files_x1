basedir <- "mSigHdp_paper_sup_files_x1" 
if (basename(getwd()) != basedir) {
  stop("Please run from top level directory, ", basedir)
}

# Loading required packages ---------------------------------------------------
library(data.table)
library(tibble)
library(magrittr)
library(dplyr)
library(beeswarm)
library(openxlsx) # https://cran.r-project.org/web/packages/openxlsx/openxlsx.pdf


# Utility functions -----------------------------------------------------------
outpath <- function(filename) {
  file.path("output_for_paper", filename)
}

set1_pch <- 16
set2_pch <- 17

split_by_approach_and_pull <- function(vv, approaches.to.use) {
  xxs     <- split(vv, vv$Approach)

  # This makes sure that the elements of xx2 are in the same order as 
  # the elements of approaches.to.use, which should be in the order 
  # we want for columns of the eventual beeswarm graph.
  xxs2    <- xxs[approaches.to.use] 
  
  my.pull <- function(my.approach, colname) { # only use my.pull for debugging
                                              # anly apply it to approaches.to.use
    zz <- xxs[[my.approach]]
    if (length(zz) == 0) {
      stop("No results for my.approach = ", my.approach, " colname = ", colname)
      
    }
    pull(zz, colname)}
  comp <- lapply(xxs2, pull, "Composite")
  tpr  <- lapply(xxs2, pull, "TPR")
  ppv  <- lapply(xxs2, pull, "PPV")
  sim  <- lapply(xxs2, pull, "aver_Sim_TP_only")
  return(list(split = xxs2, comp = comp, tpr = tpr, ppv = ppv, sim =sim))
}


# Definition of plotting functions --------------------------------------------
four_beeswarms <- function(ww, main, col, pch, filename,
                           mfrow = c(3,1),
                           legend.fn = NULL,
                           mar = c(9, 12, 4, 12) + 0.1) {

  grDevices::cairo_pdf(
    filename = outpath(filename),
    height = 9, 
    onefile = TRUE)
  par(mfrow = mfrow, mar = mar)

  beeswarm(x = ww$comp, las = 2, ylab = "Composite measure", 
           pwpch = pch, pwcol = col, labels = "")
  if (!is.null(legend.fn)) {
    legend.fn()
  }
  
  beeswarm(x = ww$ppv, las = 2,  ylab = "PPV", 
           pwpch = pch, pwcol = col, labels = "")
  
  beeswarm(x = ww$tpr, las = 2, ylab = "TPR", 
           pwpch = pch, pwcol = col, labels = "")
  
  beeswarm(x = ww$sim, las = 2, ylab = "Cosine similarity", 
           pwpch = pch, pwcol = col)
  

  grDevices::dev.off()
  
}


generic_4_beeswarm_fig <-
  function(tt, 
           approaches.to.use, # character vector of names of approaches
           sbs.or.indel, 
           file.name.prefix,
           legend.fn = NULL,
           col       = "black",
           mfrow = c(3, 1),
           mar = c(8, 15, 4, 14) + 0.1) {

  set1 <- paste0(sbs.or.indel, "_set1")
  set2 <- paste0(sbs.or.indel, "_set2")
  t1 <- filter(tt, Noise_level == "Realistic")
  xx <- filter(t1, Data_set %in% c(set1, set2))

  ww <- split_by_approach_and_pull(xx, approaches.to.use)
  xx.data.set <- unlist(lapply(ww$split, pull, "Data_set"))

  col <- ifelse(xx.data.set == set1, "black", "black")
  pch <- ifelse(xx.data.set == set1, set1_pch, set2_pch)
  
  four_beeswarms(ww,
                 col       = col,
                 pch       = pch,
                 filename  = paste0(file.name.prefix, sbs.or.indel, ".pdf"),
                 legend.fn = legend.fn,
                 mfrow     = mfrow,
                 mar       = mar)
}

downsample_indel_fig <- function(tt) {
  approaches <- c("mSigHdp", 
                  "mSigHdp_ds_10k", 
                  "mSigHdp_ds_5k",
                  "mSigHdp_ds_3k", 
                  "mSigHdp_ds_1k")
  generic_4_beeswarm_fig(tt                = tt, 
                         approaches.to.use = approaches, 
                         sbs.or.indel      = "indel", 
                         file.name.prefix  = "downsampling_",
                         mfrow = c(3, 1),
                         mar = c(8, 14, 4, 14) + 0.1,
                         legend.fn = function() { set1_set2_legend("indel")})
  
}

downsample_SBS_fig <- function(tt) {
  approaches <- c("mSigHdp",
                  "mSigHdp_ds_10k",
                  "mSigHdp_ds_5k",
                  "mSigHdp_ds_3k",
                  "mSigHdp_ds_1k"
  )
  generic_4_beeswarm_fig(tt, approaches, "SBS", "downsampling_",
                         mfrow = c(3, 1),
                         mar = c(8, 14, 4, 14) + 0.1,
                         legend.fn = function() { set1_set2_legend("SBS")})
  
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
  
  pch <- ifelse(xx.noise.level == "Realistic", set1_pch,
                ifelse(xx.noise.level == "Moderate", set1_pch, set1_pch))
  
  four_beeswarms(
    ww,
    col      = col,
    pch      = pch,
    filename = paste0(indel.or.sbs, "_noise.pdf"),
    legend.fn = function() {
      legend(x = "bottomleft",
             title  = "Resampling noise",
             legend = c("None", "Moderate", "Realistc"),
             col    = c("blue",  "violet", "red"),
             pch    = 18:16,
             bty    = "n")
    })

}

SBS35_detect_fig <- function(tt) {

  sigpro.pch  <- "S"
  msighdp.pch <- "M"
  ds1.col     <- "cornflowerblue"
  ds2.col     <- "coral"
  
  spike.in.counts <- c(5L, 10L, 20L, 30L, 50L, 100L)
  data.sets.1066 <- paste0("sens_SBS35_", spike.in.counts, "_1066")
  data.sets.728 <- paste0("sens_SBS35_", spike.in.counts, "_728")
  data.sets <- c(data.sets.1066, data.sets.728)
  data.set.2.count <- rep(spike.in.counts, 2)
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
  to.plot2.dset <- unlist(lapply(to.plot, pull, Data_set))

  data.set.1066 <- grepl("_1066$", to.plot2.dset)
  
  col <- ifelse(data.set.1066, ds1.col, ds2.col)
  pch <- ifelse(to.plot2.app == "mSigHdp_ds_3k", msighdp.pch, sigpro.pch)

  grDevices::cairo_pdf(
    filename = outpath("sensitivity.pdf"),
    height = 4, 
    onefile = TRUE)
  par(mar = c(5.1, 5.1, 4.1, 2.1))

  beeswarm(x = to.plot2, las = 2, 
           ylab = "Proportion of 5 runs\nin which SBS35 was detected", 
           xlab = "Number of synthetic spectra containing SBS35",
           pwpch = pch, pwcol = col, spacing = 1.6)
  legend(x        = "bottomright",
         legend   = c("mSigHdp data set 1",
                      "mSigHdp data set 2",
                      "SigProfilerExtractor data set 1",
                      "SigProfilerExtractor data set 2"),
         col      = c(ds1.col, ds2.col, ds1.col, ds2.col),
         text.col = c(ds1.col, ds2.col, ds1.col, ds2.col),
         pch      = c(msighdp.pch, msighdp.pch, sigpro.pch, sigpro.pch),
         bty      = "n")
  dev.off()
  
  invisible(to.plot)
  
}


main_text_cpu <- function(sbs.or.indel, approaches.to.use) {
  # browser()
  uu <- data.table::fread(outpath("supplementary_table_s5.csv"))
  data.sets <- paste0(sbs.or.indel, "_set", c(1, 2))
  filter(uu, 
         Noise_level == "Realistic" &
           Data_set %in% data.sets & Approach %in% approaches.to.use) %>%
    mutate(CPU.days = cpu_time / (60 * 60 * 24)) %>%
    mutate(Noise_level = NULL, cpu.time = NULL) -> uu3
  # browser()
  to.plot <- split(uu3, uu3$Approach)
  to.use <- which(approaches.to.use %in% names(to.plot))
  approaches.to.use <- approaches.to.use[to.use]
  to.plot <- to.plot[approaches.to.use]
  
  
  # fwrite(uu3, outpath(paste0(sbs.or.indel, "_cpu.csv")))
  
  dplyr::group_by(uu3, Data_set, Approach) %>%
    dplyr::summarise(mean_CPU_days = mean(CPU.days)) %>%
    fwrite(outpath(paste0(sbs.or.indel, "_cpu_summary.csv")))
  
  to.plot2 <- lapply(to.plot, pull, CPU.days)
  
  xx.data.set <- unlist(lapply(to.plot, pull, "Data_set"))
  
  col <- ifelse(xx.data.set == data.sets[1], "black", "black")
  pch <- ifelse(xx.data.set == data.sets[1], set1_pch, set2_pch)
  
  beeswarm(x      = to.plot2, 
           las    = 2, 
           ylab   = "CPU days",
           pwpch  = pch,
           pwcol = col)
  
  legend(x = "topright",
         legend = paste0(sbs.or.indel, "_set", 1:2),
         col    = "black", # c("red",  "blue"),
         pch    = c(16,     17),
         bty    = "n")
}

set1_set2_legend <- function(sbs.or.indel) {
  legend(x = "bottomleft",
         legend = paste0(sbs.or.indel, "_set", 1:2),
         col    = c("black",  "black"),
         pch    = c(16,     17),
         bty    = "n")
}


main_text_table <- function(tt, approaches.to.use, sbs.or.indel) {
  set1 <- paste0(sbs.or.indel, "_set1")
  set2 <- paste0(sbs.or.indel, "_set2")

  t1 <- filter(
    tt, 
    Data_set %in% c(set1, set2), 
    Noise_level == "Realistic",
    Approach %in% approaches.to.use) -> t2
  
  if (sbs.or.indel == "SBS") {
    best <- "mSigHdp_ds_3k"
  } else {
    best <- "mSigHdp"
  }
  wt <- wilcox.test(Composite ~ Approach, 
                    data = t2, 
                    subset = Approach %in% c(best, "SigProfilerExtractor"))
  message(sbs.or.indel, " Wilcoxon rank-sum test")
  print(wt)
  dplyr::group_by(t2, Approach) %>%
    dplyr::summarise(mean_comp = mean(Composite),
                     sd_comp   = sd(Composite),
                     mean_PPV  = mean(PPV),
                     mean_TPR  = mean(TPR),
                     mean_cos  = mean(aver_Sim_TP_only)) %>%
    dplyr::arrange(desc(mean_comp)) -> grand.means
  
  fwrite(grand.means,
         outpath(paste0(sbs.or.indel, "_grand_means.csv")))
  
  dplyr::group_by(t2, Data_set, Approach) %>%
    dplyr::summarise(mean_comp = mean(Composite),
                     sd_comp   = sd(Composite),
                     mean_PPV  = mean(PPV),
                     mean_TPR  = mean(TPR),
                     mean_cos  = mean(aver_Sim_TP_only)
    ) %>%
    arrange(desc(mean_comp), .by_group = TRUE) -> t3
  
  
  t3 %>% filter(Data_set == set1) %>% nrow -> num.set1
  # browser()
  colnames(t3) <- c("Data\nset", "Approach",
                    "Mean", "SD", # For composite measure
                    "Mean\nPPV", "Mean\nTPR",
                    "Mean cosine\nsimilarity")
  
  wb <- createWorkbook()
  
  heading.style <- 
    createStyle(halign = "center", textDecoration = "bold", 
                wrapText = TRUE, valign = "center",
                borderStyle = "medium", border = "bottom")
  
  num.style <- 
    createStyle(numFmt = "0.00", halign = "center")
  
  left.style <- 
    createStyle(valign = "center", halign = "center", 
                textDecoration = "bold")
  
  top.border.style <- createStyle(border = "top", borderStyle = "medium")
  
  addWorksheet(wb, sbs.or.indel)
  
  startrow <- 1
  writeData(wb, 1, "Composite measure", startCol = 3, startRow = startrow)
  mergeCells(wb, 1, cols = 3:4, rows = startrow) # Merge "Composite measure"
  
  datarow1 <- startrow + 2
  writeData(wb, 1, t3, startRow = datarow1 - 1, startCol = 1)
  set2.datarow1 <- datarow1 + num.set1
  
  mergeCells(wb, 1, cols = 1, rows = datarow1:(set2.datarow1 - 1))

  last.datarow <- datarow1 + nrow(t3) - 1
  
  mergeCells(wb, 1, cols = 1, rows = set2.datarow1:last.datarow)
   
  addStyle(wb, 1, num.style, cols = 3:7,  
           rows = datarow1:last.datarow,
           gridExpand = TRUE)
  
  addStyle(wb, 1, heading.style, 
           cols = 1:7, rows = startrow + 1, gridExpand = TRUE)
  addStyle(wb, 1, 
           heading.style, cols = 3:4, rows = startrow, gridExpand = TRUE)

  addStyle(wb, 1, left.style, cols = 1, rows = datarow1:last.datarow)
  
  addStyle(wb, 1, top.border.style, cols = 1:7, rows = last.datarow + 1)
  
  writeData(wb, 1, startCol = 1, startRow = last.datarow + 2,
            paste0("Wilcoxon rank-sum test ", best, " vs ", "SigProfilerExtractor p = ",
            format(wt$p.value, scientific = TRUE, digits = 4)))

  saveWorkbook(wb, outpath(paste0(sbs.or.indel, ".table.xlsx")), overwrite = TRUE)
  
  t3
}


all_figs_and_tables_this_file <- function(tt) {
  # tt should be the output of summarize_all_level1_dirs in file summarize_level1_dirs.R
  
  main.text.SBS.approaches <- 
    c("mSigHdp_ds_3k",
      "mSigHdp",
      "SigProfilerExtractor",
      "NR_hdp_gb_20",
      "NR_hdp_gb_1",
      "signeR",
      "SignatureAnalyzer")

  generic_4_beeswarm_fig(
    tt = tt, 
    approaches.to.use = main.text.SBS.approaches,
    sbs.or.indel      = "SBS", 
    file.name.prefix  = "main_text_",
    mfrow             = c(3, 1),
    mar               = c(8, 14, 4, 14) + 0.1,
    legend.fn         = function() { set1_set2_legend("SBS")})
  
  main_text_table(
    tt                = tt,
    approaches.to.use = main.text.SBS.approaches,
    sbs.or.indel      = "SBS"
  )
  
  main.text.indel.approaches <- # Important, this is the order in the main text figure; make sure it is sorted by the average composite measure in indel_set1 and indel_set2
    c("mSigHdp",
      "NR_hdp_gb_50", 
      "NR_hdp_gb_1",
      "SigProfilerExtractor",
      "SignatureAnalyzer",
      "signeR")
  
  main_text_table(
    tt                = tt,
    approaches.to.use = main.text.indel.approaches,
    sbs.or.indel      = "indel"
  )
  
  generic_4_beeswarm_fig(tt, main.text.indel.approaches, "indel",  "main_text_",
                         mfrow = c(3, 1),
                         mar = c(8, 14, 4, 14) + 0.1,
                         legend.fn = function() { set1_set2_legend("indel")})
  
  noise_level_fig(tt, "indel",approach = c("mSigHdp",
                                           "SigProfilerExtractor",
                                           "SignatureAnalyzer",
                                           "signeR")) # Order of SA and signeR are reversed between indel and SBS
  
  
  noise_level_fig(tt, "SBS",approach = c("mSigHdp_ds_3k",
                                         "mSigHdp",
                                         "SigProfilerExtractor",
                                         "signeR",
                                         "SignatureAnalyzer"))
  downsample_indel_fig(tt)
  downsample_SBS_fig(tt)
  SBS35_detect_fig(tt)
  
  grDevices::cairo_pdf(
    filename = outpath("CPU_time.pdf"),
    height   = 14,
    width    = 7, 
    onefile = TRUE)
  par(mfrow = c(3, 1), mar = c(9, 12, 4, 12) + 0.1)
  main_text_cpu("SBS",   main.text.SBS.approaches)

  main_text_cpu("indel", main.text.indel.approaches)
  dev.off()

}


# Calling plotting functions --------------------------------------------------
load(outpath("supplementary_table_s4.Rdata")) # Load object `all.results.fixed`
all_figs_and_tables_this_file(all.results.fixed)
# computed in summarize_level1_dirs.R
