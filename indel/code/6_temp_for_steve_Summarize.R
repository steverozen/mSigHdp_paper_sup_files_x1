# Please run this script from the top directory
top.dir <- "mSigHdp_paper_sup_files_x1"
if (basename(getwd()) != top.dir) {
  stop("Please run from top level directory, ", top.dir)
}

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

# Specify global options ------------------------------------------------------
options(stringsAsFactors = F)


# Specify global variables ----------------------------------------------------

topLevelFolder4Data <- "./indel/input"
topLevelFolder4Run <- "./indel/raw_results"
folder4ToolwiseSummary <- "./indel/summary/toolwise_summary"
folder4CombinedSummary <- "./indel/summary/top_level_summary"

# Specify dataset names
datasetNames <- c("Noiseless", "Moderate", "Realistic")

# Must source 5_rename_SA_SP_files.R before calling summarize.results.


summarize.results <- function() {
  
  tools <- dir("indel/raw_results", full.names = TRUE)
  
  for(extrAttrToolName in tools) {
    
    if (!grepl("NR_hdp_gamma_beta", x = extrAttrToolName)) next
    
    datasetNames <- dir(extrAttrToolName, full.names = TRUE)
    
    for(datasetpath in datasetNames){
      
      if (!grepl("Realistic", datasetpath)) next
      
      datasetName <- basename(datasetpath)
      
      seedsInUse <- dir(datasetpath, full.names = TRUE)
      
      for(seedInUse in seedsInUse) {
        
        if (!grepl("SignatureAnalyzer", extrAttrToolName)) {
          
          SynSigEval::SummarizeSigOneExtrAttrSubdir(
            run.dir = seedInUse,
            ground.truth.exposure.dir = paste0(topLevelFolder4Data,"/",
                                               datasetName,"/"),
            summarize.exp = F,
            overwrite = T
          )
        } else {
          
          SynSigEval:::SummarizeSigOneSASubdir(
            run.dir = paste0(topLevelFolder4Run,"/SignatureAnalyzer.results/",
                             datasetName,"/seed.",seedInUse,"/"),
            ground.truth.exposure.dir = paste0(topLevelFolder4Data,"/",
                                               datasetName,"/"),
            which.run = "best.run",
            summarize.exp = F,
            overwrite = T
          )
        }
      }
    }
  }
}

debug(summarize.results)
summarize.results()

if (FALSE) {
# Summary of runs on each dataset with each software --------------------------

for(datasetName in datasetNames){
  ## For each dataset, summarize 20 runs
  ## using different seeds by EMu
  for(extrAttrToolName in RBasedExtrAttrToolNames){
    SynSigEval::SummarizeMultiRuns(
      datasetName = datasetName,
      toolName = extrAttrToolName,
      resultPath = paste0(topLevelFolder4Run,"/",extrAttrToolName,
                          ".results/",datasetName,"/"),
      run.names = paste0("seed.",seedsInUse)
    )
  }
}



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
