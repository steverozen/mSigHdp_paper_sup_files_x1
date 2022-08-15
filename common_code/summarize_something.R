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

# Specify global options ------------------------------------------------------
options(stringsAsFactors = F)


# Specify global variables ----------------------------------------------------

if (FALSE) {
topLevelFolder4Data <- "./indel/input"
topLevelFolder4Run <- "./indel/raw_results"
folder4ToolwiseSummary <- "./indel/summary/toolwise_summary"
folder4CombinedSummary <- "./indel/summary/top_level_summary"
}


# Must source 5_rename_SA_SP_files.R before calling summarize.results.
source("common_code/all.seeds.R")

summarize_something <- function(a.folder) {
  message("summarizing a.folder=", a.folder)
  
  start.here <- file.path(a.folder, "raw_results")
  
  tools <- dir(start.here, full.names = TRUE)
  
  for(analysis.name in tools) {
    stopifnot(dir.exists(analysis.name)) # A full directory path, e.g "indel/raw_results/mSigHdp.results"
    # if (!grepl("NR_hdp_gamma_beta", x = analysis.name)) next
    message("summarizing analysis.name=", analysis.name)
    
    datasetNames <- dir(analysis.name, full.names = TRUE)
    
    for(datasetpath in datasetNames){
      # datasetpath, e.g ""indel/raw_results/mSigHdp.results/Moderate"
      # if (!grepl("Realistic", datasetpath)) next
  
      # datasetName <- basename(datasetpath)
      moderate.noiseless.realistic <- basename(datasetpath)
      if (!moderate.noiseless.realistic %in% 
                    c("Noiseless", "Moderate", "Realistic")) {
        next
      }
      message("summarizing datasetpath=", datasetpath)
      ground.truth.exposure.dir <-
        file.path(a.folder, "input", moderate.noiseless.realistic)           
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
          # browser()
          SynSigEval:::SummarizeSigOneSASubdir(
            run.dir = seedInUse,
            ground.truth.exposure.dir = ground.truth.exposure.dir,
            which.run = "best.run",
            summarize.exp = F,
            overwrite = T
          )
        }
      } # for(seedInUse)
      
      basenames.seeds <- unlist(lapply(seedsInUse, FUN = basename))
      datasetName     <- basename(datasetpath) # e.g. Moderate
      toolName        <- sub(".results", "", basename(analysis.name), fixed = TRUE)
      
      # resultPath will be e.g. indel/raw_results/mSigHdp.results/Moderate, i.e. datasetpath
      SynSigEval::SummarizeMultiRuns(
        datasetName = datasetName,
        toolName    = toolName,
        resultPath  = datasetpath,
        run.names   = basenames.seeds)
    }
  }
}

# debug(summarize_something)
summarize_something("indel")

if (FALSE) {


# Summarize results of multiple data sets by each tool ------------------------

datasetGroup <- datasetNames
names(datasetGroup) <- datasetNames

toolsToEval <- RBasedExtrAttrToolNames

for(toolName in toolsToEval){
  SummarizeOneToolMultiDatasets(
    datasetNames = datasetNames,
    datasetGroup = datasetGroup,
    datasetGroupName = "Noise level",
    datasetSubGroup = NULL,
    datasetSubGroupName = NULL,
    toolName = toolName,
    toolPath = paste0(topLevelFolder4Run,"/",toolName,".results/"),
    out.dir = paste0(folder4ToolwiseSummary,"/",toolName,"/"),
    display.datasetName = FALSE,
    overwrite = T
  )
}



# Summarize results of multi tools on multi data sets -------------------------

FinalExtrAttr <- SummarizeMultiToolsMultiDatasets(
  toolSummaryPaths = paste0(folder4ToolwiseSummary,"/",toolsToEval,"/"),
  out.dir = folder4CombinedSummary,
  display.datasetName = FALSE,
  sort.by.composite.extraction.measure = "descending",
  overwrite = T
)



# Combine match.ex.to.gt.csv in summary of each run ---------------------------

matchExToGtFull <- data.frame()

for (datasetName in datasetNames) {
  for (seedInUse in seedsInUse) {
    for (extrAttrToolName in RBasedExtrAttrToolNames) {
      summaryDir <- 
        paste0(topLevelFolder4Run, "/", extrAttrToolName, ".results/"
               ,datasetName, "/seed.", seedInUse, "/summary")
      tmpMatch <- readr::read_csv(paste0(summaryDir, "/match.ex.to.gt.csv"),
                                  show_col_types = FALSE)
      tmpMatch1 <- data.frame(prog = extrAttrToolName,
                              noise = datasetName,
                              seed = seedInUse,
                              tmpMatch,
                              stringsAsFactors = F)
      matchExToGtFull <- rbind(matchExToGtFull, tmpMatch1)
    }
  }
}

matchExToGtFull$sim <- round(matchExToGtFull$sim, digits = 3)

readr::write_csv(
  matchExToGtFull, 
  file = paste0(folder4CombinedSummary,
                "/../indel.extracted.signature.to.gt.signature.csv")
)

}
