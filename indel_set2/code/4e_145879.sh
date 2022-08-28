#!/bin/bash
#PBS -q super
#PBS -l walltime=360:00:00
#PBS -l select=1:ncpus=20:mem=200gb
#PBS -N 4e_145879
#PBS -o /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/indel_set2/raw_results/4e_145879_out.txt
#PBS -e /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/indel_set2/raw_results/4e_145879_err.txt
HOME_LOC=/data/rozen/home/wuyang
PROJ_LOC=$HOME_LOC/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1
CONDA_BIN_DIR=$HOME_LOC/opt/anaconda3/bin
CONDA_BIN=$CONDA_BIN_DIR/conda
CONDA_RSCRIPT=$HOME_LOC/opt/anaconda3/envs/R-4.2-hdp-NR-fixed/bin/Rscript

SEED=145879

# Initiate conda on computation node
$CONDA_BIN init bash

cd $PROJ_LOC
echo "Start running the wrapper script ......"
mkdir -p indel_set2/raw_results/NR_hdp_gb_50.results
nice $CONDA_RSCRIPT indel_set2/code/4e_run_NR_hdp_gamma_beta_50.R $SEED &>> indel_set2/raw_results/NR_hdp_gb_50.results/${SEED}.log

exit 0
