#!/bin/bash
#SBATCH--job-name=reads_to_genome
#SBATCH--output=/path/to/output/dir/log%a.log
#SBATCH--time=1-00:00:00
#SBATCH--chdir=/path/to/output/dir
#SBATCH--cpus-per-task=18
#SBATCH--mem=100G
#SBATCH--array=1-16

module load bwa/0.7.17
module load samtools/1.11
module load picard/2.24.1

REF=/path/to/reference
IDX=/path/to/bwa/index
READS_DIR=/path/to/reads/directory
#.txt is a list of directories/files for SLURM array. Task ID will keep an index of each line
line_N=$( awk "NR==$SLURM_ARRAY_TASK_ID" list_of_genomes_to_generate.txt)
#use bwa for alignment and sorting of bam output
srun bwa mem -M -t 18 $IDX \
$READS_DIR/${line_N}_1P.fq.gz \
$READS_DIR/${line_N}_2P.fq.gz |
  samtools view -@ 18 -f 3 -bS - | samtools sort -@ 18 -O bam -o ${line_N}.first.bam
#index first bam file
samtools index -@18 ${line_N}.first.bam
#add read group information for gatk tools
srun java -Xmx90G -jar $PICARD AddOrReplaceReadGroups \
  --INPUT ${line_N}.first.bam --OUTPUT ${line_N}.second.bam \
  --RGLB lib1 --RGPL ILLUMINA --RGPU unit1 --RGSM ${line_N}
  
samtools index -@10 ${line_N}.second.bam
#mark and remove duplicates
srun java -Xmx90G -jar $PICARD MarkDuplicates \
  INPUT=${line_N}.second.bam \
  OUTPUT=${line_N}.third.bam \
  METRICS_FILE=${line_N}.metrics.txt \
  ASSUME_SORTED=true \
  REMOVE_DUPLICATES=true
  
rm ${line_N}.first.bam
rm ${line_N}.first.bam.bai
rm ${line_N}.second.bam
rm ${line_N}.second.bam.bai

samtools index -@10 ${line_N}.third.bam
#load gatk3 for indel re-aligning
module purge
module load anaconda3/2020.11
conda activate gatk3_env

srun gatk -T RealignerTargetCreator \
  -R $REF \
  -I ${line_N}.third.bam -o ${line_N}.target.intervals
  
srun gatk -T IndelRealigner \
  -R $REF \
  -targetIntervals ${line_N}.target.intervals \
  -I ${line_N}.third.bam -o ${line_N}.indel.realigner.bam
conda deactivate
rm ${line_N}.third.bam
rm ${line_N}.third.bam.bai
#take input from indel realigner and call genotypes
conda activate bcftools_env
srun bcftools mpileup --threads 18 -f $REF ${line_N}.indel.realigner.bam \
        -Q 20 -q 20 --output-type uv | bcftools call --threads 18 -c -O z \
       	-o ${line_N}.bcf.called.vcf.gz
srun bcftools index --threads 18 ${line_N}.bcf.called.vcf.gz
#take called genotypes from vcf file and generate new consensus genome inputting N characters
#where genotypes are missing in vcf
srun bcftools consensus --absent N -H A -f $REF -o ${line_N}.bcf.consensus.fa ${line_N}.bcf.called.vcf.gz

  


