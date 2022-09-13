# Please run this script from the top-level directory
if (basename(getwd()) != "mSigHdp_paper_sup_files_x1") {
  stop("Please run from top level directory, mSigHdp_paper_sup_files_x1")
}

# Install and load required packages ------------------------------------------
if ((!requireNamespace("ICAMS", quietly = TRUE)) ||
    (packageVersion("ICAMS") < "3.0.6")) {
  remotes::install_github("steverozen/ICAMS", ref = "v3.0.6-branch")
}
if (!(requireNamespace("mSigAct", quietly = TRUE)) ||
    (packageVersion("mSigAct") < "2.3.2")) {
  remotes::install_github(repo = "steverozen/mSigAct", ref = "v2.3.2-branch")
}
require(ICAMS)
require(mSigAct)



# Specify global variables ----------------------------------------------------
# Level 1 dirs are also the name of the data sets
level1_dirs <- c("indel_set1",
                 "indel_set2",
                 "SBS_set1",
                 "SBS_set2")
level1_dirs <- c(level1_dirs,
                 paste0("sens_SBS35_",
                        c(5L, 10L, 20L, 30L, 50L, 100L),
                        "_728"),
                 paste0("sens_SBS35_",
                        c(5L, 10L, 20L, 30L, 50L, 100L),
                        "_1066"))


# Function to convert SigPro signature files-----------------------------------
# under a data set directory (e.g. "SBS_set1") 
move_sigpro_files_one_dir <- function(a_dir) {
  
  start.here <- file.path(a_dir, "raw_results")
  
  
  # Check whether a_dir contains SBS or indel data sets.
  # This is useful to call different functions to transfrom SigPro catalog.
  flag_indel <- FALSE
  flag_SBS <- FALSE
  if (grepl("indel", basename(a_dir))) {
    # indel_set1, indel_set2
    # indel_set1_down_samp, indel_set2_down_samp
    flag_indel <- TRUE
  }
  if (grepl("SBS", basename(a_dir))) {
    # SBS_*
    # sens_SBS35_*
    flag_SBS <- TRUE
  }
  
  # Skip a_dir is not a folder with indel or SBS data set.
  if ((flag_SBS || flag_indel) == FALSE) {
    message("Skipping ", a_dir, " as it is not a folder for SBS or indel data sets")
    invisible(return(NULL))
  }
  if ((flag_SBS && flag_indel) == TRUE) {
    stop("a_dir cannot be both an SBS and indel data set\n")
  }
  
  # A full directory path, e.g "indel_set1/raw_results/SigProfilerExtractor.results"
  analysis_name <- file.path(a_dir, "raw_results", "SigProfilerExtractor.results")
  if(!dir.exists(analysis_name)) {
    message("\n=====================")
    message("\n=====================")
    message(analysis_name, " does not exist, skipping...")
    invisible(return(NULL))
  }

  message("\n=====================")
  message("\n=====================")
  message("Looking for analysis_name=", analysis_name)
  tool_name <- sub("\\.results", "", basename(analysis_name), fixed = TRUE)
  # dataset_path, e.g indel_set1/raw_results/SigProfilerExtractor.results/"Moderate"
  dataset_paths <- list.files(analysis_name, full.names = TRUE)
  for (dataset_path in dataset_paths) {
    noise_level <- basename(dataset_path)
    if (!noise_level %in% 
        c("Noiseless", "Moderate", "Realistic")) {
      if (dir.exists(dataset_path)) {
        message("\n\n**Skipping directory ", dataset_path, "**\n\n")
      }
      next
    }
    message("Moving into dataset_path=", dataset_path)
    seeds_paths <- 
      list.files(dataset_path, pattern = "seed\\.\\d+", full.names = TRUE)
    
    # Switch SigPro extracted signatures into ICAMS format catalog csv file
    for(seed_path in seeds_paths) {
      # seedInUse e.g. "indel/raw_results/mSigHdp.results/Moderate/seed.528401"
      message("\nMoving into seed_path=", seed_path)
      seedInUse <-sub("seed\\.", "", basename(seed_path), fixed = TRUE)
      
      # Pass if SigPro raw result folder is absent
      # These raw results are only locally stored 
      # because their path are too long to be pushed to a GitHub repo.
      path_to_check_SBS <- file.path(seed_path, "SBS96")
      path_to_check_ID <- file.path(seed_path, "ID83")
      if (dir.exists(path_to_check_ID) ||
          dir.exists(path_to_check_SBS) == FALSE) {
        message("Skipping seed_path=", seed_path, "\n")
        next
      }
      
      # Copy and reformat files
      if (flag_SBS) cat_type <- "SBS96"
      if (flag_indel) cat_type <- "ID83"
      
      # Convert SigPro-TSV-formatted signatures to ICAMS-CSV format -----------------
      # <seed_path>/SBS96/Suggested_Solution/SBS96_De-Novo_Solution/Signatures
      sig.path <- 
        paste0(seed_path, "/", cat_type, "/Suggested_Solution/",
        cat_type, "_De-Novo_Solution/Signatures/", 
        cat_type, "_De-Novo_Signatures.txt")
      sig.catalog.sp <- utils::read.table(
        sig.path,
        sep = "\t",
        as.is = TRUE,
        header = TRUE)
      # Convert catalog to ICAMS format, using wrapper function
      if (cat_type == "SBS96") {
        sig.catalog <- ICAMS:::MakeSBS96CatalogFromSigPro(sig.catalog.sp)
      } else if (cat_type == "ID83") {
        sig.catalog <- ICAMS:::MakeID83CatalogFromSigPro(sig.catalog.sp)
      }
      sig.catalog <- ICAMS::as.catalog(sig.catalog,
                                       catalog.type = "counts.signature")
      ICAMS::WriteCatalog(sig.catalog,
                          paste0(seed_path, "/extracted.signatures.csv"))
      message(
        "Finished converting SigProfilerExtractor's ",
        "signature extraction TSV file into ", seed_path, "\n")
      message("---------------------")
    } # for (seedInUse in seedsInUse)
  } # for (dataset_path in datasetNames)
  invisible(return(NULL))
}


move_sigpro_files_all_level1_dirs <- function(level1_dirs = level1_dirs) {
  lapply(level1_dirs, move_sigpro_files_one_dir)
  message("\n=====================")
  message("Finished moving SigPro files in all sub-directories.")
  invisible(return(NULL))
}

# Run wrapper function --------------------------------------------------------
invisible(move_sigpro_files_all_level1_dirs(level1_dirs))
