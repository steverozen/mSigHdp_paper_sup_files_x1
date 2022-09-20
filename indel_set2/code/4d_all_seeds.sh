#!/bin/bash
#PBS -q super
#PBS -l walltime=360:00:00
#PBS -l select=1:ncpus=20:mem=200gb
#PBS -N 4d_all_seeds_indel_set2
#PBS -o /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/indel_set2/raw_results/4d_out.txt
#PBS -e /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/indel_set2/raw_results/4d_err.txt
HOME_LOC=/data/rozen/home/wuyang
PROJ_LOC=$HOME_LOC/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1
CONDA_DIR=$HOME_LOC/opt/anaconda3
CONDA_BIN=$CONDA_DIR/bin/conda
CONDA_PYTHON=$CONDA_DIR/envs/SigPro/bin/python3

#SEED=145879

# Initiate conda on computation node
$CONDA_BIN init bash

cd $PROJ_LOC
echo "Start running the wrapper script ......"
mkdir -p indel_set2/raw_results/SigProfilerExtractor.results
nice $CONDA_PYTHON indel_set2/code/4d_run_SP.py &>> indel_set2/raw_results/SigProfilerExtractor.results/4d_all_seeds.out

exit 0
