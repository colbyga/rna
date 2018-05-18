#!/bin/bash
#SBATCH --mem=120gb
#SBATCH --array=1-18%8
#SBATCH -c 8
#SBATCH -t 14-0:0:0 
#SBATCH -o /global/project/hpcg1504/rna/logs_gc/gc_run_trimmomatic.sh.%A_%a.stdout
#SBATCH -e /global/project/hpcg1504/rna/logs_gc/slurm/gc_run_trimmomatic.sh.%A_%a.stderr


module load trimmomatic

BASEDIR=/global/project/hpcg1504/rna
FASTQDIR=$BASEDIR/rawdata/sequence
TRIMDIR=$BASEDIR/analysis_gc/trimmomatic

#FILENAME1=`ls $FASTQDIR/*R1.fastq.gz | head -n 1 | tail -n 1`


#smart: lists all files *R1 1-18 and chooses the last one in list
FILENAME1=`ls $FASTQDIR/*R1.fastq.gz | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`
#sed also smart: matches both R1 and replaces with R2
FILENAME2=`echo $FILENAME1 | sed 's/_R1/_R2/g'`

PREFIX=`basename $FILENAME1 .fastq.gz`
#commented out because it produces different formats or with the change made [3-5] would overwrite files
#PREFIX=`echo $PREFIX | sed 's/HI.4444.00[3-5].Index_//g'`
PREFIX=`echo $PREFIX | sed 's/_R1//g'`
echo $PREFIX

cd $TRIMDIR

RUNCODE="java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.36.jar PE -phred33 -threads $SLURM_JOB_CPUS_PER_NODE -trimlog $TRIMDIR/$PREFIX.log $FILENAME1 $FILENAME2 -baseout $TRIMDIR/$PREFIX.fastq ILLUMINACLIP:$BASEDIR/rawdata/TruSeq3-PE-2.fa:3:30:8:8:true LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36 CROP:120 HEADCROP:30 AVGQUAL:20"

echo $RUNCODE
`$RUNCODE`
