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
  if (!dir.exists(ddd)) {
    stop("Directory ", ddd, " does not exist")
  }

  unlink(outdir, recursive = TRUE)
  dir.create(outdir)
  fplist <- list()
  outfile <- file.path(outdir, "md.md") 
  mycat <- function(...) cat(..., "\n\n", file = outfile, append = TRUE, sep = "") 
  mycat("## ", approach, " ", data.set, "\n")
  for (se in all.seeds()) {
    dx <- paste0(ddd, "/seed.", se)
    fplist <- c(fplist, dd_one_seed(dir      = dx, 
                                    my.seed  = se, 
                                    data.set = data.set, 
                                    outdir   = outdir,
                                    mycat    = mycat))
  }
  fplist.catalog <- do.call(cbind, fplist)
  if (ncol(fplist.catalog) > 0 ) {
    ICAMS::PlotCatalogToPdf(fplist.catalog, file.path(outdir, "all_FP.pdf"))
  }
}


dd_one_seed <- function(dir,
                        my.seed,
                        data.set, 
                        outdir, 
                        reconstruct.with.all = FALSE,
                        mycat) {


  sdir <- file.path(dir, "summary")
  
  gt <- file.path(data.set, "input", "Realistic", "ground.truth.syn.sigs.csv")
  if (!file.exists(gt)) browser()
  if (TRUE) {
    gt <- ICAMS::ReadCatalog(gt, catalog.type = "counts.signature")
  } else {
  gt <- ICAMS::ReadCatalog(file.path(sdir, "ground.truth.sigs.csv"),
                           catalog.type = "counts.signature")
  }
  ex <- ICAMS::ReadCatalog(file.path(sdir, "extracted.sigs.csv"),
                           catalog.type = "counts.signature")
  xx <- mSigTools::TP_FP_FN_avg_sim(ex, gt)
  
  mycat("\n### ", gsub("seed", "", my.seed))
  # browser()
  mycat("#### False pos sigs:\n\n", paste(xx$unmatched.ex.sigs, collapse = "\n\n"))
  mycat("#### False neg sigs:\n\n", paste(xx$unmatched.ref.sigs, collapse = "\n\n"))

  if (length(xx$unmatched.ex.sigs) == 0) {
    return(c())
  }
  fpsigs <- ex[ , xx$unmatched.ex.sigs, drop = FALSE]
  
  fnsigs <- gt[ , xx$unmatched.ref.sigs, drop = FALSE]
  
  if (length(xx$unmatched.ref.sigs) > 0) {
    mycat("\n#### Reconstructed with false negative signatures:")
    can.we.reconstruct <- 
      lapply(X = colnames(fpsigs),
             function(x) {
               to.plot <- reconstruct1(fpsigs[ , x, drop = FALSE], 
                                       sig.universe = fnsigs,
                                       cat.fn = mycat)
               recon.file <- 
                 file.path(outdir, 
                           paste0(my.seed, "_", gsub(" .*", "", x), ".pdf"))
               ICAMS::PlotCatalogToPdf(to.plot, 
                                       recon.file, 
                                       ylim = c(0, max(to.plot[ , 1])))
             }
      )
  }
  
  if (reconstruct.with.all) {
    mycat("\n#### Reconstructed with all signatures:")
    can.we.reconstruct2 <-
      lapply(X = colnames(fpsigs), 
             function(x) reconstruct1(fpsigs[ , x, drop = FALSE], 
                                      sig.universe = gt,
                                      cat.fn = mycat))
  }
  
  colnames(fpsigs) <- paste(dir, "-", colnames(fpsigs), sep = "")
  # cat(colnames(fpsigs), "\n")
  return(list(fpsigs))  
}

reconstruct1 <- function(target.sig, sig.universe, max.set.size = 3, cat.fn) {
  cat.fn("\nReconstructing ", colnames(target.sig))
  exposures <- mSigTools::optimize_exposure_QP(target.sig, sig.universe)
  okexp <- which(exposures > 0.05)
  exposures <- exposures[okexp]
  exposures <- 
    mSigTools::optimize_exposure_QP(
      target.sig, sig.universe[ , names(exposures), drop = FALSE])
  for (nn in names(exposures)) {
    cat.fn(nn, " ", exposures[nn])
  }
  reconstructed <- mSigAct::ReconstructSpectrum(sig.universe, exposures, use.sig.names = TRUE)
  cossim <- philentropy::dist_one_one(target.sig, reconstructed, method = "cosine")
  cat.fn("Cosine similarity = ", round(cossim, digits = 3), "\n\n")
  
  # Experimental
  ctype <-attr(target.sig, "catalog.type")
  reconstructed <- ICAMS::as.catalog(reconstructed, catalog.type = ctype )
  roundd <- 3
  colnames(reconstructed) <- 
    paste0("Reconstruction, cosine similarity = ", 
           round(cossim, digits = roundd))
  exposures <- sort(exposures, decreasing = TRUE)
  partial.catalog <- 
    do.call(
      cbind,
      lapply(names(exposures), function(nn) exposures[nn] * sig.universe[ , nn]))
  partial.catalog <- ICAMS::as.catalog(partial.catalog, catalog.type = ctype)
  colnames(partial.catalog) <- 
    paste(names(exposures), round(exposures, digits = roundd), sep = ": ")
  to.plot <- cbind(target.sig, reconstructed, partial.catalog)
  return(to.plot)
}

if (FALSE) {

ddive("SBS_set1", "SigProfilerExtractor")
ddive("SBS_set2", "SigProfilerExtractor")
ddive("SBS_set1", "mSigHdp_ds_3k")
ddive("SBS_set2", "mSigHdp_ds_3k")

ddive("indel_set1", "mSigHdp")
ddive("indel_set2", "mSigHdp")
ddive("indel_set1", "SigProfilerExtractor")
ddive("indel_set2", "SigProfilerExtractor")

ddive("sens_SBS35_5_1066", "SigProfilerExtractor")
ddive("sens_SBS35_5_728", "SigProfilerExtractor")
ddive("sens_SBS35_10_1066", "SigProfilerExtractor")
ddive("sens_SBS35_10_728", "SigProfilerExtractor")
ddive("sens_SBS35_20_1066", "SigProfilerExtractor")
ddive("sens_SBS35_20_728", "SigProfilerExtractor")
ddive("SBS_set1", "SP_KmSigHdp")
}
  