#!/bin/bash
#SBATCH --mem=30gb
#SBATCH --array=1-18%9
#SBATCH -c 9
#SBATCH -t 3-0:0:0 
#SBATCH -o /global/project/hpcg1504/rna/logs_gc/gc_run_cdhit.sh.%A_%a.stdout
#SBATCH -e /global/project/hpcg1504/rna/logs_gc/slurm/gc_run_cdhit.sh.%A_%a.stderr


BASEDIR=/global/project/hpcg1504/rna
CDHITDIR=$BASEDIR/bin/cd-hit-v4.6.8-2017-1208/
VSEARCHDIR=$BASEDIR/analysis_gc/vsearch3
OUTDIR=$BASEDIR/analysis_gc/cdhit


#FILENAME1=`ls $VSEARCHDIR/*qual.fastq | head -n 1 | tail -n 1`
FILENAME1=`ls $VSEARCHDIR/*qual.fastq | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`

PREFIX=`basename $FILENAME1`
PREFIX=`echo $PREFIX | sed 's/.fastq/_unique.fastq/g'`


cd $OUTDIR

$CDHITDIR/cd-hit-auxtools/cd-hit-dup -i $FILENAME1 -m true -o $PREFIX 

echo "cdhit complete"

#cd error cd-hit-dup: cdhit-dup.cxx:193: int HashingDepth(int, int): Assertion `len >= min' failed.
# this error may be due to the fact that I had reads below 38 bp long last time