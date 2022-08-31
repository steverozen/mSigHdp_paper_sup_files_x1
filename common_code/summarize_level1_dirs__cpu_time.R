# Please run this script from the top directory
top.dir <- "mSigHdp_paper_sup_files_x1"
if (basename(getwd()) != top.dir) {
  stop("Please run from top level directory, ", top.dir)
}


# Function to fetch CPU time table --------------------------------------------
summarize_level1_dirs <- function(a.folder) {
  message("summarizing a.folder=", a.folder)
  stopifnot(dir.exists(a.folder))
  dataset.name.to.use <- sub("_down_samp", "", a.folder)
  message("using dataset name ", dataset.name.to.use)
  
  # Import summary/cpu_time.csv
  cpu_time_table <- 
    file.path(a.folder, "summary", "cpu_time.csv") %>% 
    utils::read.csv()
  
  # Export CPU time table with data set indicated.
  cpu_time_table <- data.frame(Data_set = a.folder, cpu_time_table)
  
  # Change column name "Down_samp_level" to "Noise_level"
  ind <- which(colnames(cpu_time_table) == "Down_samp_level")
  colnames(cpu_time_table)[ind] <- "Noise_level"
  
  invisible(cpu_time_table)
} # function summarize_something


# Wrapper function ------------------------------------------------------------
summarize_all_level1_dirs <- function()  {
  
  level1.dirs <- c("indel_set1",
                   "indel_set1_down_samp",
                   "indel_set2",
                   "indel_set2_down_samp",
                   "SBS_set1",
                   "SBS_set1_down_samp",
                   "SBS_set2",
                   "SBS_set2_down_samp")
  
  all.out.list <- lapply(level1.dirs, summarize_level1_dirs)
  
  all.cpu.time <- do.call(rbind, all.out.list)
  
  utils::write.csv(all.cpu.time, "cpu_time_by_seed.csv", 
                   row.names = F,
                   quote = F)
  save(all.cpu.time, file = "cpu_time_by_seed.Rdata")
  invisible(all.cpu.time)
}

# Run wrapper function --------------------------------------------------------
all.cpu.time <- summarize_all_level1_dirs()
