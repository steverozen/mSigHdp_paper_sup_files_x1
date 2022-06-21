#PBS -q super
#PBS -l nodes=1:ppn=20
#PBS -N 4e_1076753_gamma_beta_1
#PBS -o 1076753_out_b1.txt
#PBS -e 1076753_err_b1.txt
#PBS -S /bin/bash

cd $PBS_O_WORKDIR/

mkdir -p indel/raw_results/NR_hdp_gamma_beta_1
nice Rscript indel/code/4f_run_NR_hdp_gamma_beta_1.R 1076753 >& indel/raw_results/NR_hdp_gamma_beta_1/1076753.log
