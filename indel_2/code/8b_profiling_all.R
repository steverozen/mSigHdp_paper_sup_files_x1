# Please run this script from the top directory
if (basename(getwd()) != "mSigHdp_paper_sup_files_x1") {
  stop("Please run from top level directory, mSigHdp_paper_sup_files_x1")
}

# 0. Install and load dependencies --------------------------------------------

require(data.table)
require(dplyr)



# 1. Specify default options --------------------------------------------------

options(stringsAsFactors = F)



# 2. Specify global variables -------------------------------------------------

topLevelFolder4Data <- "./indel_2/input"
topLevelFolder4Run <- "./indel_2/raw_results"
folder4Summary <- "./indel_2/summary/"


# Specify dataset names
datasetNames <- c("Noiseless", "Realistic")


# Specify names of computational approaches
# to summarize from their profiling output.
RBasedToolNames <- c("mSigHdp", "signeR", "SignatureAnalyzer")


# Specify seeds used in analysis.
# Specify 5 seeds used in software running
seedsInUse <- c(145879, 200437, 310111, 528401, 1076753)


DF <- data.table()



# 3. Summarizing code-profiling results from R packages. ----------------------

for (toolName in RBasedToolNames) {
  for (datasetName in datasetNames) {
    for (seedInUse in seedsInUse) {
      
      run.path <- paste0(topLevelFolder4Run, "/",
                         toolName, ".results/", datasetName,
                         "/seed.", seedInUse)
      load(paste0(run.path, "/code.profile.Rdata"))
      
      # Calculate CPU time in seconds
      user_CPU <- code.profile$system.time[c(1,4)] %>% sum()
      system_CPU <- code.profile$system.time[c(2,5)] %>% sum()
      CPU_time <- user_CPU + system_CPU
      
      foo <- data.frame(
        Approach = toolName,
        Noise_level = datasetName,
        Run = paste0("seed.",seedInUse),
        CPU_time = CPU_time)
      
      DF <- rbind(DF, foo)
    }
  }
}


fn <- paste0(folder4Summary, "/", "cpu_time_SigProfilerExtractor.csv")

DF_PY <- read.csv(fn, header = T)

DF <- rbind(DF, DF_PY)


write.csv(DF,
          file = paste0(folder4Summary, "/cpu_time.csv"),
          row.names = FALSE, quote = FALSE)
