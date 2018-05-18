#!/bin/bash
#SBATCH --mem=250gb
#SBATCH --array=1-18%12
#SBATCH -c 16
#SBATCH -t 3-0:0:0 
#SBATCH -o /global/project/hpcg1504/rna/logs_gc/gc_run_annonate.sh.%A_%a.stdout
#SBATCH -e /global/project/hpcg1504/rna/logs_gc/slurm/gc_run_annonate.sh.%A_%a.stderr

# Step 9. Annotate reads to known genes/proteins
