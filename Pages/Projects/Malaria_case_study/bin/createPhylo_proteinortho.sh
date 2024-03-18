#!bin/bash

# This script is used to create a phylogenetic tree using the orthologous genes.
# First, extracts the complete of fragmented BUSCO genes found in all taxa.

while getopts i:p:o: flag
do
    case "${flag}" in
        i) input_dir=${OPTARG};;
        p) proteinorhto=${OPTARG};;
        o) output_dir=${OPTARG};;
    esac
done

# Create a directory to store the complete and fragmented BUSCO genes
mkdir -p ${output_dir}

# Extract the complete and fragmented BUSCO genes found in all taxa
tsv_path=$(find "$input_dir" -name $proteinorhto)

if [ -f "${tsv_path}" ]; then
    echo "Extracting ProteinOrtho predicted groups found in all taxa"
    awk -F"\t" '$1 == "8" && $2 == "8" && $3 > 0.7 {
        print "Group"NR,$4,$5,$6,$7,$8,$9,$10,$11
        }' $tsv_path > ${output_dir}/complete.tsv
fi

# Create a directory to store the sequences
mkdir -p ${output_dir}/sequences

while read -r line; do
    group=$(echo $line | cut -d " " -f1)
    genes=$(echo $line | cut -d " " -f2-9)
    echo -e "Extracting sequences in $group"
    for gene in $genes; do
        for taxa in {Ht,Pb,Pc,Pf,Pk,Pv,Py,Tg}; do
            grep --no-group-separator -A1 -w $gene ${input_dir}/${taxa}.fixed.faa >> ${output_dir}/sequences/${group}.fna
        done
    done
done < ${output_dir}/complete.tsv

# Run Clustal Omega to align the sequences
mkdir -p ${output_dir}/alignments

for f in $output_dir/sequences/*; do
    if [ -f "$f" ]; then
        echo "Aligning $f"
        clustalo -i $f -o ${output_dir}/alignments/$(basename $f .faa).aln --auto
    fi
done

# Create a tree from the alignments using iqtree
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
