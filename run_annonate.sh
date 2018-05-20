#!/bin/bash
#SBATCH --mem=250gb
#SBATCH --array=1-18%12
#SBATCH -c 16
#SBATCH -t 3-0:0:0 
#SBATCH -o /global/project/hpcg1504/rna/logs_gc/gc_run_annonate.sh.%A_%a.stdout
#SBATCH -e /global/project/hpcg1504/rna/logs_gc/slurm/gc_run_annonate.sh.%A_%a.stderr

# Step 9. Annotate reads to known genes/proteins
source activate parkinson_py2.7.12

module load bwa/0.7.17
module load samtools/1.5
module load blat/3.5

BASEDIR=/global/project/hpcg1504/rna
SPADES=$BASEDIR/bin/SPAdes-3.11.1-Linux/bin
SCRIPTS=$BASEDIR/bin/python_scripts
REREP=$BASEDIR/analysis_gc/rereplication
ASSEMBLY=$BASEDIR/analysis_gc/assembly

#mRNA=`ls $REREP/*_mRNA.fastq | head -n 1`
mRNA=`ls $REREP/*_mRNA.fastq | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`

PREFIX=`basename $mRNA`
PREFIX=`echo $PREFIX | sed 's/_mRNA.fastq//g'`

cd $ASSEMBLY