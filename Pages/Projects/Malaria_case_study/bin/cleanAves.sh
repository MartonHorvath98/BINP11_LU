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

while getopts fa:g:db:gc:o: flag
do
    case "${flag}" in
        fa) fasta=${OPTARG};;
        g) gtf=${OPTARG};;
        db) bird_db=${OPTARG};;
        gc) gc_threshold=${OPTARG};;
        o) out_dir=${OPTARG};;
    esac
done

# Define a function to extract the first letter of each word separated by underscores
get_initials() {
    echo "$1" | awk -F_ '{for (i=1; i<=NF; i++) printf "%s", substr($i,1,1)}'
}

# Read in files from the input fasta file and gtf file using the -fa or -gtf flags
if[ -z "$fasta" ]
then
    echo "No fasta file provided"
    exit 1
fi
else
    echo "Gene predition for $(basename $f)"
    output=$(get_initials "$(basename $f)")

    # Create a gene prediction directory
    gene_dir=$out_dir/gene_prediction
    mkdir -p $gene_dir   
    # Run the removeScaffold.py script
    python bin/removeScaffold.py $fasta $gc_threshold $gene_dir/$output"_GC"$gc_threshold 3000
    # Run the gffParser.pl script
    gffParser.pl -i $gene_dir/$output"_GC"$gc_threshold".fa" -g $gtf -d $gene_dir -b $output"_GC"$gc_threshold"_pred" -p -c

    echo "Running blastp on $(basename $f)"
    echo "This will take a WHILE... go stretch, take a coffee :)"
    # Create a blastp directory
    blast_dir=$out_dir/blastp
    mkdir -p $blast_dir
    # Run blastp to compare the proteins to the bird protein database
    blastp -query $gene_dir/$output"_GC"$gc_threshold"_pred.faa" -db SwissProt -outfmt 6 \
        -num_threads 16 -evalue 0.05 -out $blast_dir/$output"_GC"$gc_threshold"_hits.tsv" 
    # evalue cutoff is set to 0.05; the output format is tabular (6); the number of threads is set to 16

    # Create a filtered genome directory
    filtered_dir=$out_dir/clean_genome
    mkdir -p $filtered_dir

    echo "Filtering $(basename $f)"
    # Find proteins that match any bird proteins among the top 5 hits
    hits=$(cat $blast_dir/$output"_GC"$gc_threshold"_hits.tsv")
    genes=$(echo $hits |\
     awk 'NR==1 {value=$1; count=1} $1!=value {value=$1; count=1} $1==value && count<=5 {print; count++}' |\
     grep -Ff <(cut -f 2 $bird_db) | cut -f1 | sort | uniq)
    # Find the contigs where the genes encoding these proteins are located
    contigs=$(cat $gtf | grep -wFf <(echo $genes) | cut -f1 | sort | uniq)
    # Remove these contigs from the genome assembly
    clean_genome=$(cat $gene_dir/$output"_GC"$gc_threshold".fa" |\
        grep -vFf <(echo $contigs) | grep -A 1 "^>" --no-group-separator)
    
    echo "Saving the filtered genome assembly"
    # Save the filtered genome assembly
    echo $clean_genome > $filtered_dir/$(basename $f)
fi
