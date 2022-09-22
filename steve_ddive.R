source("common_code/all.seeds.R")


ddive <- function(data.set, approach, outdir = ".") {
  if (approach == "mSigHdp_ds_3k" 
      && data.set %in% c("SBS_set1", "SBS_set2")) {
    ddd <- paste0(data.set, 
                 "_down_samp/raw_results/mSigHdp_ds_3k.results/Realistic/")
  }
  else {
    ddd <- paste0(data.set,
                  "/raw_results/", approach, ".results/Realistic/",  )
  }
  browser()
  dir(ddd)
  
  for (se in all.seeds()) {
    dx <- paste0(ddd, "/seed.", se)
    dd_one_seed(dx, outdir)
  }
}

dd_one_seed(dir, outdir) {
  sdir <- file.path(dir, "summary")
  gt <- ICAMS::ReadCatalog(file.path(sdir, "ground.truth.sigs.csv"))
  ex <- ICAMS::ReadCatalog(file.path(sdir, "extracted.sigs.csv"))
  xx <- mSigTools::TP_FP_FN_avg_sim()
  browser()
  # Now print false positives and false negatives as text
  # Print false positive signatures
  # reconstruct every false positive from known signatures and
  # generate output as text
  
}

ddive("SBS_set1", "mSigHdp_ds_3k")
  