#!/bin/bash
# Marton Horvath, February 2024

# Create environment
mamba create -f environment.yml

#Set up directory tree
mamba activate malaria

# Run the QC pipeline
echo "#######################"
echo "Running the QC pipeline"
echo "#######################"

# Create the results directory
mkdir -p results/01_QC
qc_foder="results/01_QC"
source bin/QC.sh -d data/raw_genomes -o $qc_folder

# Run the gene prediction pipeline
echo "####################################"
echo "Running the gene prediction pipeline"
echo "####################################"

# Create the results directory
mkdir -p results/02_gene_prediction
gene_folder="results/02_gene_prediction"
# minimum contig length of 1000 bp for the first run
source bin/genePred.sh -d data/raw_genomes -o $gene_folder -m 1000 

# Clean the Haemoproteus tartakovskyi genome assembly
echo "###############################################"
echo "Cleaning the Haemoproteus tartakovskyi assembly"
echo "###############################################"

# Create the results directory
mkdir -p results/03_cleaned_genomes
clean_folder="results/03_cleaned_genomes"
# Run the cleanAves.sh script
source bin/cleanAves.sh -fa data/raw_genomes/Haemoproteus_tartakovskyi.genome \
    -g results/02_gene_prediction/genemark.Ht.gtf -db data/uniprot/aves_taxid.tsv \
    -gc 27 -o $clean_folder





