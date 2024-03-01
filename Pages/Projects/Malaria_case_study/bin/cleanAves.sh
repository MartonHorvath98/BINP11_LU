#!/bin/bash

# This script is used to remove contigs from the genome assembly that map to bird genomes! It takes
# a genome assembly in fasta format and a gtf file as input and outputs a filtered genome assembly in fasta format.

# The script uses the custom scripts removeScaffold.py and gffParser.pl: 1) removeScaffold.py is used to 
# remove contigs below a given GC threshold and length 2) gffParser.pl is used to extract hypothetical proteins 
# from the genome assembly. Then, the script uses blastp to compare the proteins to the bird protein database 
# downloaded from SwissProt and removes contigs that match any bird proteins among the top 5 hits.

# removeScaffold.py usage: removeScaffolds.py [arg1] [arg2] [arg3] [arg4]
#   -   sys.argv[1] is input fasta file name
#   -   sys.argv[2] is threshold GC content as integer
#   -   sys.argv[3] is the output file
#   -   sys.argv[4] is the minimum length for scaffolds to keep

# gffParser.py usage: gffParser.py -i -g -d -b -p* -c*
#   -   [-i] input fasta file
#   -   [-g] input gff file
#   -   [-d] output directory
#   -   [-b] output basename
#   -   [-p] if set the program outputs a protein file
#   -   [-c] if set, when an internal stop codon is found the program will try the next reading frame

while getopts f:g:d:t:o: flag
do
    case "${flag}" in
        f) fasta=${OPTARG};;
        g) gtf=${OPTARG};;
        d) bird_db=${OPTARG};;
        t) gc_threshold=${OPTARG};;
        o) out_dir=${OPTARG};;
    esac
done

# Define a function to extract the first letter of each word separated by underscores
get_initials() {
    echo "$1" | awk -F_ '{for (i=1; i<=NF; i++) printf "%s", substr($i,1,1)}'
}

# Read in files from the input fasta file and gtf file using the -fa or -gtf flags
if [ -f "$fasta" ]
then


    echo "Filtering $(basename $fasta)"
    # Find proteins that match any bird proteins among the top 5 hits

    cat $blast_dir/$output"_GC"$gc_threshold"_hits.tsv" |\
     awk 'NR==1 {value=$1; count=1} $1!=value {value=$1; count=1} $1==value && count<=5 {print; count++}' |\
     grep -Ff <(cut -f2 $bird_db) | cut -f1 | sort | uniq > $filtered_dir/$output"_GC"$gc_threshold"_genes.txt"
    # Find the contigs where the genes encoding these proteins are located
    cat $gtf | grep -wFf $filtered_dir/$output"_GC"$gc_threshold"_genes.txt" | cut -f1 | sort | uniq >\
     $filtered_dir/$output"_GC"$gc_threshold"_contigs.txt"
    # Remove these contigs from the genome assembly
    cat $gene_dir/$output"_GC"$gc_threshold".fa" |\
        grep -vFf $filtered_dir/$output"_GC"$gc_threshold"_contigs.txt" | grep -A 1 "^>" --no-group-separator >\
        $filtered_dir/$(basename $fasta)
fi

