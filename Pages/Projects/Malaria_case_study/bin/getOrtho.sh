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
        busco -i $f --out "$busco_dir/$output.genome" -m genome -c 8 -l "$busco_db/apicomplexa_odb10"
        generate_plot.py -wd "$busco_dir/$output.genome" 
        # move the plot and the summary to the main busco directory
        mv "$busco_dir/$output/"*.png "$busco_dir/$output"_genome.png
        mv "$busco_dir/$output/"*.txt "$busco_dir/$output"_genome_summary.txt
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

# Fix header to keep gene number and taxa, and remove asterisks from sequences (stop codons)
for d in $orto_dir/*; do
    if [ -z "$d" ]; then
        echo "Fixing header and removing stop codons from $(basename $d)"
        taxon=$(basename $d | cut -d'.' -f1)
        
        # fix header
        awk -v fix="_$taxon" '/^>/{print $1 fix; next}{print}' "$ortho_dir/$d/$taxon.faa" | sed 's/\*//g' > "$orthod_dir/$taxon.fixed.faa"
    fi
done

# Call BUSCO again on the proteins predicted by gffParse.pl
for f in $ortho_dir/*; do
    if [ -f "$f" ]; then
        echo "Running BUSCO on $(basename $f)"
        output=$(basename $f | cut -d'.' -f1)
        # run busco
        busco -i $f --out "$busco_dir/$output.protein" -m prot -c 8 -l "$busco_db/apicomplexa_odb10"
        generate_plot.py -wd "$busco_dir/$output.protein" 
        # move the plot and the summary to the main busco directory
        mv ${busco_dir}/${output}.protein/*.png ${busco_dir}/${output}_protein.png
        mv ${busco_dir}/${output}.protein/*.txt ${busco_dir}/${output}_protein_summary.txt
    fi
done

# Call proteinortho to find orthologs using brace expansion.
proteinortho6.pl -project=Malaria_phylo $ortho_dir/{Ht,Pb,Pc,Pf,Pk,Pv,Py,Tg}.fixed.faa

