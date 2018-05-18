#!/bin/bash
#SBATCH --mem=60gb
#SBATCH --array=1-18
#SBATCH -c 16
#SBATCH -t 4-0:0:0 
#SBATCH -o /global/project/hpcg1504/rna/logs_gc/gc_run_rRNA_remove.sh.%A_%a.stdout
#SBATCH -e /global/project/hpcg1504/rna/logs_gc/slurm/gc_rRNA_remove.sh.%A_%a.stderr


# skipping step where parkinson removes host reads

# will be using *_univec_blat.fastq for downstream analysis
# this should have been dereplicated and contamination removed


source activate parkinson_py2.7.12

module load bwa/0.7.17
module load samtools/1.5
module load blat/3.5
module load vsearch/2.5.0
module load infernal/1.1.2

BASEDIR=/global/project/hpcg1504/rna
CONTAM=$BASEDIR/analysis_gc/contam_3
INFERNAL=$BASEDIR/analysis_gc/infernal
SCRIPTS=$BASEDIR/bin/python_scripts
RFAM=$BASEDIR/bin/Rfam

#FILENAME1=`ls $CONTAM/*_univec_blat.fastq | head -n 1 | tail -n 1`
FILENAME1=`ls $CONTAM/*_univec_blat.fastq | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`

PREFIX=`basename $FILENAME1`
PREFIX=`echo $PREFIX | sed 's/_qual_unique.fastq_univec_blat.fastq/_univec_blat.fasta/g'`

PREFIX2=`echo $PREFIX | sed 's/_univec_blat.fasta//g'`

cd $INFERNAL

#vsearch convert to fasta
vsearch --fastq_filter $FILENAME1 --fastaout $INFERNAL/$PREFIX
cmsearch -o $INFERNAL/$PREFIX"_rRNA.log" --tblout $INFERNAL/$PREFIX"_rRNA.infernalout" --cpu 16 --anytrunc --rfam -E 0.001 $RFAM/Rfam.cm $INFERNAL/$PREFIX


# using python script
python $SCRIPTS/2_Infernal_Filter.py $FILENAME1 $PREFIX"_rRNA.infernalout" $PREFIX2"_unique_mRNA.fastq" $PREFIX2"_unique_rRNA.fastq"

# The argument structure for this script is: 2_Infernal_Filter.py <Input_Reads.fq> <Infernal_Output_File> <mRNA_Reads_Output> <rRNA_Reads_Output>


source deactivate


# this was a really slow process and seems like it might fail
# if I need to run again I will increase both time request from 3 days to 6 days and up CPUs from 10 to 16
# also stop limiting the number of jobs to be loads eg. %10 in #SBATCH --array=1-18%10\\\

# error generated in python scripts
# Traceback (most recent call last):
#  File "/global/project/hpcg1504/rna/bin/python_scripts/2_Infernal_Filter.py", line 33, in <module>
#    mRNA_seqs.add(sequence)
#TypeError: unhashable type: 'SeqRecord'


#working on fixing

#source activate parkinson
#
#module load bwa/0.7.17
#module load samtools/1.5
#module load blat/3.5
#module load vsearch/2.5.0
#module load infernal/1.1.2
#
#BASEDIR=/global/project/hpcg1504/rna
#CONTAM=$BASEDIR/analysis_gc/contam_3
#INFERNAL=$BASEDIR/analysis_gc/infernal
#SCRIPTS=$BASEDIR/bin/python_scripts
#RFAM=$BASEDIR/bin/Rfam
#
#
#
#FILENAME1=`ls $CONTAM/HI.4444.003.Index_12.GR_RNA_S4-3_qual_unique.fastq_univec_blat.fastq | head -n 1 | tail -n 1`
##FILENAME1=`ls $CONTAM/*_univec_blat.fastq | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`
#
#PREFIX=`basename $FILENAME1`
#PREFIX=`echo $PREFIX | sed 's/"_qual_unique.fastq_univec_blat.fastq"/_univec_blat.fasta/g'`
#
#PREFIX2=`echo $PREFIX | sed 's/_univec_blat.fasta//g'`
#
#cd $INFERNAL
#
##vsearch convert to fasta
#vsearch --fastq_filter $FILENAME1 --fastaout $INFERNAL/$PREFIX
#cmsearch -o $INFERNAL/$PREFIX"_rRNA.log" --tblout $INFERNAL/$PREFIX"_rRNA.infernalout" --cpu 2 --anytrunc --rfam -E 0.001 $RFAM/Rfam.cm $INFERNAL/$PREFIX
#
#
## using python script
#python $SCRIPTS/2_Infernal_Filter_edit.py $CONTAM/HI.4444.003.Index_12.GR_RNA_S4-3_qual_unique.fastq_univec_blat.fastq $INFERNAL/HI.4444.003.Index_12.GR_RNA_S4-3_univec_blat.fasta_rRNA.infernalout $INFERNAL/HI.4444.003.Index_12.GR_RNA_S4-3_unique_mRNA.fastq $INFERNAL/HI.4444.003.Index_12.GR_RNA_S4-3_unique_rRNA.fastq
#
#
#
#
#
#
#
#################
##DEMO FILE
############
#cd $CONTAM
#head -n 10000 HI.4444.003.Index_12.GR_RNA_S4-3_qual_unique.fastq_univec_blat.fastq > demo.fastq
#
#FILENAME1=`ls $CONTAM/demo.fastq | head -n 1 | tail -n 1`
##FILENAME1=`ls $CONTAM/*_univec_blat.fastq | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`
#
#PREFIX=`basename $FILENAME1`
#PREFIX=`echo $PREFIX | sed 's/.fastq/.fasta/g'`
#
#PREFIX2=`echo $PREFIX | sed 's/.fasta//g'`
#
#cd $INFERNAL
#
##vsearch convert to fasta
#vsearch --fastq_filter $FILENAME1 --fastaout $INFERNAL/$PREFIX
#cmsearch -o $INFERNAL/$PREFIX"_rRNA.log" --tblout $INFERNAL/$PREFIX"_rRNA.infernalout" --cpu 2 --anytrunc --rfam -E 0.001 $RFAM/Rfam.cm $INFERNAL/$PREFIX
#
#
#
#
#
#python $SCRIPTS/2_Infernal_Filter.py $CONTAM/demo.fastq $INFERNAL/demo.fasta_rRNA.infernalout $INFERNAL/demo_unique_mRNA.fastq $INFERNAL/demo_unique_rRNA.fastq
#
## The argument structure for this script is: 2_Infernal_Filter.py <Input_Reads.fq> <Infernal_Output_File> <mRNA_Reads_Output> <rRNA_Reads_Output>
#
#
#source deactivate




