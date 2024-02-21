#!/bin/bash
# Marton Horvath, February 2024

# Create environment
conda env create -f environment.yml

#Input directory
reads=$1
indir='data'
mkdir ${indir}

# Downloading reads
echo '########################'
echo '# Download the SRR reads'
echo '########################'

prefetch ${reads} -O ${indir}
fastq-dump ${indir}/${reads} --threads 10 --progress -O ${indir}/
cd ${indir} && wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/146/045/GCF_000146045.2_R64/GCF_000146045.2_R64_genomic.fna.gz
gunzip GCF_000146045.2_R64_genomic.fna.gz
mv GCF_000146045.2_R64_genomic.fna reference.fna
cd ..

# Quality check
folder_01='01_QC'
mkdir -p results/${folder_00}
fastqc -o results/${folder_00} -f fastq -t 10 ${indir}/SRR13577846.fastq

# de novo assembly

echo '#########################'
echo '# De novo genome assembly'
echo '#########################'
folder_02='02_assembly'
mkdir -p results/${folder_02}
flye --pacbio-hifi ${indir}/${reads}.fastq --out-dir results/${folder_02} --threads 10

# Polishing assembly
folder_03='03_quast'
mkdir -p results/${folder_03}
quast -o results/${folder_03}  -r ${indir}/reference.fna -t 10 --no-icarus results/${folder_02}/assembly.fasta

