source("common_code/all.seeds.R")


ddive <- 
  function(data.set, approach, 
           outdir = 
             paste0( "./output_for_paper/ddive_", data.set, "_", approach)) {
    if (approach == "mSigHdp_ds_3k" 
        && data.set %in% c("SBS_set1", "SBS_set2")) {
      ddd <- paste0(data.set, 
                    "_down_samp/raw_results/mSigHdp_ds_3k.results/Realistic/")
  }
  else {
    ddd <- paste0(data.set,
                  "/raw_results/", approach, ".results/Realistic/")
  }

  unlink(outdir, recursive = TRUE)
  dir.create(outdir)
  fplist <- list()
  for (se in all.seeds()) {
    dx <- paste0(ddd, "/seed.", se)
    fplist <- c(fplist, dd_one_seed(dir = dx, my.seed = se, outdir = outdir))
  }
  fplist.catalog <- do.call(cbind, fplist)
  if (ncol(fplist.catalog) > 0 ) {
    ICAMS::PlotCatalogToPdf(fplist.catalog, file.path(outdir, "all_FP.pdf"))
  }
}

reconstruct1 <- function(target.sig, sig.universe, max.set.size = 3, cat.fn) {
  cat.fn("\nReconstructing ", colnames(target.sig))
  exposures <- mSigAct:::OptimizeExposureQP(target.sig, sig.universe)
  okexp <- which(exposures > 0.01)
  exposures <- exposures[okexp]
  # browser()
  for (nn in names(exposures)) {
    cat.fn(nn, " ", exposures[nn])
  }
  reconstructed <- mSigAct::ReconstructSpectrum(sig.universe, exposures, use.sig.names = TRUE)
  cossim <- philentropy::dist_one_one(target.sig, reconstructed, method = "cosine")
  cat.fn("Cosine similarity = ", round(cossim, digits = 3), "\n\n")
}

dd_one_seed <- function(dir, my.seed, outdir) {

  outfile <- file.path(outdir, "md.md") 
  mycat <- function(...) cat(..., "\n\n", file = outfile, append = TRUE, sep = "") 

  sdir <- file.path(dir, "summary")
  
  gt <- ICAMS::ReadCatalog(file.path(sdir, "ground.truth.sigs.csv"),
                           catalog.type = "counts.signature")
  ex <- ICAMS::ReadCatalog(file.path(sdir, "extracted.sigs.csv"),
                           catalog.type = "counts.signature")
  xx <- mSigTools::TP_FP_FN_avg_sim(ex, gt)
  
  mycat("\n### ", dir)
  # browser()
  mycat("False pos sigs:\n", paste(xx$unmatched.ex.sigs, collapse = "\n"))
  mycat("False neg sigs: ", paste(xx$unmatched.ref.sigs, collapse = " "))

  if (length(xx$unmatched.ex.sigs) == 0) {
    return(c())
  }
  fpsigs <- ex[ , xx$unmatched.ex.sigs, drop = FALSE]
  
  fnsigs <- gt[ , xx$unmatched.ref.sigs, drop = FALSE]
  
  mycat("\nReconstructed with false negative signatures:")
  can.we.reconstruct <- 
    apply(X = fpsigs, MARGIN = 2, reconstruct1, 
          sig.universe = fnsigs,
          cat.fn = mycat)

  mycat("\nReconstructed with all signatures:")
  can.we.reconstruct2 <-
    apply(X = fpsigs, MARGIN = 2, reconstruct1, 
          sig.universe = gt,
          cat.fn = mycat)
  
  colnames(fpsigs) <- paste(dir, "-", colnames(fpsigs), sep = "")
  return(list(fp = fpsigs))  
}

ddive("SBS_set1", "SigProfilerExtractor")
ddive("SBS_set2", "SigProfilerExtractor")
ddive("indel_set1", "SigProfilerExtractor")
ddive("indel_set2", "SigProfilerExtractor")
  