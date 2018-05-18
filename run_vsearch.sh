#!/bin/bash
#SBATCH --mem=100gb
#SBATCH --array=1-18%9
#SBATCH -c 8
#SBATCH -t 14-0:0:0 
#SBATCH -o /global/project/hpcg1504/rna/logs_gc/gc_run_vsearch.sh.%A_%a.stdout
#SBATCH -e /global/project/hpcg1504/rna/logs_gc/slurm/gc_run_vsearch.sh.%A_%a.stderr


module load fastqc
module load vsearch/2.5.0

BASEDIR=/global/project/hpcg1504/rna
TRIMDIR=$BASEDIR/analysis_gc/trimmomatic
VSEARCHDIR=$BASEDIR/analysis_gc/vsearch
FASTQCDIR=$BASEDIR/analysis_gc/fastqc_vsearch

#vsearch --fastq_mergepairs mouse1_trim.fastq --reverse mouse2_trim.fastq --fastqout mouse_merged_trim.fastq --fastqout_notmerged_fwd mouse1_merged_trim.fastq --fastqout_notmerged_rev mouse2_merged_trim.fastq
#--fastq_mergepairs Instructs VSEARCH to use the read merging algorithm to merge overlapping paired-end reads
#--reverse Indicates the name of the file with the 3' to 5' (reverse) paired-end reads
#--fastqout Indicates the output file contain the overlapping paired-end reads
#--fastqout_notmerged_fwd and --fastqout_notmerged_rev Indicates the output files containing the non-overlapping paired-end reads

#vsearch --fastq_filter mouse1_trim.fastq --fastq_maxee 2.0 --fastqout mouse1_qual.fastq
#--fastq_filter Instructs VSEARCH to use the quality filtering algorithm to remove low quality reads
#--fastq_maxee 2.0 The expected error threshold. Set at 1. Any reads with quality scores that suggest that the average expected number of errors in the read are greater than 1 will be filtered.
#--fastqout Indicates the output file contain the quality filtered reads

#vsearch --fastq_filter mouse1_trim.fastq --fastq_maxee 2.0 --fastqout mouse1_qual.fastq
#FILENAME1=`ls $TRIMDIR/*1P | head -n 18 | tail -n 1`

FILENAME1=`ls $TRIMDIR/*1P | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`
FILENAME2=`echo $FILENAME1 | sed 's/_1P/_2P/g'`

PREFIX=`basename $FILENAME1`
PREFIX=`echo $PREFIX | sed 's/_1P/.fastq/g'`
echo $PREFIX

PREFIX_R1=`basename $FILENAME1`
PREFIX_R2=`basename $FILENAME2`
echo $PREFIX_R1 + $PREFIX_R2

PREFIXQUAL=`basename $FILENAME1`
PREFIXQUAL=`echo $PREFIXQUAL | sed 's/1P/qual.fastq/g'`

cd $VSEARCHDIR

#echo to output file
echo vsearch --fastq_mergepairs $FILENAME1 --reverse $FILENAME2 --fastqout $VSEARCHDIR/$PREFIX --fastqout_notmerged_fwd $VSEARCHDIR/$PREFIX_R1.notmerged.fastq --fastqout_notmerged_rev $VSEARCHDIR/$PREFIX_R2.notmerged.fastq
# actual cmd
vsearch --threads 8 --fastq_mergepairs $FILENAME1 --reverse $FILENAME2 --fastqout $VSEARCHDIR/$PREFIX --fastqout_notmerged_fwd $VSEARCHDIR/$PREFIX_R1.notmerged.fastq --fastqout_notmerged_rev $VSEARCHDIR/$PREFIX_R2.notmerged.fastq 

#echo to output file 
echo vsearch --threads 8 --fastq_filter $VSEARCHDIR/$PREFIX --fastq_maxee 2.0 --fastqout $VSEARCHDIR/$PREFIXQUAL
# actual cmd
vsearch --threads 8 --fastq_filter $VSEARCHDIR/$PREFIX --fastq_maxee 2.0 --fastqout $VSEARCHDIR/$PREFIXQUAL

#fastqc on quality paired output
cd $FASTQCDIR
RUNCODE="fastqc -o $FASTQCDIR $VSEARCHDIR/$PREFIXQUAL"
echo $RUNCODE
fastqc -o $FASTQCDIR $VSEARCHDIR/$PREFIXQUAL















