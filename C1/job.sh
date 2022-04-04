#!/bin/bash -l
#SBATCH --job-name=C1
#SBATCH --account=project_465000061
#SBATCH --time=4:00:00
#SBATCH --nodes=4
###SBATCH --ntasks-per-node=128
#SBATCH --ntasks-per-node=64
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4000
#SBATCH --partition=small

source ~/git_repos/abinit/_build_gnu/modules.sh
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
srun abinit run.abi  > run.log 2> run.err
