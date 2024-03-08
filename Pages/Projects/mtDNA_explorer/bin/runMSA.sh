#!/bin/bash

# Define variables for environment name and Python version
ENV_NAME="MSA"
CONFIG="../config/environment.yml"

# Check if the environment already exists
if ! mamba env list | grep -q "^$ENV_NAME"; then
    # Create the Mamba environment
    mamba create -n "$ENV_NAME" --no-default-packages    
    echo "Conda environment '$ENV_NAME' created successfully..."
else
    # Activate the existing environment
    mamba env update -n "$ENV_NAME" --file "$CONFIG"
    mamba activate "$ENV_NAME"
    
    echo "Conda environment '$ENV_NAME' already exists and activated."
fi

# get input and output file names with argparse
while getopts i: flag
do
    case "${flag}" in
        i) in_file=${OPTARG};; # input file
        f) filter=${OPTARG};; # filter file
    esac
done
# check if the input file exists then run mafft on the input file
if [ -f "$in_file" ]
then
    # Check if the file is in FASTA format
    if ! grep -q "^>" "$in_file"; then
        echo "Error: File '$in_file' is not in FASTA format!"
        exit 1
    fi
    # Remove line breaks from the FASTA file
    echo "Converting FASTA file to one-line format..."
    awk '/^>/ {if (NR>1) print ""; print $0; next} {printf "%s", $0} END {print ""}' "$fasta_file" > "${in_file%.fasta}_oneline.fasta"

    # Filter the input file based on the filter file
    echo "Filtering input file based on the filter file..."
    if [ -f "$filter" ]; then
        echo "Filtering input file based on the filter file..."
        grep -A 1 -wFf "$filter" --no-group-separator "${in_file%.fasta}_oneline.fasta" > "${in_file%.fasta}_filtered.fasta"
    fi

    # Run multiple sequence alignment using MAFFT
    echo "Running multiple sequence alignment..."
    mafft --auto --thread 4 "${in_file%.fasta}_oneline.fasta" > "${in_file%.fasta}_msa.fasta"

    # Use bioawk to calculate base information content
    echo "Calculating information content from MSA..."

    awk '/^>/ { if (NR>1) print ""; print $0; next} { printf "%s", $0 } END {print ""}' "${in_file%.fasta}_msa.fasta" | \
        grep -v "^>" | \
        awk 'BEGIN { FS = "" } { 
            for (i = 1; i <= NF; i++) {
                a[NR, i] = $i 
            } 
        } 
        NF > p { 
            p = NF 
        } 
        END { 
            for (j = 1; j <= p; j++) { 
                str = a[1, j]; 
                for (i = 2; i <= NR; i++) { 
                    str = str a[i, j] 
                } 
                print str 
            } 
        }' > "${in_file%.fasta}_transposed.txt"

    awk 'BEGIN { FS = ""; OFS="\t"; OFMT = "%.4f"; print "Pos", "Info" }
    {
        delete charCounts
        rowLength = length($0)
        sum = 0

        # Count occurrences of each character
        for (i = 1; i <= rowLength; i++) {
            charCounts[$i]++
        }

        # Calculate and sum up p * log(p) for each character, where log is natural log
        for (char in charCounts) {
            p = charCounts[char] / rowLength
            if (p > 0) {
                sum -= p * log(p)
            }
        }

        print NR, 2 - sum
    }' "${in_file%.fasta}_transposed.txt" > "${in_file%.fasta}_info_content.txt

else
    echo "Input file does not exist. Please check the file path and try again."
fi