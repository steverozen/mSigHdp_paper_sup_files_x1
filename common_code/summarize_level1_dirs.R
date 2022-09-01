# To include SigProfilerExtractor extracted signatures
# into the summary, please run 
# common_code/rename_SP_files_level1_dirs.R
# Before running this script.


# Please run this script from the top directory
top.dir <- "mSigHdp_paper_sup_files_x1"
if (basename(getwd()) != top.dir) {
  stop("Please run from top level directory, ", top.dir)
}

# Install and load dependencies -----------------------------------------------
if (!requireNamespace("tibble", quietly = TRUE)) {
  install.packages("tibble")
}
require(ICAMS)
require(SynSigEval)
require(tibble)


# Function for summary directory on one seed ----------------------------------
extract_from_one_seeds_summary <- function(summary.directory.path) {
  gt <- ICAMS::ReadCatalog(file.path(summary.directory.path, "ground.truth.sigs.csv"))
  ex <- ICAMS::ReadCatalog(file.path(summary.directory.path, "extracted.sigs.csv"))
  tff <- mSigTools::TP_FP_FN_avg_sim(ex, gt)
  tff$PPV <- tff$TP / (tff$TP + tff$FP)
  tff$TPR <- tff$TP / (tff$TP + tff$FN)
  return(tff)
}
# debug(SynSigEval:::SummarizeSigOneSubdir)

summarize_level1_dirs <- function(a.folder, delete.non.text = TRUE) {
  message("summarizing a.folder=", a.folder)
  stopifnot(dir.exists(a.folder))
  dataset.name.to.use <- sub("_down_samp", "", a.folder)
  message("using dataset name ", dataset.name.to.use)

  level1.results <- tibble_row(Data_set         = "",
                               Noise_level      = "",
                               Approach         = "",
                               Run              = "",
                               PPV              = -1,
                               TPR              = -1,
                               aver_Sim_TP_only = -1,
                               Composite        = -1,
                               N_Sigs           = -1,
                               FN               = -1,
                               FP               = -1,
                               FP.sigs          = list(character(0)),
                               FN.sigs          = list(character(0)))
  
  start.here <- file.path(a.folder, "raw_results")
  
  tools <- dir(start.here, pattern = "\\.results", full.names = TRUE)
  
  for (analysis.name in tools) {
    stopifnot(dir.exists(analysis.name)) # A full directory path, e.g "indel/raw_results/mSigHdp.results"
    # if (!grepl("NR_hdp_gamma_beta", x = analysis.name)) next
    message("summarizing analysis.name=", analysis.name)
    toolName <- sub(".results", "", basename(analysis.name), fixed = TRUE)
    
    datasetNames <- dir(analysis.name, full.names = TRUE)
    
    for(datasetpath in datasetNames){
      # datasetpath, e.g ""indel/raw_results/mSigHdp.results/Moderate"
      # if (!grepl("Realistic", datasetpath)) next
  
      # datasetName <- basename(datasetpath)
      noise.level <- basename(datasetpath)
      if (!noise.level %in% 
          c("Noiseless", "Moderate", "Realistic")) {
        if (dir.exists(datasetpath)) {
          message("\n\n**Skipping directory ", datasetpath, "**\n\n")
        }
        next
      }
      message("summarizing datasetpath=", datasetpath)
      ground.truth.exposure.dir <-
        file.path(a.folder, "input", noise.level)           
      seedsInUse <- dir(datasetpath, pattern = "seed\\.\\d+", full.names = TRUE)
      
      for(seedInUse in seedsInUse) {
        # seedInUse e.g. "indel/raw_results/mSigHdp.results/Moderate/seed.528401"
        message("summarizing seedInUse=", seedInUse)

        if (!grepl("SignatureAnalyzer", analysis.name)) {
          
          SynSigEval::SummarizeSigOneExtrAttrSubdir(
            run.dir = seedInUse,
            ground.truth.exposure.dir = ground.truth.exposure.dir,
            summarize.exp = F,
            overwrite = T
          )
        } else {
          SynSigEval:::SummarizeSigOneSASubdir(
            run.dir = seedInUse,
            ground.truth.exposure.dir = ground.truth.exposure.dir,
            which.run = "best.run",
            summarize.exp = F,
            overwrite = T
          )
        } # else SignatureAnalyzer
        
        if (delete.non.text) {
          # browser()
          summary.path <- file.path(seedInUse,"summary")
          pdfs.to.delete <- 
            dir(summary.path, pattern = "\\.pdf", full.names = TRUE)
          if (0 != unlink(pdfs.to.delete)) {
            message("unlink of ", 
                    paste(pdfs.to.delete, collapse = " "),
                    " failed")
          }
          also.delete <- 
            dir(summary.path, 
                pattern = "assessment.sessionInfo\\.txt", 
                full.names= TRUE)
          unlink(also.delete)
        }
        
        tff <- extract_from_one_seeds_summary(file.path(seedInUse, "summary"))
        a.row <- tibble_row(Data_set         = dataset.name.to.use,
                            Noise_level      = noise.level,
                            Approach         = toolName,
                            Run              = basename(seedInUse),
                            PPV              = tff$PPV,
                            TPR              = tff$TPR,
                            aver_Sim_TP_only = tff$avg.cos.sim,
                            Composite        = tff$PPV + tff$TPR + tff$avg.cos.sim,
                            N_Sigs           = tff$TP + tff$FP,
                            FN               = tff$FN,
                            FP               = tff$FP,
                            FP.sigs          = list(tff$unmatched.ex.sigs),
                            FN.sigs          = list(tff$unmatched.ref.sigs))

        level1.results <- rbind(level1.results, a.row)
        
      } # for(seedInUse)
      
    } # for (datasetpath in datasetNames)
  } # for (analysis.name in tools)
  
  level1.results <- level1.results[-1, ]
  readr::write_csv(data.table::as.data.table(level1.results), file.path(a.folder, "new_all_sub_results.csv"))
  save(level1.results, file=file.path(a.folder, "level1_results.Rdata"))
  invisible(level1.results)
} # function summarize_something

