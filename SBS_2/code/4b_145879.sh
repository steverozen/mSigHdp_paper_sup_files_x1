#!/bin/bash
#PBS -q long
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=100:mem=200gb
#PBS -N 4b_145879
#PBS -o /data/rozen/home/e0240162/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/SBS_2/raw_results/4b_145879_out.txt
#PBS -e /data/rozen/home/e0240162/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/SBS_2/raw_results/4b_145879_err.txt
HOME_LOC=/data/rozen/home/e0240162
PROJ_LOC=$HOME_LOC/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1
CONDA_BIN_DIR=$HOME_LOC/opt/anaconda3/bin
CONDA_BIN=$CONDA_BIN_DIR/conda
CONDA_RSCRIPT=$HOME_LOC/opt/anaconda3/envs/R-4.1.3/bin/Rscript

SEED=145879

# Initiate conda on computation node
$CONDA_BIN init bash

cd $PROJ_LOC
echo "Start running the wrapper script ......"
mkdir -p $PROJ_LOC/SBS_2/raw_results/SignatureAnalyzer.results/
$CONDA_RSCRIPT $PROJ_LOC/SBS_2/code/4b_run_SignatureAnalyzer.R $SEED &>> $PROJ_LOC/SBS_2/raw_results/SignatureAnalyzer.results/4b_${SEED}.out

exit 0

