# Please run this script from the top directory
if (basename(getwd()) != "mSigHdp_paper_sup_files_x1") {
  stop("Please run from top level directory, mSigHdp_paper_sup_files_x1")
}

# Install and load dependencies -----------------------------------------------
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}
if ((!requireNamespace("ICAMS", quietly = TRUE)) ||
    (packageVersion("ICAMS") < "3.0.6")) {
  remotes::install_github("steverozen/ICAMS", ref = "v3.0.6-branch")
}
if ((!requireNamespace("SynSigEval", quietly = TRUE)) ||
    (packageVersion("SynSigEval") < "0.3.1")) {
  remotes::install_github(repo = "WuyangFF95/SynSigEval", ref = "0.3.1-branch")
}
require(ICAMS)
require(SynSigEval)
require(readr)



# Specify global options ------------------------------------------------------
options(stringsAsFactors = F)



# Specify global variables ----------------------------------------------------
topLevelFolder4Data <- "./indel_2_down_samp/input"
topLevelFolder4Run <- "./indel_2_down_samp/raw_results"
folder4ToolwiseSummary <- "./indel_2_down_samp/summary/toolwise_summary"
folder4CombinedSummary <- "./indel_2_down_samp/summary/top_level_summary"

# Specify dataset names
# Do not sample "500"
datasetNames <- c("1k", "3k", "5k", "10k", "non_hyper")


# Specify names of computational approaches
RBasedExtrAttrToolNames <- "mSigHdp"

# Specify seeds used in analysis.
# Specify 5 seeds used in software running
seedsInUse <- c(145879, 200437, 310111, 528401, 1076753)



# Summarize on individual runs ------------------------------------------------
for(datasetName in datasetNames){
  for(seedInUse in seedsInUse){
    ## Summarize R-based Extraction and attribution tools.
    for(extrAttrToolName in RBasedExtrAttrToolNames){
      SynSigEval::SummarizeSigOneExtrAttrSubdir(
        run.dir = paste0(topLevelFolder4Run,"/",extrAttrToolName,
                         ".results/",datasetName,"/seed.",seedInUse,"/"),
        ground.truth.exposure.dir = paste0(topLevelFolder4Data,"/",
                                           datasetName,"/"),
        summarize.exp = F,
        overwrite = T)
    }
  }
}



# Summary of runs on each dataset with each software --------------------------
for(datasetName in datasetNames){
  ## For each dataset, summarize 5 runs
  for(extrAttrToolName in RBasedExtrAttrToolNames){
    SynSigEval::SummarizeMultiRuns(
      datasetName = datasetName,
      toolName = extrAttrToolName,
      resultPath = paste0(topLevelFolder4Run,"/",extrAttrToolName,
                          ".results/",datasetName,"/"),
      run.names = paste0("seed.", seedsInUse))
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
    datasetGroupName = "Down-sampling threshold",
    datasetSubGroup = NULL,
    datasetSubGroupName = NULL,
    toolName = toolName,
    toolPath = paste0(topLevelFolder4Run,"/",toolName,".results/"),
    out.dir = paste0(folder4ToolwiseSummary,"/",toolName,"/"),
    display.datasetName = FALSE,
    overwrite = T)
}


# Summarize results of multi tools on multi data sets -------------------------
FinalExtrAttr <- SummarizeMultiToolsMultiDatasets(
  toolSummaryPaths = paste0(folder4ToolwiseSummary,"/",toolsToEval,"/"),
  out.dir = folder4CombinedSummary,
  display.datasetName = FALSE,
  sort.by.composite.extraction.measure = "descending",
  overwrite = T)



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
                              down_samp_thres = datasetName,
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
