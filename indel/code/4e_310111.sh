#PBS -q super
#PBS -l nodes=1:ppn=20
#PBS -N 4e_310111
#PBS -o 310111_out.txt
#PBS -e 310111_err.txt
#PBS -S /bin/bash

cd $PBS_O_WORKDIR/

mkdir -p indel/raw_results/NR_hdp_gamma_beta_50
nice Rscript indel/code/4e_run_NR_hdp_gamma_beta_50.R 310111 >& indel/raw_results/NR_hdp_gamma_beta_50/310111.log
