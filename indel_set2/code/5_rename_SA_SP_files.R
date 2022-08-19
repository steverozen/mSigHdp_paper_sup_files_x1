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
home_for_data <- "indel_set2/input"
home_for_run <- "indel_set2/raw_results"

# Import data set names
dataset_names <- c("Noiseless", "Realistic")

# Specify 5 seeds used in software running
seeds_in_use <- c(145879, 200437, 310111, 528401, 1076753)



# Copy the best extraction by SignatureAnalyzer in "best.run/" ----------------
for (dataset_name in dataset_names) {
  for (seed_in_use in seeds_in_use) {
    
    sa_run_dir <- paste0(home_for_run, "/SignatureAnalyzer.results/",
                         dataset_name, "/seed.", seed_in_use)
    
    # Copy signature in ICAMS format
    sig_path <- paste0(sa_run_dir, "/best.run/sa.output.sigs.csv")
    file.copy(from = sig_path,
              to = paste0(sa_run_dir, "/extracted.signatures.csv"),
              copy.date = TRUE)
  }
}

# Copy SigPro signature files from old.sig.path to sig.path -------------------
for (dataset_name in dataset_names) {
  for (seed_in_use in seeds_in_use) {
    sp_run_dir <- paste0(home_for_run, "/SigProfilerExtractor.results/",
                         dataset_name, "/seed.", seed_in_use)
    # Note: SigProfilerExtractor originally exports extracted signature file
    # in a very deep path
    old.sig.path <- 
      paste0(sp_run_dir, 
             "/ID83/Suggested_Solution/ID83_De-Novo_Solution/Signatures/",
             "ID83_De-Novo_Signatures.txt")
    # This very deep path will break some program on Windows,
    # and thus we copied these files to sig.path.
    sig.path <- paste0(sp_run_dir, "/ID83_De-Novo_Signatures.txt")
    file.copy(from = old.sig.path, to = sig.path, copy.date = TRUE)
  }
}


# Convert SigPro-TSV-formatted signatures to ICAMS-CSV format -----------------
for (dataset_name in dataset_names) {
  for (seed_in_use in seeds_in_use) {
    sp_run_dir <- paste0(home_for_run, "/SigProfilerExtractor.results/",
                         dataset_name, "/seed.", seed_in_use)
    
    # Convert catalog to ICAMS format, using wrapper function
    sig.path <- paste0(sp_run_dir, "/ID83_De-Novo_Signatures.txt")
    sig.catalog.sp <- utils::read.table(
      sig.path,
      sep = "\t",
      as.is = TRUE,
      header = TRUE)
    sig.catalog <- ICAMS:::MakeID83CatalogFromSigPro(sig.catalog.sp)
    sig.catalog <- ICAMS::as.catalog(sig.catalog,
                                     catalog.type = "counts.signature")
    ICAMS::WriteCatalog(sig.catalog,
                        paste0(sp_run_dir, "/extracted.signatures.csv"))
  }
}


# Convert exposure files to mSigAct-format ------------------------------------
for (dataset_name in dataset_names) {
  for (seed_in_use in seeds_in_use) {
    sp_run_dir <- paste0(home_for_run, "/SigProfilerExtractor.results/",
                         dataset_name, "/seed.", seed_in_use)
    # Note: SigProfilerExtractor originally exports inferred exposure file
    # in a very deep path
    old.exp.path <- 
      paste0(sp_run_dir, 
             "/ID83/Suggested_Solution/ID83_De-Novo_Solution/Activities/",
             "ID83_De-Novo_Activities_refit.txt")
    # Transpose the SigPro-formatted exposure to mSigAct-formatted spectra
    exp <- utils::read.table(
      old.exp.path,       
      sep = "\t",
      row.names = 1,
      as.is = TRUE,
      header = TRUE)
    sig.path <- paste0(sp_run_dir, "/inferred.exposures.csv")
    mSigAct::WriteExposure(t(exp), file = sig.path)
  }
}
