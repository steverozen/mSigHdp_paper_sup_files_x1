basedir <- "mSigHdp_paper_sup_files_x1" 
if (basename(getwd()) != basedir) {
  stop("Please run from top level directory, ", basedir)
}

# Install and load package versions to test Nicola Roberts's algorithms 

if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

# Always install the version of hdpx and mSigHdp with the Nicola
# Roberts algorithm for combining raw clusters into signatures
hdpx.version <- "0.1.5.0099"
if (system.file(package = "hdpx") != "") {
  if (packageVersion("hdpx") != hdpx.version) {
    remove.package("hdpx")
    remotes::install_github("steverozen/hdpx", ref = "NR-version-plus-fixes")
  }
} else {
  remotes::install_github("steverozen/hdpx", ref = "NR-version-plus-fixes")
}
message("hdpx version ", packageVersion("hdpx"))
stopifnot(packageVersion("hdpx") == hdpx.version)

mSigHdp.version <- "0.0.0.9019"
if (system.file(package = "mSigHdp") != "") {
  if (packageVersion("mSigHdp") != mSigHdp.version) {
    remove.packages("mSigHdp")
    remotes::install_github(repo = "steverozen/mSigHdp", 
                            ref = "for-NR-version-plus-fixes")
  }
} else {
  remotes::install_github(repo = "steverozen/mSigHdp", 
                          ref = "for-NR-version-plus-fixes")
}
message("mSigHdp version ", packageVersion("mSigHdp"))
stopifnot(packageVersion("mSigHdp") == mSigHdp.version)

# ICAMS is installed when installing mSigHdp
require(ICAMS)
require(hdpx)
require(mSigHdp)



# Run mSigHdp -----------------------------------------------------------------

for (dataset_name in dataset_names) {
  for (seed_in_use in seeds_in_use) {
    
    # dot case ".results" is used for compatibility with SynSigEval.
    out_dir <- paste0(home_for_run, "/mSigHdp.results/",
                      dataset_name, "/seed.", seed_in_use)
    
    # Skip if all finished jobs to save time if a users needs to re-run.
    if (file.exists(paste0(out_dir, "/code.profile.Rdata"))) next

    message("\n\n===========================================\n\n")
    message(paste0("Begin running mSigHdp on data set ",
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
        multi.chains.etc <- mSigHdp::RunHdpParallel(
          input.catalog     = paste0(home_for_data, "/", dataset_name,
                                     "/ground.truth.syn.catalog.csv"),
          seedNumber        = seed_in_use,
          K.guess           = start_K,
          multi.types       = TRUE,
          post.burnin       = burnin.iterations,
          post.n            = 200,
          post.space        = 100,
          CPU.cores         = CPU.cores,
          num.child.process = num.child.process,
          overwrite         = TRUE,
          out.dir           = out_dir)
        save(multi.chains.etc, file = paste0(out_dir, "/multi.chains.etc.Rdata"))
      },
      gcFirst = FALSE
    )
    
    # The return value of gc()
    # records info for peak memory usage.
    code.profile[["gc"]] <- gc(reset = TRUE)
    
    # Save code profiling data.
    save(code.profile, file = paste0(out_dir, "/code.profile.Rdata"))
    
    # Delete mSigHdp return-value object.
    # This makes the measurement of peak-memory usage
    # for the next job accurate.
    rm(multi.chains.etc)
  }
}
