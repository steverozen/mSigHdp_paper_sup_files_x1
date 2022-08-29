#!/bin/bash
#PBS -q long
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=100:mem=100gb
#PBS -N 3b_145879__ROC_SBS35_10
#PBS -o /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/ROC_SBS35_10_1066/raw_results/3b_145879_out.txt
#PBS -e /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/ROC_SBS35_10_1066/raw_results/3b_145879_err.txt
HOME_LOC=/data/rozen/home/wuyang
PROJ_LOC=$HOME_LOC/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1
CONDA_BIN_DIR=$HOME_LOC/opt/anaconda3/bin
CONDA_BIN=$CONDA_BIN_DIR/conda
CONDA_PY=$HOME_LOC/opt/anaconda3/envs/SigPro/bin/Rscript

SEED=145879

# Initiate conda on computation node
$CONDA_BIN init bash

cd $PROJ_LOC
echo "Start running the wrapper script ......"
mkdir -p $PROJ_LOC/ROC_SBS35_10_1066/raw_results/Realistic/
$CONDA_PY $PROJ_LOC/ROC_SBS35_10_1066/code/3b_run_SP_${SEED}.py &>> $PROJ_LOC/ROC_SBS35_10_1066/raw_results/3b_${SEED}.out

exit 0

