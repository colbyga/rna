#!/bin/bash
#SBATCH --mem=250gb
#SBATCH --array=1-18%12
#SBATCH -c 12
#SBATCH -t 3-0:0:0 
#SBATCH -o /global/project/hpcg1504/rna/logs_gc/gc_run_assemble.sh.%A_%a.stdout
#SBATCH -e /global/project/hpcg1504/rna/logs_gc/slurm/gc_run_assemble.sh.%A_%a.stderr

# Step 8. Assembling reads with spades 

source activate spades

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

$SPADES/spades.py -t 12 -m 250 --rna -s $mRNA -o $ASSEMBLY/$PREFIX"_spades"
mv $PREFIX"_spades"/transcripts.fasta $PREFIX"_contigs.fasta"

#--rna: Uses the mRNA transcript assembly algorithm
#-s: The single-end input reads
#-o: The output directory

#build an index to allow BWA to search against our set of contigs
bwa index -a bwtsw $ASSEMBLY/$PREFIX"_contigs.fasta"
#attempt to map the entire set of putative mRNA reads to this contig database
bwa mem -t 12 $ASSEMBLY/$PREFIX"_contigs.fasta" $mRNA > $PREFIX"_contigs.sam"


#bwa index -a bwtsw mouse1_contigs.fasta
#bwa mem -t 4 mouse1_contigs.fasta mouse1_mRNA.fastq > mouse1_contigs.sam

source deactivate
#########
#chaning environments
#########
echo "changed envs, executing python script 5"
source activate parkinson

module load bwa/0.7.17
module load samtools/1.5
module load blat/3.5

BASEDIR=/global/project/hpcg1504/rna
SPADES=$BASEDIR/bin/SPAdes-3.11.1-Linux/bin
SCRIPTS=$BASEDIR/bin/python_scripts
REREP=$BASEDIR/analysis_gc/rereplication
ASSEMBLY=$BASEDIR/analysis_gc/assembly

mRNA=`ls $REREP/*_mRNA.fastq | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`

PREFIX=`basename $mRNA`
PREFIX=`echo $PREFIX | sed 's/_mRNA.fastq//g'`

cd $ASSEMBLY

#extract unmapped reads into a fastq format file for subsequent processing and generate a mapping table in which each contig is associated with the number of reads used to assemble that contig.

python $SCRIPTS/5_Contig_Map.py $mRNA $ASSEMBLY/$PREFIX"_contigs.sam" $ASSEMBLY/$PREFIX"_unassembled.fastq" $PREFIX"_contigs_map.tsv"

#./5_Contig_Map.py mouse1_mRNA.fastq mouse1_contigs.sam mouse1_unassembled.fastq mouse1_contigs_map.tsv
#5_Contig_Map.py <Reads_Used_In_Alignment> <Output_SAM_From_BWA> <Output_File_For_Unassembed_Reads> <Output_File_For_Contig_Map>

source deactivate

