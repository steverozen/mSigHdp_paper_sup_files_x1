#PBS -q super
#PBS -l nodes=1:ppn=20
#PBS -N 4e_200437
#PBS -o 200437_out.txt
#PBS -e 200437_err.txt
#PBS -S /bin/bash

cd $PBS_O_WORKDIR/

mkdir -p indel/raw_results/NR_hdp_gamma_beta_50
nice Rscript indel/code/4e_run_NR_hdp_gamma_beta_50.R 200437 >& indel/raw_results/NR_hdp_gamma_beta_50/200437.log
