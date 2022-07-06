# Please run this script from the top directory
if (basename(getwd()) != "mSigHdp_paper_sup_files_x1") {
  stop("Please run from top level directory, mSigHdp_paper_sup_files_x1")
}

# Install and load required packages ------------------------------------------

if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}
# Install signeR from Bioconductor
R_ver <- base::version
if(R_ver$major < "4" || R_ver$minor < "1"){
  stop("signeR 1.18.1+ depends on Bioconductor 3.13+ and R 4.1+")
}
if (!("BiocManager" %in% rownames(installed.packages())) ||
    packageVersion("BiocVersion") < "3.13") {
  install.packages("BiocManager")
}
if (!("signeR" %in% rownames(installed.packages())) ||
    packageVersion("signeR") < "1.18.1") {
  BiocManager::install("signeR")
}
if (!("ICAMS" %in% rownames(installed.packages())) ||
    packageVersion("ICAMS") < "3.0.5") {
  remotes::install_github("steverozen/ICAMS", ref = "v3.0.5-branch")
}
if (!("SynSigRun" %in% rownames(installed.packages())) ||
    packageVersion("SynSigRun") < "1.0.0") {
  remotes::install_github("WuyangFF95/SynSigRun", ref = "1.0.0-branch")
}

require(ICAMS)
require(SynSigRun)
require(signeR)



# Specify global variables ----------------------------------------------------

home_for_data <- "./indel/input"
home_for_run <- "./indel/raw_results"

# Range of signatures to choose from.
# We assume SignatureAnalyzer does not know the ground-truth K (11),
# then we should specify K_range as 2..20.
#
# Note: K.range parameter in SynSigRun::RunsigneR() 
# accepts min and max sig numbers - c(2, 20),
# rather than the full range - 2..20
K_range <- c(2, 20)

# Names of data sets
dataset_names <- c("Noiseless", "Moderate", "Realistic")

# Specify 5 seeds used in software running
seeds_in_use <- c(145879, 200437, 310111, 528401, 1076753)



# Run signeR ------------------------------------------------------------------

for (dataset_name in dataset_names) {
  for (seed_in_use in seeds_in_use) {
    
    # dot case ".results" is used for compatibility with SynSigEval.
    out_dir <- paste0(home_for_run, "/signeR.results/",
                      dataset_name, "/seed.", seed_in_use)
    
    # Skip if all finished jobs to save time if a users needs to re-run.
    if (file.exists(paste0(out_dir, "/code.profile.Rdata"))) next

    message("\n\n===========================================\n\n")
    message(paste0("Begin running signeR on data set ",
                   dataset_name, " using seed ", seed_in_use, "...\n"))
    message("\n\n===========================================\n\n")

    # Instantiate a list to store profiling data.
    code.profile <- list()
    
    # Garbage collection before code profiling 
    # to make code profiling more accurate
    #
    # Specify reset = TRUE to reset max memory consumption.
    # This prevents the influence by previous runs. 
    gc(reset = TRUE)
    
    # system.time() is a length-5 vector which collects the following 
    # time usage:
    #
    # 1. user.self: User CPU time of the main process
    # 2. system.self: System CPU time of the main process
    # 3. elapsed: Elapsed time (a.k.a. Wall clock time) - 
    #    the actual time a user experienced to wait from the job's 
    #    beginning to the end. 
    # 4. user.child: Sum of user CPU times of all the child processes
    # 5. system.child: Sum of system CPU times of all the child processes
    #
    # When calling "print(code_profile$system.time)" only three numbers
    # are returned:
    #
    #   user: Sum of 1 and 4; 
    #   system: Sum of 2 and 5;
    #   elapsed: 3.
    code.profile[["system.time"]] <- system.time(
      {
        SynSigRun::RunsigneR(
          input.catalog = paste0(home_for_data,"/",dataset_name,
                                 "/ground.truth.syn.catalog.csv"),
          out.dir = out_dir,
          K.range = K_range,
          seedNumber = seed_in_use,
          overwrite = T)
      },
      gcFirst = FALSE
    )
    # Garbage collection.
    # The return value of gc()
    # records info for peak memory usage.
    code.profile[["gc"]] <- gc(reset = TRUE)
    
    # Save code profiling data.
    save(code.profile, file = paste0(out_dir, "/code.profile.Rdata"))
  }
}
