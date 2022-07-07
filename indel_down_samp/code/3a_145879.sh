#!/bin/bash
#PBS -q super
#PBS -l walltime=360:00:00
#PBS -l select=1:ncpus=20:mem=200gb
#PBS -N 3a_145879
#PBS -o indel_down_samp/raw_results/3a_145879_out.txt
#PBS -e indel_down_samp/raw_results/3a_145879_err.txt
HOME_LOC=/data/rozen/home/e0240162
PROJ_LOC=${HOME_LOC}/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1
ANACOND_BIN=${HOME_LOC}/opt/anaconda3/bin/conda
ANACOND_RSCRIPT=${HOME_LOC}/opt/anaconda3/envs/R-4.1.3/bin/Rscript

SEED=145879

cd $PROJ_LOC
echo "Start running the wrapper script ......"
mkdir -p ${PROJ_LOC}/indel_down_samp/raw_results/mSigHdp.results/non_hyper/
$ANACOND_BIN activate R-4.1.3
$ANACON_RSCRIPT ${PROJ_LOC}/indel_down_samp/code/3a_run_mSigHdp.R $SEED &>> ${PROJ_LOC}/indel_down_samp/raw_results/mSigHdp.results/3a_${SEED}.out
$ANACOND_BIN deactivate
$ANACOND_BIN deactivate
exit 0

