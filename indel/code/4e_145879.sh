#PBS -q super
#PBS -l nodes=1:ppn=20
#PBS -N 4e_145879
#PBS -o 145879_out.txt
#PBS -e 145879_err.txt
#PBS -S /bin/bash

cd $PBS_O_WORKDIR/

nice Rscript indel/code/4e_run_NR_hdp_gamma_beta_50.R 145879 >& indel/raw_results/NR_hdp_gamma_beta_50/145879.log
