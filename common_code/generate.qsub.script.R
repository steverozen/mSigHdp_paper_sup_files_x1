generate.qsub.script <- function(
  seed,
  indel.or.SBS,
  script.to.run, # identify this with approach
  queue="super",
  out.file.name = file.path(indel.or.SBS,"code", paste(indel.or.SBS, script.to.run, seed, "sh", sep = ".")),
  target.dir    = file.path(indel.or.SBS, "raw_results", script.to.run)
) {
  cat("#PBS -q ", queue, "\n", sep = "", file = out.file.name)
  mycat <- function(...) {
    cat(..., "\n", sep = "", file = out.file.name, append = TRUE)
  }
  pbscat <- function(...) { mycat("#PBS -", ...)}
  pbscat("l nodes=1:ppn=20")
  pbscat("N ", script.to.run, ".", seed)
  pbscat("o ", out.file.name, ".out")
  pbscat("e ", out.file.name, ".err")
  pbscat("S /bin/bash")
  mycat("cd $PBS_O_WORKDIR")
  mycat("mkdir ", target.dir)
  mycat("nice Rscript ", 
        file.path(indel.or.SBS, "code", paste0(script.to.run, ".R")), " ", 
        seed, ">& ", dirname(target.dir), "/", script.to.run, "/", seed, ".log")
  
}
