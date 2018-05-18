#!/bin/bash
#SBATCH --mem=30gb
#SBATCH --array=1-18%12
#SBATCH -c 4
#SBATCH -t 3-0:0:0 
#SBATCH -o /global/project/hpcg1504/rna/logs_gc/gc_run_contam_3.sh.%A_%a.stdout
#SBATCH -e /global/project/hpcg1504/rna/logs_gc/slurm/gc_run_contam_3.sh.%A_%a.stderr


source activate parkinson

module load bwa/0.7.17
module load samtools/1.5
module load blat/3.5
module load vsearch/2.5.0
 
BASEDIR=/global/project/hpcg1504/rna
UNIVECDIR=$BASEDIR/bin
CDHITOUT=$BASEDIR/analysis_gc/cdhit
CONTAM=$BASEDIR/analysis_gc/contam_3
SCRIPTS=$BASEDIR/bin/python_scripts

#FILENAME1=`ls $CDHITOUT/*_unique.fastq | head -n 1 | tail -n 1`
FILENAME1=`ls $CDHITOUT/*_unique.fastq | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`

PREFIX=`basename $FILENAME1`

####
##previously must have generated univec index using the following 
####
#wget ftp://ftp.ncbi.nih.gov/pub/UniVec/UniVec_Core
#bwa index -a bwtsw UniVec_Core
#samtools faidx UniVec_Core
#makeblastdb -in UniVec_Core -dbtype nucl

# perform alignments for the reads with BWA and filter out any reads that align to our vector database with Samtools

cd $CONTAM

bwa mem -t 4 $UNIVECDIR/UniVec_Core $CDHITOUT/$PREFIX > $PREFIX"_univec_bwa.sam"
samtools view -bS $CONTAM/$PREFIX"_univec_bwa.sam" > $CONTAM/$PREFIX"_univec_bwa.bam"
samtools fastq -n -F 4 -0 $CONTAM/$PREFIX"_univec_bwa_contaminats.fastq" $CONTAM/$PREFIX"_univec_bwa.bam"
samtools fastq -n -f 4 -0 $CONTAM/$PREFIX"_univec_bwa.fastq" $CONTAM/$PREFIX"_univec_bwa.bam"

#samtools fastq: Generates fastq outputs for all reads that mapped to the vector contaminant database (-F 4) and all reads that did not map to the vector contaminant database (-f 4)


#perform additional alignments for the reads with BLAT to filter out any remaining reads that align to our vector contamination database
#BLAT only accepts fasta files
#convert fastq to fasta
vsearch --fastq_filter $CONTAM/$PREFIX"_univec_bwa.fastq" --fastaout $CONTAM/$PREFIX"_univec_bwa.fasta"

#Use blat
blat -noHead -minIdentity=90 -minScore=65  $UNIVECDIR/UniVec_Core $CONTAM/$PREFIX"_univec_bwa.fasta" -fine -q=rna -t=dna -out=blast8 $CONTAM/$PREFIX"_univec.blatout"

#here is the merging and beging to use python scripts
python $SCRIPTS/1_BLAT_Filter.py $CONTAM/$PREFIX"_univec_bwa.fastq" $CONTAM/$PREFIX"_univec.blatout" $CONTAM/$PREFIX"_univec_blat.fastq" $CONTAM/$PREFIX"_univec_blat_contaminats.fastq"

source deactivate


