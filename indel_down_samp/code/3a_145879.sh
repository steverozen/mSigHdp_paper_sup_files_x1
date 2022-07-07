#PBS -q long
#PBS -l nodes=1:ppn=20
#PBS -N 3a_145879
#PBS -o 3a_145879_out.txt
#PBS -e 3a_145879_err.txt
#PBS -S /bin/bash

cd $PBS_O_WORKDIR/

echo "Start running the wrapper script ......"
mkdir -p indel_down_samp/raw_results/mSigHdp.results/non_hyper
nice /data/rozen/home/e0240162/opt/anaconda3/envs/R-4.1.3/bin/Rscript indel_down_samp/code/3a_run_mSigHdp.R 145879 &>> indel_down_samp/raw_results/mSigHdp.results/3a_145879.out
