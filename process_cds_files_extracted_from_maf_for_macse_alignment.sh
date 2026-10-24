#!/bin/bash
# process_fasta.sh
#process extracted cds files from .maf file removing * and - chracters to realign using macse pipeline
echo "Processing file: $1"
base=$(basename $1 _combined.fasta)
sed 's/[*-]//g; /^$/d' "$1" > ${base}_cleaned.fasta_tmp
seqkit seq --min-len 1 ${base}_cleaned.fasta_tmp > ${base}_cleaned.fasta
sed -i '/^>/ s/ //g' ${base}_cleaned.fasta
rm ${base}_cleaned.fasta_tmp
