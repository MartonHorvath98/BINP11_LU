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
qc='results/01_QC'
mkdir -p ${qc}
fastqc -o ${qc} -f fastq -t 10 ${indir}/${reads}.fastq

# de novo assembly

echo '#########################'
echo '# De novo genome assembly'
echo '#########################'
assembly='results/02_assembly'
mkdir -p ${assembly}
flye --pacbio-hifi ${indir}/${reads}.fastq --out-dir ${assembly} --threads 10

# Polishing assembly
polishing='results/03_quast'
mkdir -p ${polishing}
quast -o ${polishing}  -r ${indir}/reference.fna -t 10 --no-icarus ${assembly}/assembly.fasta

# analyzing assembly quality based on the coverage and fragmentation of BUSCO genes
echo '#####################'
echo '# BUSCO gene analysis'
echo '#####################'
BUSCO='results/04_busco'
mkdir -p ${BUSCO}
busco -i ${assembly}/assembly.fasta -m genome -c 12 --out_path ${BUSCO}/ -l saccharomycetes_odb10
generate_plot.py -wd ${BUSCO}/BUSCO_assembly.fasta/

echo '######################'
echo '# Analysis finished...'
echo '######################'