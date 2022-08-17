# Please run this script from the top directory
top.dir <- "mSigHdp_paper_sup_files_x1"
if (basename(getwd()) != top.dir) {
  stop("Please run from top level directory, ", top.dir)
}

if (FALSE) {
# Install and load dependencies -----------------------------------------------

if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

if (!("ICAMS" %in% rownames(installed.packages())) ||
    packageVersion("ICAMS") < "3.0.5") {
  remotes::install_github("steverozen/ICAMS", ref = "v3.0.5-branch")
}
if (!("SynSigEval" %in% rownames(installed.packages())) ||
    packageVersion("SynSigEval") < "0.3.1") {
  remotes::install_github(repo = "WuyangFF95/SynSigEval", ref = "0.3.1-branch")
}

require(ICAMS)
require(SynSigEval)
require(readr)
}

library(data.table)

extract_from_one_seeds_summary <- function(summary.directory.path) {
  gt <- ICAMS::ReadCatalog(file.path(summary.directory.path, "ground.truth.sigs.csv"))
  ex <- ICAMS::ReadCatalog(file.path(summary.directory.path, "extracted.sigs.csv"))
  tff <- mSigTools::TP_FP_FN_avg_sim(ex, gt)
  tff$PPV <- tff$TP / (tff$TP + tff$FP)
  tff$TPR <- tff$TP / (tff$TP + tff$FN)
  return(tff)
}

summarize_level1_dirs <- function(a.folder) {
  message("summarizing a.folder=", a.folder)
  stopifnot(dir.exists(a.folder))
  dataset.name.to.use <- sub("_down_samp", "", a.folder)
  message("using dataset name ", dataset.name.to.use)
  
  out <- data.table(Data_set         = "",
                    Noise_level      = "",
                    Approach         = "",
                    Run              = "",
                    PPV              = -1,
                    TPR              = -1,
                    aver_Sim_TP_only = -1,
                    Composite        = -1,
                    N_Sigs           = -1,
                    FN               = -1,
                    FP               = -1)
  
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
        
        tff <- extract_from_one_seeds_summary(file.path(seedInUse, "summary"))
        row <- data.table(Data_set         = dataset.name.to.use,
                          Noise_level      = noise.level,
                          Approach         = toolName,
                          Run              = basename(seedInUse),
                          PPV              = tff$PPV,
                          TPR              = tff$TPR,
                          aver_Sim_TP_only = tff$avg.cos.sim,
                          Composite        = tff$PPV + tff$TPR + tff$avg.cos.sim,
                          N_Sigs           = tff$TP + tff$FP,
                          FN               = tff$FN,
                          FP               = tff$FP)

        out <- rbind(out, row)
        
      } # for(seedInUse)
      
    } # for (datasetpath in datasetNames)
  } # for (analysis.name in tools)
  
  out <- out[-1, ]
  data.table::fwrite(data.table::as.data.table(out), file.path(a.folder, "all_sub_results.csv"))
  invisible(out)
} # function summarize_something

# xx <- summarize_level1_dirs("indel_set1_down_samp") # ok

level1.dirs <- c("indel_set1",
                 "indel_set1_down_samp",
                 "indel_set2",
                 "indel_set2_down_samp",
                 "SBS_set1",
                 "SBS_set1_down_samp",
                 "SBS_set2",
                 "SBS_set2_down_samp")

all.out.list <- lapply(level1.dirs, summarize_level1_dirs)

all.out <- do.call(rbind, all.out.list)

data.table::fwrite(all.out, "all_results_by_seed.csv")

tt <- tibble::as_tibble(all.out)

tt.indel <- dplyr::filter(tt, Data_set %in% c("indel_set1", "indel_set2"))
tt.SBS   <- dplyr::filter(tt, Data_set %in% c("SBS_set1",   "SBS_set2"))
