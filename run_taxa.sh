#!/bin/bash
#SBATCH --mem=160gb
#SBATCH --array=1-18
#SBATCH -c 8
#SBATCH -t 3-0:0:0 
#SBATCH -o /global/project/hpcg1504/rna/logs_gc/gc_run_kaiju.sh.%A_%a.stdout
#SBATCH -e /global/project/hpcg1504/rna/logs_gc/slurm/gc_run_kaiju.sh.%A_%a.stderr

#Step 7. taxa classification 

source activate parkinson_py2.7.12

module load bwa/0.7.17
module load samtools/1.5
module load blat/3.5
module load vsearch/2.5.0
module load fastqc/0.11.5

BASEDIR=/global/project/hpcg1504/rna
#cd $BASEDIR/analysis_gc
#mkdir kaiju
SCRIPTS=$BASEDIR/bin/python_scripts
REREP=$BASEDIR/analysis_gc/rereplication
KAIJU=$HOME/rna_dna_2017/dna/raw_data/data_complete/kaiju/bin
KAIJUFILES=$HOME/rna_dna_2017/dna/raw_data/data_complete/kaijudb_prokaryotes
KAIJUOUT=$BASEDIR/analysis_gc/kaiju


mRNA=`ls $REREP/*mRNA.fastq | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`
PREFIX=`basename $mRNA`
PREFIX=`echo $PREFIX | sed 's/_mRNA.fastq//g'`

cd $KAIJUOUT

$KAIJU/kaiju -t $KAIJUFILES/nodes.dmp -f $KAIJUFILES/kaiju_db.fmi -i $mRNA -a greedy -e 5 -m 11 -s 75 -z 8 -o $PREFIX"_classification.tsv"

python $SCRIPTS/4_Constrain_Classification.py genus $KAIJUOUT/$PREFIX"_classification.tsv" $KAIJUFILES/nodes.dmp $KAIJUFILES/names.dmp $KAIJUOUT/$PREFIX"_classification_genus.tsv"

$KAIJU/kaijuReport -t $KAIJUFILES/nodes.dmp -n $KAIJUFILES/names.dmp -i $KAIJUOUT/$PREFIX"_classification_genus.tsv" -o $KAIJUOUT/$PREFIX"_classification_Summary.txt" -r genus

echo "need to combine the output files and then run rscript, this step should be mostly complete already"
source deactivate

