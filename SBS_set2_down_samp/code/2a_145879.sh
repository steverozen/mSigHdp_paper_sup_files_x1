#!/bin/bash
#PBS -q super
#PBS -l walltime=360:00:00
#PBS -l select=1:ncpus=100:mem=200gb
#PBS -N 2a_145879__SBS_set2_ds
#PBS -o /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/SBS_set2_down_samp/raw_results/2a_145879_out.txt
#PBS -e /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/SBS_set2_down_samp/raw_results/2a_145879_err.txt
HOME_LOC=/data/rozen/home/wuyang
PROJ_LOC=$HOME_LOC/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1
CONDA_BIN_DIR=$HOME_LOC/opt/anaconda3/bin
CONDA_BIN=$CONDA_BIN_DIR/conda
CONDA_RSCRIPT=$HOME_LOC/opt/anaconda3/envs/R-4.2/bin/Rscript

SEED=145879

# Initiate conda on computation node
$CONDA_BIN init bash

cd $PROJ_LOC
echo "Start running the wrapper script ......"
mkdir -p $PROJ_LOC/SBS_set2_down_samp/raw_results/mSigHdp_ds_1k.results/
mkdir -p $PROJ_LOC/SBS_set2_down_samp/raw_results/mSigHdp_ds_3k.results/
mkdir -p $PROJ_LOC/SBS_set2_down_samp/raw_results/mSigHdp_ds_5k.results/
mkdir -p $PROJ_LOC/SBS_set2_down_samp/raw_results/mSigHdp_ds_10k.results/
$CONDA_RSCRIPT $PROJ_LOC/SBS_set2_down_samp/code/2a_run_mSigHdp.R $SEED &>> $PROJ_LOC/SBS_set2_down_samp/raw_results/2a_${SEED}.out

exit 0

