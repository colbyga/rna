#!/bin/bash
#SBATCH --mem=80gb
#SBATCH -c 5
#SBATCH -t 3-0:0:0
#SBATCH -J refseq


#attempt 1
#source activate parkinson
#python getRefseqGenomic.py -b "bacteria,archaea" -l "Complete Genome" -a -p 5
#source deactivate

BASEDIR=/global/project/hpcg1504/rna/bin/annotation_dbs/ncbi
cd $BASEDIR

#attempt 2
curl 'ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt' | \
awk '{FS="\t"} !/^#/ {print $20} ' | \
sed -r 's|(ftp://ftp.ncbi.nlm.nih.gov/genomes/all/.+/)(GCF_.+)|\1\2/\2_genomic.fnn.gz|' > bacteria_genomic_file

curl 'ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/archaea/assembly_summary.txt' | \
awk '{FS="\t"} !/^#/ {print $20} ' | \
sed -r 's|(ftp://ftp.ncbi.nlm.nih.gov/genomes/all/.+/)(GCF_.+)|\1\2/\2_genomic.fnn.gz|' > archaea_genomic_file

BASEDIR=/global/project/hpcg1504/rna/bin/annotation_dbs/ncbi

cd $BASEDIR/bacteria
wget --input bacteria_genomic_file

cd $BASEDIR/archaea
wget --input archaea_genomic_file


