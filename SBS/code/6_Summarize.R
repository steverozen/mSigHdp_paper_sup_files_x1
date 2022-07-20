# Please run this script from the top directory
if (basename(getwd()) != "mSigHdp_paper_sup_files_x1") {
  stop("Please run from top level directory, mSigHdp_paper_sup_files_x1")
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

topLevelFolder4Data <- "./SBS/input"
topLevelFolder4Run <- "./SBS/raw_results"
folder4ToolwiseSummary <- "./SBS/summary/toolwise_summary"
folder4CombinedSummary <- "./SBS/summary/top_level_summary"

# Specify dataset names
datasetNames <- c("Noiseless", "Moderate", "Realistic")

# Specify names of computational approaches
# R-based tools which can do both extraction and attribution.
#
# SigProfilerExtractor is included, but we should run
# 5_rename_SA_SP_files before this summarization.
RBasedExtrAttrToolNames <- c("mSigHdp", "signeR", "SigProfilerExtractor")

# Specify seeds used in analysis.
# Specify 20 seeds used in software running
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
        overwrite = T
      )
    }

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

RBasedExtrAttrToolNames <- c(RBasedExtrAttrToolNames, "SignatureAnalyzer")



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
                "/../SBS.extracted.signature.to.gt.signature.csv")
)
