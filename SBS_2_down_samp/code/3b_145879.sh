#!/bin/bash
#PBS -q super
#PBS -l walltime=360:00:00
#PBS -l select=1:ncpus=50:mem=100gb
#PBS -N 3b__SBS_2_down_samp_145879
#PBS -o /data/rozen/home/e0240162/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/SBS_2_down_samp/raw_results/3b_145879_out.txt
#PBS -e /data/rozen/home/e0240162/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/SBS_2_down_samp/raw_results/3b_145879_err.txt
HOME_LOC=/data/rozen/home/e0240162
PROJ_LOC=$HOME_LOC/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1
CONDA_BIN_DIR=$HOME_LOC/opt/anaconda3/bin
CONDA_BIN=$CONDA_BIN_DIR/conda
CONDA_PYTHON=$HOME_LOC/opt/anaconda3/envs/SigPro/bin/python3

SEED=145879

# Initiate conda on computation node
$CONDA_BIN init bash

cd $PROJ_LOC
echo "Start running the wrapper script for SigProfilerExtractor ......"
mkdir -p $PROJ_LOC/SBS_2_down_samp/raw_results/SigProfilerExtractor.results/
$CONDA_PYTHON $PROJ_LOC/SBS_2_down_samp/code/3b_run_SP.py --seeds ${SEED} &>> $PROJ_LOC/SBS_2_down_samp/raw_results/SigProfilerExtractor.results/3b_${SEED}.out

exit 0

