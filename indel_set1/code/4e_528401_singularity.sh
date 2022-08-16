#PBS -q super
#PBS -l nodes=1:ppn=20
#PBS -N 4e_528401
#PBS -o 528401_out.txt
#PBS -e 528401_err.txt
#PBS -S /bin/bash

cd $PBS_O_WORKDIR/

mkdir -p indel/raw_results/NR_hdp_gamma_beta_50
nice Rscript indel/code/4e_run_NR_hdp_gamma_beta_50.R 528401 >& indel/raw_results/NR_hdp_gamma_beta_50/528401.log
