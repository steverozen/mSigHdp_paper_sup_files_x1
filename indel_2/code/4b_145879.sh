#!/bin/bash
#PBS -q super
#PBS -l walltime=360:00:00
#PBS -l select=1:ncpus=50:mem=200gb
#PBS -N 4b_145879
#PBS -o /data/rozen/home/e0240162/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/indel_2/raw_results/4b_145879_out.txt
#PBS -e /data/rozen/home/e0240162/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1/indel_2/raw_results/4b_145879_err.txt
HOME_LOC=/data/rozen/home/e0240162
PROJ_LOC=$HOME_LOC/practice/6_Mo_mSigHdp/mSigHdp_paper_sup_files_x1
CONDA_BIN_DIR=$HOME_LOC/opt/anaconda3/bin
CONDA_BIN=$CONDA_BIN_DIR/conda
CONDA_RSCRIPT=$HOME_LOC/opt/anaconda3/envs/R-4.1.3/bin/Rscript

SEED=145879

# Activate conda environment
source $CONDA_BIN_DIR/activate
$CONDA_BIN activate R-4.1.3

cd $PROJ_LOC
echo "Start running the wrapper script ......"
mkdir -p $PROJ_LOC/indel_2/raw_results/SignatureAnalyzer.results/non_hyper/
$CONDA_RSCRIPT $PROJ_LOC/indel_2/code/4b_run_SignatureAnalyzer.R $SEED &>> $PROJ_LOC/indel_down_samp/raw_results/SignatureAnalyzer.results/4b_${SEED}.out

$CONDA_BIN deactivate #this is to exit the $ENV_NAME environment
$CONDA_BIN deactivate #this is to exit the base anaconda environment

exit 0

