#PBS -q super
#PBS -l nodes=1:ppn=20
#PBS -N 4f_NR_hdp_gamma_beta_1.1076753
#PBS -o indel_set1/code/indel.4f_NR_hdp_gamma_beta_1.1076753.sh.out
#PBS -e indel_set1/code/indel.4f_NR_hdp_gamma_beta_1.1076753.sh.err
#PBS -S /bin/bash
cd $PBS_O_WORKDIR
mkdir -p indel_set1/raw_results/4f_NR_hdp_gamma_beta_1
nice Rscript indel_set1/code/4f_NR_hdp_gamma_beta_1.R indel/raw_results/4f_NR_hdp_gamma_beta_1 1076753 >& indel/raw_results/4f_NR_hdp_gamma_beta_1/1076753.log
