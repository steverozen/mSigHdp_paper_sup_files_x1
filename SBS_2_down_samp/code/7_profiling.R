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

topLevelFolder4Data <- "./SBS_2_down_samp/input"
topLevelFolder4Run <- "./SBS_2_down_samp/raw_results"
folder4Summary <- "./SBS_2_down_samp/summary/"


# Specify dataset names
datasetNames <- c("1k", "3k", "5k", "no_down_samp")
dn_part <- "10k"


# Specify names of computational approaches
# to summarize from their profiling output.
RBasedToolNames <- "mSigHdp"

# Specify seeds used in analysis.
# Specify 5 seeds used in software running
#
# NOTE: seed 145879 failed on data set "10k"
seedsInUse <- c(200437, 310111, 528401, 1076753)
seeds_part <- 145879


DF <- data.table()



# 3. Summarizing code-profiling results from R packages. ----------------------
for (toolName in RBasedToolNames) {
  for (datasetName in datasetNames) {
    for (seedInUse in c(seedsInUse, seeds_part)) {
      
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
        Dataset_name = datasetName,
        Run = paste0("seed.",seedInUse),
        CPU_time = CPU_time)
      
      DF <- rbind(DF, foo)
    }
  }
}

# Also summarize dn_paret on all seeds except 145879
for (toolName in RBasedToolNames) {
  for (datasetName in dn_part) {
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
        Down_samp_level = datasetName,
        Run = paste0("seed.",seedInUse),
        CPU_time = CPU_time)
      
      DF <- rbind(DF, foo)
    }
  }
}


write.csv(DF,
          file = paste0(folder4Summary, "/cpu_time.csv"),
          row.names = FALSE, quote = FALSE)
