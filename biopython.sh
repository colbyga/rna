#!/bin/bash
#SBATCH --mem=1gb
#SBATCH -c 1
#SBATCH -t 3-0:0:0 

source activate parkinson

pip install biopython


source deactivate

echo "did this work?"
