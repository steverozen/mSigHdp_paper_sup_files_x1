#!/bin/bash
#PBS -q super
#PBS -l walltime=360:00:00
#PBS -l select=1:ncpus=20:mem=200gb
#PBS -N 4a_145879__indel_set1
#PBS -o /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/indel_set1/raw_results/4a_145879_out.txt
#PBS -e /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/indel_set1/raw_results/4a_145879_err.txt
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
mkdir -p indel_set1/raw_results/mSigHdp.results
nice $CONDA_RSCRIPT indel_set1/code/4a_run_mSigHdp.R $SEED &>> indel_set1/raw_results/mSigHdp.results/4a_${SEED}.log

exit 0
