# Comparative-Genomics-Hawaiian-Honeycreepers
This repository contains code used for various analyses of Hawaiian Honeycreeper genomes. At various degrees of completion.
### Generating reference guided assembly
The script *reads_to_genome_pipeline_set_as_slurm_array.sh* goes through aligning trimmed reads for 16 honeycreeper species to a reference Oʻahu ʻamakhi genome assembled using 10X linked reads. The pipeline aligns trimmomatic trimmed illumina short reads using bwa, removes duplicate reads using Picard, realigns indels using gatk3, calls genotypes using bcftools and then generates a new consensus alignment using bcftools consensus.
