#!/bin/bash
#PBS -q super
#PBS -l walltime=360:00:00
#PBS -l select=1:ncpus=20:mem=200gb
#PBS -N 2a_145879__SBS_set1_down_samp
#PBS -o /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/SBS_set1_down_samp/raw_results/2a_145879_out.txt
#PBS -e /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/SBS_set1_down_samp/raw_results/2a_145879_err.txt
HOME_LOC=/data/rozen/home/wuyang
PROJ_LOC=$HOME_LOC/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1
CONDA_DIR=$HOME_LOC/opt/anaconda3
CONDA_BIN=$CONDA_DIR/bin/conda
CONDA_RSCRIPT=$CONDA_DIR/envs/R-4.2/bin/Rscript

SEED=145879

# Initiate conda on computation node
$CONDA_BIN init bash

cd $PROJ_LOC
echo "Start running the wrapper script ......"
mkdir -p SBS_set1_down_samp/raw_results/
nice $CONDA_RSCRIPT SBS_set1_down_samp/code/2a_run_mSigHdp.R $SEED &>> SBS_set1_down_samp/raw_results/2a_${SEED}.log

exit 0
