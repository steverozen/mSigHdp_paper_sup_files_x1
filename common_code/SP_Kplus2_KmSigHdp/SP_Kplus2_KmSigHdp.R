# Please run this script from the top directory
top.dir <- "mSigHdp_paper_sup_files_x1"
if (basename(getwd()) != top.dir) {
  stop("Please run from top level directory, ", top.dir)
}

# Install and load dependencies -----------------------------------------------
# We decide to containerize the required package some time
require(ICAMS) # v3.0.6
require(SynSigEval) # v0.4.0
require(tibble)


# Source common function ------------------------------------------------------
source("common_code/sigpro_sig_to_icams_one_run.R")


# Function to convert SigPro signatures files into ICAMS format ---------------

# Function to fetch number of signatures (K) discovered 
# by SigProfilerExtractor, in sub-folder "Suggested_Solution/De-Novo_Solution"
get_sigpro_K_denovo_one_seed <- function(seed_path, cat_type) {
  stopifnot(cat_type %in% c("SBS96", "ID83"))
  input_path <- 
    paste0(seed_path, "/", cat_type, "/Suggested_Solution/",
           cat_type, "_De-Novo_Solution/Signatures/", 
           cat_type, "_De-Novo_Signatures.txt")
  stopifnot(file.exists(input_path))
  # Uses default output_path in sigpro_sig_to_icams_one_run.
  # This will create 
  sig_catalog <- sigpro_sig_to_icams_one_run(input_path = input_path, 
                                             cat_type = cat_type,
                                             output_path = NULL)
  K_denovo <- ncol(sig_catalog)
  message(
    "The number of signatures (K) discovered in SigProfilerExtractor's ",
    "De-Novo_Solution was ", K_denovo, "\n")
  invisible(return(K_denovo))
}

# Function to copy sigpro "All_Solutions/<cat_type>_<K_desire>_Signatures"
# into 
# by SigProfilerExtractor, in sub-folder "All_Solutions/
convert_sigpro_K_custom_one_seed <- function(seed_path, 
                                             K_custom, 
                                             cat_type, 
                                             output_path) {
  stopifnot(cat_type %in% c("SBS96", "ID83"))
  input_path <- 
    paste0(seed_path, "/", cat_type, "/All_Solutions/",
           cat_type, "_", K_custom,"_Signatures/Signatures/", 
           cat_type, "_S", K_custom, "_Signatures.txt")
  message(
    "Importing SigProfilerExtractor's extracted signatures given K = ",
    K_custom, "...\n")
  if(!dir.exists(output_path)) dir.create(output_path)
  sig_catalog <- sigpro_sig_to_icams_one_run(
    input_path = input_path, 
    output_path = output_path, 
    cat_type = cat_type)
  message("SigProfilerExtractor's extracted signatures imported,",
          " and exported to ", output_path)
  invisible(return(sig_catalog))
}

# Conversion function for ONE data set directory (e.g. "SBS_set1") 
prepare_Kplus2_KmSigHdp_files_one_level1_dir <- function(a_dir) {
  
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
  # Path ended other than "SigProfiler.results" 
  # (e.g. "SigProfilerExtractor.results_old) will not be analyzed.
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
  
  # No need to use "\\." for exact match, as fixed = TRUE is set
  tool_name <- sub(".results", "", basename(analysis_name), fixed = TRUE)
  # Read results only from "Realistic" data sets
  # dataset_path, e.g indel_set1/raw_results/SigProfilerExtractor.results/Realistic
  noise_level <- "Realistic"
  dataset_path <- file.path(analysis_name, noise_level)
  stopifnot(dir.exists(dataset_path))
  message("Moving into dataset_path=", dataset_path)
  
  # This excludes seed.<num>_old
  seeds_paths <- 
    list.files(dataset_path, pattern = "seed\\.\\d+", full.names = TRUE)
  # Switch SigPro extracted signatures into ICAMS format catalog csv file
  for(seed_path in seeds_paths) {
    # Specify common variables ------------------------------------------------
    # seed_in_use e.g. "indel/raw_results/mSigHdp.results/Moderate/seed.528401"
    message("\nMoving into seed_path=", seed_path)
    seed_in_use <- sub("seed.", "", basename(seed_path), fixed = TRUE)
    # Pass if SigPro raw result folder for the seed is is absent
    # These raw results are only locally stored 
    # because their path are too long to be pushed to a GitHub repo.
    if (flag_SBS) cat_type <- "SBS96"
    if (flag_indel) cat_type <- "ID83"
    
    # Fetch number of signatures (K) discovered in "De-Novo_Solution" ---------
    # Import SigPro-TSV-formatted signatures to ICAMS catalog format
    K_denovo <- get_sigpro_K_denovo_one_seed(
      seed_path = seed_path, 
      cat_type = cat_type)

    # Converting SigProfilerExtractor signature files, ------------------------
    # with K_custom = K_denovo + 2
    output_path_Kplus2 <- paste0(a_dir, "/raw_results/SP_Kplus2.results/",
                                 "Realistic/seed.", seed_in_use)
    if(!dir.exists(output_path_Kplus2)) 
      dir.create(output_path_Kplus2, recursive = T)
    convert_sigpro_K_custom_one_seed(
      seed_path = seed_path, 
      K_custom = K_denovo + 2, 
      cat_type = cat_type, 
      output_path = output_path_Kplus2)
    
    # Converting SigProfilerExtractor signature files, ------------------------
    # with K_custom = K_mSigHdp
    output_path_KmSigHdp <- paste0(a_dir, "/raw_results/SP_KmSigHdp.results/",
                                 "Realistic/seed.", seed_in_use)
    if(!dir.exists(output_path_KmSigHdp)) 
      dir.create(output_path_KmSigHdp, recursive = T)
    if (flag_SBS) K_mSigHdp <- 21
    if (flag_indel) K_mSigHdp <- 15
    
    convert_sigpro_K_custom_one_seed(
      seed_path = seed_path, 
      K_custom = K_mSigHdp, 
      cat_type = cat_type, 
      output_path = output_path_KmSigHdp)
  } # for (seed_path in seeds_paths)
  invisible(return(NULL))
}

# Conversion function for all level1_directories.
prepare_Kplus2_KmSigHdp_files_all_level1_dirs <- 
  function(level1_dirs = level1_dirs) {
  lapply(level1_dirs, prepare_Kplus2_KmSigHdp_files_one_level1_dir)
  message("\n=====================")
  message("Finished moving SigPro files in all sub-directories.")
  invisible(return(NULL))
}


# Conversion from SigPro signatures to ICAMS signatures -----------------------
# Required step because function extract_from_one_seeds_summary()
# only accepts ICAMS signature files

# SBS or indel data sets, without down-sampling
level1_dirs <- c("indel_set1", "SBS_set1")
invisible(prepare_Kplus2_KmSigHdp_files_all_level1_dirs(level1_dirs))


# 
