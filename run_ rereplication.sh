#!/bin/bash
#SBATCH --mem=30gb
#SBATCH --array=1-18
#SBATCH -c 4
#SBATCH -t 3-0:0:0 
#SBATCH -o /global/project/hpcg1504/rna/logs_gc/gc_run_rereplication.sh.%A_%a.stdout
#SBATCH -e /global/project/hpcg1504/rna/logs_gc/slurm/gc_run_rereplication.sh.%A_%a.stderr

#Step 6. rereplication 

source activate parkinson_py2.7.12

module load bwa/0.7.17
module load samtools/1.5
module load blat/3.5
module load vsearch/2.5.0
module load fastqc/0.11.5

 
BASEDIR=/global/project/hpcg1504/rna
SCRIPTS=$BASEDIR/bin/python_scripts
VSEARCH=$BASEDIR/analysis_gc/vsearch3
CDHIT=$BASEDIR/analysis_gc/cdhit
INFERNAL=$BASEDIR/analysis_gc/infernal
REREP=$BASEDIR/analysis_gc/rereplication
							

#mRNA=`ls $INFERNAL/*_unique_mRNA.fastq | head -n 1 | tail -n 1`
mRNA=`ls $INFERNAL/*_unique_mRNA.fastq | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`

PREFIX=`basename $mRNA`
PREFIX=`echo $PREFIX | sed 's/_unique_mRNA.fastq//g'`

QUALFILE=`ls $VSEARCH/*qual.fastq | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`
CDHITFILE=`ls $CDHIT/*qual_unique.fastq.clstr | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`

cd $REREP

python $SCRIPTS/3_Reduplicate.py $QUALFILE $mRNA $CDHITFILE $REREP/$PREFIX"_mRNA.fastq"

#./3_Reduplicate.py mouse1_qual.fastq mouse1_unique_mRNA.fastq mouse1_unique.fastq.clstr mouse1_mRNA.fastq
#3_Reduplicate.py <Duplicated_Reference_File> <Deduplicated_File> <CDHIT_Cluster_File> <Reduplicated_Output>

fastqc $PREFIX"_mRNA.fastq"

source deactivate
