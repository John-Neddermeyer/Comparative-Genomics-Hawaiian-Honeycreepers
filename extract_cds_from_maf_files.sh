#!/bin/bash
#parse chromosome specific maf files to extract CDS sequence. Takes input a list of ensemble gene ids
#can be run using xargs for large lists of gene ids. Script needs to be modified to direct combined CDS fasta
#files to directory other than temp_dir set here.
while read line 
  do 
    mkdir ${line}_temp_dir
#search for ensemble gene idea within chromosome subsets of zebrafinch gtf
#extract canonical transcript CDS
    grep --no-filename ${line} chr*gtf | grep Ensembl_canonical | grep CDS > ${line}_temp_dir/${line}.gtf_tmp
#strip Taeniopygia_guttata. from chromosome alignment name in .maf
    VAR=$(grep --no-filename ${line} chr*gtf | head -n1 | awk '{print $1}' |sed 's/Taeniopygia_guttata.//g')
    cd ${line}_temp_dir
#use msa_split to pull CDS from per chromosome maf. Will output fasta file for each coordinate interval
    msa_split ${VAR}_filtered_33_minRow.maf --in-format MAF --features ${line}.gtf_tmp --for-features \
      --out-root ${line}_msa_split
#if more than one fasta file is produced for each ensemble CDS interval than concatenate the individual
#fasta files using seqkit concat. Sometimes there is only one CDS interval
    TEST_VAR=$(ls *fa | wc -l) 
      if [ "$TEST_VAR" -gt 1 ] 
        then 
          seqkit concat --full *fa > ${line}_combined.fasta 
        else mv ${line}_msa_split*fa ${line}_combined.fasta
    fi
    cd ..
    rm -r ${line}_temp_dir 
  done < list.tmp
