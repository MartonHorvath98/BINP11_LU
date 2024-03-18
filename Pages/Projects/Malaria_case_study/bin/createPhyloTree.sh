#!bin/bash

# This script is used to create a phylogenetic tree using the orthologous genes.
# First, extracts the complete of fragmented BUSCO genes found in all taxa.

while getopts i:p:o: flag
do
    case "${flag}" in
        i) input_dir=${OPTARG};;
        p) protein_dir=${OPTARG};;
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
done

# Store the complete BUSCO genes name present in all taxa
cat $output_dir/complete.tsv | cut -f2 | sort | uniq -c |\
awk '$1 == 8 {print $2}' > $output_dir/all_shared_ortho.tsv
cat $output_dir/complete.tsv | grep -v "Tg" | cut -f2 | sort | uniq -c |\
awk '$1 == 7 {print $2}' > $output_dir/noTg_shared_ortho.tsv

# A while loop that reads in genes from the all_share_ortho.tsv file, finds the corresponding
# sequence ids from the tsv_path file, and then extracts the sequences from the protein_dir
# and stores them in a file named after the gene. For the taxon Tg only add the first hit!
mkdir -p ${output_dir}/sequences

while read gene; do
    echo "Extracting sequences for $gene"
    grep -w $gene $output_dir/complete.tsv | cut -f1 | while read taxa; do
        grep -w $gene ${input_dir}/${taxa}.protein/${tsv_path} | cut -f3 | head -1 | while read seq_id; do
            grep --no-group-separator -A1 -w $seq_id ${protein_dir}/${taxa}.fixed.faa >> $output_dir/sequences/$gene.faa
        done
    done
done < $output_dir/all_shared_ortho.tsv

mkdir -p ${output_dir}/noTg_sequences

while read gene; do
    echo "Extracting sequences for $gene"
    grep -w $gene $output_dir/complete.tsv | cut -f1 | while read taxa; do
        grep -w $gene ${input_dir}/${taxa}.protein/${tsv_path} | cut -f3 | head -1 | while read seq_id; do
            grep --no-group-separator -A1 -w $seq_id ${protein_dir}/${taxa}.fixed.faa >> $output_dir/noTg_sequences/$gene.faa
        done
    done
done < $output_dir/noTg_shared_ortho.tsv

# Run Clustal Omega to align the sequences
mkdir -p ${output_dir}/alignments

for f in $output_dir/sequences/*; do
    if [ -f "$f" ]; then
        echo "Aligning $f"
        clustalo -i $f -o ${output_dir}/alignments/$(basename $f .faa).aln --auto
    fi
done

mkdir -p ${output_dir}/noTg_alignments

for f in $output_dir/noTg_sequences/*; do
    if [ -f "$f" ]; then
        echo "Aligning $f"
        clustalo -i $f -o ${output_dir}/noTg_alignments/$(basename $f .faa).aln --auto
    fi
done

# Create a tree from the alignments using iqtree
# 1. for the full set of genes
mkdir -p ${output_dir}/tree

for f in $output_dir/alignments/*; do
    if [ -f "$f" ]; then
        echo "Creating tree from $f"
        mkdir -p ${output_dir}/tree/$(basename $f .aln)
        iqtree -s $f -m MFP -bb 1000 -nt AUTO -pre ${output_dir}/tree/$(basename $f .aln)/$(basename $f .aln)
    fi
done
# Extract the AICs from the log files
grep -oP "(?<=BEST SCORE FOUND : ).+" $(find ${output_dir}/tree/ -name *.log) | tr ":" "\t" |\
sort -n -k2 > ${output_dir}/AICs_full.txt

# 2. for the set of shared genes excluding the outgroup, Toxoplasma gondii
mkdir -p ${output_dir}/noTg_tree

for f in $output_dir/noTg_alignments/*; do
    if [ -f "$f" ]; then
        echo "Creating tree from $f"
        mkdir -p ${output_dir}/noTg_tree/$(basename $f .aln)
        iqtree -s $f -m MFP -bb 1000 -nt AUTO -pre ${output_dir}/noTg_tree/$(basename $f .aln)/$(basename $f .aln)
    fi
done
# Extract the AICs from the log files
grep -oP "(?<=BEST SCORE FOUND : ).+" $(find ${output_dir}/noTg_tree/ -name *.log) | tr ":" "\t" |\
sort -n -k2 > ${output_dir}/AICs_noTg.txt
