#!/bin/bash

#SBATCH --partition=batch
#SBATCH --job-name=zro2
###SBATCH --ntasks=29
###SBATCH --ntasks=24
#SBATCH --ntasks=48
##SBATCH --ntasks=96
##SBATCH --ntasks=72
##SBATCH --ntasks=128
###SBATCH --ntasks=256
###SBATCH --ntasks=512
#SBATCH --mem-per-cpu=4000
#SBATCH --time=0-1:0:0
#SBATCH --output=queue.qout
#SBATCH --error=queue.qerr

# OpenMp Environment
export OMP_NUM_THREADS=1

# Load Modules
source $HOME/git_repos/abinit_rmms/_intel/modules.sh
export PATH=$HOME/git_repos/abinit_rmms/_intel/src/98_main/:$PATH

mpirun -n ${SLURM_NTASKS} abinit run.abi > run.log 2> run.err
