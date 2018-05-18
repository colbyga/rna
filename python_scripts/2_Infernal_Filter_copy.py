#!/usr/bin/env python

import sys
import os
import os.path
import shutil
import subprocess
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord

#/global/project/hpcg1504/rna/analysis_gc/contam_3/demo.fastq
sequence_file = open('/global/project/hpcg1504/rna/analysis_gc/contam_3/demo.fastq', "r")
#parses fastq file into a list
sequences = list(SeqIO.parse(sequence_file, "fastq"))
#/global/project/hpcg1504/rna/analysis_gc/infernal/demo.fasta_rRNA.infernalout
Infernal_out = ('/global/project/hpcg1504/rna/analysis_gc/infernal/demo.fasta_rRNA.infernalout')

#output files
mRNA_file = open('/global/project/hpcg1504/rna/analysis_gc/infernal/demo_unique_mRNA.fastq', 'rw+')
rRNA_file = open('/global/project/hpcg1504/rna/analysis_gc/infernal/demo_unique_rRNA.fastq', 'rw+')


#empty unordered collections of unique elements
Infernal_rRNA_IDs = set()

mRNA_seqs = set()
rRNA_seqs = set()

#with open(Infernal_out, "r") as infile_read:
#    for line in infile_read:
#		x = len(line)
#		print(x)

with open(Infernal_out, "r") as infile_read:
    for line in infile_read:
        if not line.startswith("#") and len(line) > 10:
            Infernal_rRNA_IDs.add(line[:line.find(" ")].strip())

mRNA_seqs = set()

for sequence in sequences:
    if sequence.id in Infernal_rRNA_IDs:
        rRNA_seqs.add(sequence)
    else:
        mRNA_seqs.add(sequence)    #this is the problem line

with mRNA_file as out:
    SeqIO.write(list(mRNA_seqs), out, "fastq")

with rRNA_file as out:
    SeqIO.write(list(rRNA_seqs), out, "fastq")

print str(len(rRNA_seqs)) + " reads were aligned to the rRNA database"
print str(len(mRNA_seqs)) +  " reads were not aligned to the rRNA database"