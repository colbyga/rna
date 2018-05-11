#!/bin/bash
#SBATCH --mem=60gb
#SBATCH --array=1-36%8
#SBATCH -c 8
#SBATCH -o /global/project/hpcg1504/rna/logs_gc/gc_run_trim_fastqc.sh.%A_%a.stdout
#SBATCH -e /global/project/hpcg1504/rna/logs_gc/slurm/gc_run_trim_fastqc.sh.%A_%a.stderr

module load fastqc

BASEDIR=/global/project/hpcg1504/rna/
FASTQDIR=$BASEDIR/analysis_gc/trimmomatic
FASTQCDIR=$BASEDIR/analysis_gc/fastqc_trimmomatic

FILENAME=`ls $FASTQDIR/*P | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`

#PREFIX=`basename $FILENAME .fastq.gz`
#PREFIX=`echo $PREFIX | sed 's/HI.4444.003.Index_//g'`

cd $FASTQCDIR

RUNCODE="fastqc -o $FILENAME.fastq.gz $FILENAME"
echo $RUNCODE
fastqc -o $FASTQCDIR $FILENAME

