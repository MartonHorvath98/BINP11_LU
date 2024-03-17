#!bin/bash

# This script is used to create a phylogenetic tree using the orthologous genes.
# First, extracts the complete of fragmented BUSCO genes found in all taxa.

while getopts i:o: flag
do
    case "${flag}" in
        i) input_dir=${OPTARG};;
        o) output_dir=${OPTARG};;
    esac
done

# Create a directory to store the complete and fragmented BUSCO genes
mkdir -p ${output_dir}

# Define the path to the full_table.tsv file
tsv_path="run_apicomplexa_odb10/full_table.tsv"

# Extract the complete and fragmented BUSCO genes found in all taxa
for taxa in {Ht,Pb,Pc,Pf,Pk,Pv,Py,Tg}; do
    echo "Extracting complete and fragmented BUSCO genes from $taxa"

    if [ ! -f "$output_dir/complete.tsv" ]; then
        echo -e "taxa\tgene" > $output_dir/complete.tsv
    fi

     # Extract the complete BUSCO genes
    cat ${input_dir}/${taxa}.protein/${tsv_path} $output_dir |\
    awk -v taxon=$taxa 'BEGIN{FS="\t"; OFS="\t"}{if($2 == "Complete") print taxon, $1}' >> $output_dir/complete.tsv
    
    # for Toxoplasma gondii only, add duplicated genes too to the complete.tsv file
    if [ $taxa == "Tg" ]; then
        cat ${input_dir}/${taxa}.protein/${tsv_path} $output_dir |\
        awk -v taxon=$taxa 'BEGIN{FS="\t"; OFS="\t"}{if($2 == "Duplicated") print taxon, $1}' |\
        uniq >> $output_dir/complete.tsv
    fi
    
done

# Store the complete BUSCO genes name present in all taxa
cat $output_dir/complete.tsv | cut -f2 | sort | uniq -c | awk '$1 == 8 {print $2}' > $output_dir/all_share_ortho.tsv

# Extract the complete BUSCO genes found in all taxa from the gene predictions
while read gene; do
    echo "Extracting shared BUSCO genes found in all taxa"
    for taxa in {Ht,Pb,Pc,Pf,Pk,Pv,Py,Tg}; do
        grep -A1 --no-group-separator $gene ${input_dir}/${taxa}.protein/${taxa}.faa > $output_dir/$taxa/$gene.faa
    done
done < $output_dir/all_share_ortho.tsv
