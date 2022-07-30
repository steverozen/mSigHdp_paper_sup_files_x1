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
topLevelFolder4Data <- "./indel_2/input"
topLevelFolder4Run <- "./indel_2/raw_results"
folder4ToolwiseSummary <- "./indel_2/summary/toolwise_summary"
folder4CombinedSummary <- "./indel_2/summary/top_level_summary"

# Specify dataset names
datasetNames <- c("Noiseless", "Realistic")

# Specify names of computational approaches
# R-based tools which can do both extraction and attribution.
#
# SigProfilerExtractor is included, but we should run
# 5_rename_SA_SP_files before this summarization.
RBasedExtrAttrToolNames <- c("mSigHdp", "signeR", 
                             "SigProfilerExtractor",
                             "NR_hdp_gb_1")
toolNamesExt <- c("NR_hdp_gb_50")

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
  
    ## Also summarize tools in toolNamesExt, on data set "Realistic"
    if(datasetName != "Realistic") next
    for(extrAttrToolName in toolNamesExt){
      SynSigEval::SummarizeSigOneExtrAttrSubdir(
        run.dir = paste0(topLevelFolder4Run,"/",extrAttrToolName,
                         ".results/Realistic/seed.",seedInUse,"/"),
        ground.truth.exposure.dir = paste0(topLevelFolder4Data,"/Realistic/"),
        summarize.exp = F,
        overwrite = T)
    }
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
  ## Also summarize tools in toolNamesExt, on data set "Realistic"
  if(datasetName != "Realistic") next
  for(extrAttrToolName in toolNamesExt){
    SynSigEval::SummarizeMultiRuns(
      datasetName = datasetName,
      toolName = extrAttrToolName,
      resultPath = paste0(topLevelFolder4Run,"/",extrAttrToolName,
                          ".results/Realistic/"),
      run.names = paste0("seed.",seedsInUse)
    )
  }
}



# Summarize results of multiple data sets by each tool ------------------------
datasetGroup <- datasetNames
names(datasetGroup) <- datasetNames


for(toolName in RBasedExtrAttrToolNames){
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
for(toolName in toolNamesExt){
  SummarizeOneToolMultiDatasets(
    datasetNames = "Realistic",
    datasetGroup = "Realistic",
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
toolsToEval <- c(RBasedExtrAttrToolNames, toolNamesExt)
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
    if(datasetName != "Realistic") next
    for (extrAttrToolName in toolNamesExt) {
      summaryDir <- 
        paste0(topLevelFolder4Run, "/", extrAttrToolName, ".results/"
               , "/Realistic/seed.", seedInUse, "/summary")
      tmpMatch <- readr::read_csv(paste0(summaryDir, "/match.ex.to.gt.csv"),
                                  show_col_types = FALSE)
      tmpMatch1 <- data.frame(prog = extrAttrToolName,
                              noise = "Realistic",
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
