#!/bin/bash
#SBATCH --mem=40gb
#SBATCH -c 1
#SBATCH -t 14-0:0:0 
#SBATCH -o /global/project/hpcg1504/rna/logs_gc/univec.stdout
#SBATCH -e /global/project/hpcg1504/rna/logs_gc/slurm/univec.stderr


module load bwa/0.7.17
module load samtools/1.5
module load blat/3.5

BASEDIR=/global/project/hpcg1504/rna
UNIVECDIR=$BASEDIR/bin

cd $UNIVECDIR

bwa index -a bwtsw UniVec_Core
samtools faidx UniVec_Core
makeblastdb -in UniVec_Core -dbtype nucl


echo "univec db complete"