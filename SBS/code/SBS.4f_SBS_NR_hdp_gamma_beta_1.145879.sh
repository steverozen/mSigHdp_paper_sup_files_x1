#PBS -q super
#PBS -l nodes=1:ppn=20
#PBS -N 4f_SBS_NR_hdp_gamma_beta_1.145879
#PBS -o SBS/code/SBS.4f_SBS_NR_hdp_gamma_beta_1.145879.sh.out
#PBS -e SBS/code/SBS.4f_SBS_NR_hdp_gamma_beta_1.145879.sh.err
#PBS -S /bin/bash
cd $PBS_O_WORKDIR
mkdir -p SBS/raw_results/4f_SBS_NR_hdp_gamma_beta_1
nice Rscript SBS/code/4f_SBS_NR_hdp_gamma_beta_1.R SBS/raw_results/4f_SBS_NR_hdp_gamma_beta_1 145879 >& SBS/raw_results/4f_SBS_NR_hdp_gamma_beta_1/145879.log
