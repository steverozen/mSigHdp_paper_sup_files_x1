basedir <- "mSigHdp_paper_sup_files_x1" 
if (basename(getwd()) != basedir) {
  stop("Please run from top level directory, ", basedir)
}

source("common_code/all.seeds.R")
source("common_code/generate.qsub.script.R")

for (seed in all.seeds()) {
  generate.qsub.script(
    seed = seed,
    indel.or.SBS = "SBS",
    script.to.run = "4f_SBS_NR_hdp_gamma_beta_1",
  )
}
