#!bin/bash

# This script is used to identify orthologous genes present across all taxa. First,
# the script runs BUSCO analysis on the gene predictions for each species. Then, with
# the custom script gffParse.pl it extracts each gene from the gene predictions. And,
# finally, the script runs proteinOrtho to identify orthologous genes present across 
# all taxa.

while getopts i:g:d:b:o: flag
do
    case "${flag}" in
        i) input_dir=${OPTARG};;
        g) gtf_dir=${OPTARG};;
        d) busco_db=${OPTARG};;
        b) busco_dir=${OPTARG};;
        o) orto_dir=${OPTARG};;
    esac
done

# Define a function to extract the first letter of each word separated by underscores
get_initials() {
    echo "$1" | awk -F_ '{for (i=1; i<=NF; i++) printf "%s", substr($i,1,1)}'
}

# Create a BUSCO directory
mkdir -p ${busco_dir}

# Run BUSCO analysis on the gene predictions for each species
for f in $input_dir/*; do
    if [ -f "$f" ]; then
        echo "Running BUSCO on $(basename $f)"
        output=$(get_initials "$(basename $f)")
        # run busco
        busco -i $f --out_path "$busco_dir/$output.genome" -m genome -c 8 -l "$busco_db/apicomplexa_odb10"
        generate_plot.py -wd "$busco_dir/$output.genome" 
        # move the plot and the summary to the main busco directory
        mv "$busco_dir/$output/"*.png "$busco_dir/$output"_busco.png
        mv "$busco_dir/$output/"*.txt "$busco_dir/$output"_summary.txt
    fi
done

# Create a directory to store extracted gene sequences
mkdir -p ${orto_dir}

# Extract each gene from the gene predictions using the gffParse.pl script
for f in $input_dir/*; do
    if [ -f "$f" ]; then
        echo "Extracting genes from $(basename $f)"
        taxon=$(get_initials "$(basename $f)")
        perl bin/gffParse.pl -c -p -i $f -g "$gtf_dir/genemark.$taxon.gtf" -d "$orto_dir/$taxon" -b $taxon
    fi
done

