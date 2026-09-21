#!/bin/bash

#SBATCH --job-name=medical-analysis
#SBATCH --partition=research
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
#SBATCH --chdir=/research/projects
#SBATCH --output=/research/results/medical-job-%j.out
#SBATCH --error=/research/results/medical-job-%j.err

echo "Starting Slurm research job"
echo "Compute node: $(hostname)"
echo "User: $(whoami)"

python3 /research/projects/medical_analysis.py

echo "Job finished"
