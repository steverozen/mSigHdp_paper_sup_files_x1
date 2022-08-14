library(data.table)

all_result_dirs <- function() {
  # Map from folder name to data set
  return(list(indel             = "indel_set1",
              indel_2           = "indel_set2",
              indel_down_samp   = "indel_set1",
              indel_2_down_samp = "indel_set2",
              SBS               = "SBS_set1",
              SBS_2             = "SBS_set2",
              SBS_down_samp     = "SBS_set1",
              SBS_2_down_samp   = "SBS_set2"))
}

one_top_level_dir <- function(dir.name, data.set) {
  # cat(dir.name, data.set, "\n")
  summary.file <- file.path(dir.name, "summary", "all_results.csv")
  dd <- data.table::fread(summary.file)
  cn <- colnames(dd)
  if (cn[2] == "Down_samp_level")  {
    new.approach <- apply(dd[ , c("Approach", "Down_samp_level")],
                          MARGIN = 1, paste, collapse = ".downsample.")
    dd[ , "Approach"] <- new.approach
    dd[ , 2] <- "Realistic"
    colnames(dd)[2] <- "Noise_level"
  } else {
    stopifnot(cn[2] == "Noise_level")
  }
  dd[ , "Data_set"] <- data.set
  dd <- dd[ , c(11, 2, 1, 3:10)]
  return(dd)
}

main_text_fig <- function(tt, SBS.or.indel) {
  
  
}

top_level_analysis <- function() {
  all.dirs <- all_result_dirs()

  all.summaries <- lapply(names(all.dirs), 
                     function(dir.name) { 
                       one_top_level_dir(dir.name, all.dirs[[dir.name]]) })
  # Maybe add info from e.g.
  # indel/raw_results/mSigHdp.results/Realistic/seed.1076753/summary{other.results, "etc"}
  # There are problems - with 
  tt <- do.call(rbind, all.summaries)
  data.table::fwrite(tt, "all_results_by_seed.csv")
}

if (T) {
  top_level_analysis()
}