summarize_all_level1_dirs <- function()  {
  
  level1.dirs <- c("indel_set1",
                   "indel_set1_down_samp",
                   "indel_set2",
                   "indel_set2_down_samp",
                   "SBS_set1",
                   "SBS_set1_down_samp",
                   "SBS_set2",
                   "SBS_set2_down_samp")
  level1.dirs <- c(level1.dirs,
                   paste0("ROC_SBS35_",
                          c(5L, 10L, 20L, 30L, 50L, 100L),
                          "_1066"))
  
  all.out.list <- lapply(level1.dirs, summarize_level1_dirs)
  
  all.results <- do.call(rbind, all.out.list)
  
  NR.approach <- c("NR_hdp_gb_1", "NR_hdp_gb_50", "NR_hdp_gb_20")
  
  all.results.fixed <- 
    dplyr::mutate(all.results, 
                  FP = dplyr::if_else(Approach %in% NR.approach, FP - 1, FP))
  
  foox <- dplyr::filter(all.results, !(Approach %in% NR.approach))
  foo2x <- dplyr::filter(all.results.fixed, !(Approach %in% NR.approach))
  stopifnot(all.equal(foox, foo2x)) # paranoid checking
                         
  readr::write_csv(all.results.fixed, "new_all_results_fixed_by_seed.csv")
  save(all.results.fixed, file = "all_results_fixed_by_seed.Rdata")
  invisible(all.results.fixed)
}

# Run wrapper function to summarize directories of all levels -----------------
all.results.fixed <- summarize_all_level1_dirs()


# development code: -----------------------------------------------------------
foo <- dplyr::filter(
  all.results.fixed,
  Data_set == "SBS_set1" & Noise_level == "Realistic" & Approach == "mSigHdp_ds_3k")
bar <- dplyr::filter(
  all.results.fixed,
  Data_set == "SBS_set1" & Noise_level == "Realistic" & Approach == "SigProfilerExtractor")
bar2 <- dplyr::filter(
  all.results.fixed, 
  Data_set == "SBS_set2" & Noise_level == "Realistic" & Approach == "SigProfilerExtractor")
bar2$FN.sigs