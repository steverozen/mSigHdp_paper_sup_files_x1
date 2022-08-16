#PBS -q super
#PBS -l nodes=1:ppn=20
#PBS -N 4e_1076753
#PBS -o 1076753_out.txt
#PBS -e 1076753_err.txt
#PBS -S /bin/bash

cd $PBS_O_WORKDIR/

mkdir -p indel/raw_results/NR_hdp_gamma_beta_50
nice Rscript indel/code/4e_run_NR_hdp_gamma_beta_50.R 1076753 >& indel/raw_results/NR_hdp_gamma_beta_50/1076753.log
