# Please run this script from the top directory
if (basename(getwd()) != "Liu_et_al_Sup_Files") {
  stop("Please run from top level directory, Liu_et_al_Sup_Files")
}

# Install and load required packages ------------------------------------------
require(ICAMS)



# Specify global variables ----------------------------------------------------
home_for_data <- "SBS/input"
home_for_run <- "SBS/raw_results"

# Import data set names
dataset_names <- c("Noiseless", "Moderate", "Realistic")

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



# Convert SigPro-TSV-formatted signatures and exposures -----------------------
# into ICAMS-CSV-formatted signatures and exposures.
for (dataset_name in dataset_names) {
  for (seed_in_use in seeds_in_use) {
    
    sp_run_dir <- paste0(home_for_run, "/SigProfilerExtractor.results/",
                         dataset_name, "/seed.", seed_in_use)
    
    # Write signature in ICAMS format
    # Note: SigProfilerExtractor originally exports extracted signature file
    # in a very deep path under sp_run_dir:
    # SBS96/Suggested_Solution/SBS96_De-Novo_Solution/Signatures/SBS96_De-Novo_Signatures.txt
    #
    # This very deep path is too long will break some program on Windows,
    # and therefore we copied these files directly under sp_run_dir.
    sig.path <- paste0(sp_run_dir, "/SBS96_De-Novo_Signatures.txt")
    sig.catalog <- utils::read.table(
      sig.path,
      sep = "\t",
      row.names = 1,
      as.is = TRUE,
      header = TRUE)
    n <- rownames(sig.catalog)
    new.n <- paste0(substr(n,1,1), substr(n,3,3), substr(n,7,7), substr(n,5,5))
    rownames(sig.catalog) <- new.n
    sig.catalog <- sig.catalog[ICAMS::catalog.row.order$SBS96, ,drop = FALSE]
    sig.catalog <- ICAMS::as.catalog(sig.catalog,
                                     catalog.type = "counts.signature")
    ICAMS::WriteCatalog(sig.catalog,
                        paste0(sp_run_dir, "/extracted.signatures.csv"))
  }
}
