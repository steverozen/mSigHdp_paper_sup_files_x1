#!/bin/bash
#PBS -q super
#PBS -l walltime=360:00:00
#PBS -l select=1:ncpus=20:mem=200gb
#PBS -N 3a_all_seeds__sens_SBS35_10_728
#PBS -o /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/sens_SBS35_10_728/raw_results/3a_all_seeds_out.txt
#PBS -e /data/rozen/home/wuyang/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/sens_SBS35_10_728/raw_results/3a_all_seeds_err.txt
HOME_LOC=/data/rozen/home/wuyang
PROJ_LOC=$HOME_LOC/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1
CONDA_BIN_DIR=$HOME_LOC/opt/anaconda3/bin
CONDA_BIN=$CONDA_BIN_DIR/conda
CONDA_RSCRIPT=$HOME_LOC/opt/anaconda3/envs/R-4.2/bin/Rscript


# Initiate conda on computation node
$CONDA_BIN init bash

cd $PROJ_LOC
echo "Start running the wrapper script ......"
mkdir -p $PROJ_LOC/sens_SBS35_10_728/raw_results/mSigHdp_ds_3k.results/Realistic/
$CONDA_RSCRIPT $PROJ_LOC/sens_SBS35_10_728/code/3a_run_mSigHdp_ds_3k.R &>> $PROJ_LOC/sens_SBS35_10_728/raw_results/3a_all_seeds.out

exit 0

