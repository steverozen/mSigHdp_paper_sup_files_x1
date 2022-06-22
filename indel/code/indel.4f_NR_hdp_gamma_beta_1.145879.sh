#PBS -q super
#PBS -l nodes=1:ppn=20
#PBS -N indel/code/indel.4f_NR_hdp_gamma_beta_1.145879.sh
#PBS -o indel/code/indel.4f_NR_hdp_gamma_beta_1.145879.sh.out
#PBS -e indel/code/indel.4f_NR_hdp_gamma_beta_1.145879.sh.err
#PBS -S /bin/bash
cd $PBS_O_WORKDIR
mkdir indel/raw_results/4f_NR_hdp_gamma_beta_1
nice Rscript indel/code/4f_NR_hdp_gamma_beta_1.R 145879>& indel/raw_results/4f_NR_hdp_gamma_beta_1/145879.log
