#!/bin/bash
#PBS -q super
#PBS -l walltime=360:00:00
#PBS -l select=1:ncpus=100:mem=200gb
#PBS -N 3a_145879__ROC_SBS35_100
#PBS -o /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/ROC_SBS35_100_1066/raw_results/3a_145879_out.txt
#PBS -e /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/ROC_SBS35_100_1066/raw_results/3a_145879_err.txt
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
mkdir -p $PROJ_LOC/ROC_SBS35_100_1066/raw_results/Realistic/
$CONDA_RSCRIPT $PROJ_LOC/ROC_SBS35_100_1066/code/3a_run_mSigHdp_ds_3k.R $SEED &>> $PROJ_LOC/ROC_SBS35_100_1066/raw_results/3a_${SEED}.out

exit 0

