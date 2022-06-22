#PBS -q super
#PBS -l nodes=1:ppn=20
#PBS -N 4f_NR_hdp_gamma_beta_1.528401
#PBS -o indel/code/indel.4f_NR_hdp_gamma_beta_1.528401.sh.out
#PBS -e indel/code/indel.4f_NR_hdp_gamma_beta_1.528401.sh.err
#PBS -S /bin/bash
cd $PBS_O_WORKDIR
mkdir indel/raw_results/4f_NR_hdp_gamma_beta_1
nice Rscript indel/code/4f_NR_hdp_gamma_beta_1.R indel/raw_results/4f_NR_hdp_gamma_beta_1 528401 >& indel/raw_results/4f_NR_hdp_gamma_beta_1/528401.log
