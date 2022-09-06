#!/bin/bash
#PBS -q long
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=100:mem=100gb
#PBS -N 3b_all_seeds__sens_SBS35_20_728
#PBS -o /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/sens_SBS35_20_728/raw_results/3b_all_seeds_out.txt
#PBS -e /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/sens_SBS35_20_728/raw_results/3b_all_seeds_err.txt
HOME_LOC=/data/rozen/home/wuyang
PROJ_LOC=$HOME_LOC/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1
CONDA_BIN_DIR=$HOME_LOC/opt/anaconda3/bin
CONDA_BIN=$CONDA_BIN_DIR/conda
CONDA_PY=$HOME_LOC/opt/anaconda3/envs/SigPro/bin/python3


# Initiate conda on computation node
$CONDA_BIN init bash

cd $PROJ_LOC
echo "Start running the wrapper script ......"
mkdir -p $PROJ_LOC/sens_SBS35_20_728/raw_results/SigProfilerExtractor.results/Realistic/
$CONDA_PY $PROJ_LOC/sens_SBS35_20_728/code/3b_run_SP.py &>> $PROJ_LOC/sens_SBS35_20_728/raw_results/3b_all_seeds.out

exit 0

