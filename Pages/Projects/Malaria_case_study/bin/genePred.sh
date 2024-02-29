#!/bin/bash

# This script is used to run the gene prediction pipeline for the RNA-seq data
# The gene prediction uses the gmes_petap.pl script from the gmes suite
while getopts d:f:m:o: flag
do
    case "${flag}" in
        d) dir=${OPTARG};;
        f) file=${OPTARG};;
        m) min_contig=${OPTARG};;
        o) out_dir=${OPTARG};;
    esac
done

# Define a function to extract the first letter of each word separated by underscores
get_initials() {
    echo "$1" | awk -F_ '{for (i=1; i<=NF; i++) printf "%s", substr($i,1,1)}'
}


# Read in files from the input file or directory using -f or -d flags
if [ -z "$file" ]
then
    for f in $dir/*; do
        if [ -f "$f" ]; then
            echo "Processing $(basename $f) file..."
            # Create a unique output directory based on the initials of the species name
            output=$(get_initials "$(basename $f)")
            # Run the gene prediction function
            gmes_petap.pl --ES --min_contig $min_contig --cores 16 --sequence $f --work_dir $out_dir/$output
        fi
    done
else
    echo "Processing $(basename $file) file..."
    # Create a unique output directory based on the initials of the species name
    output=$(get_initials "$(basename $file)")
    # Run the gene prediction function
    gmes_petap.pl --ES --min_contig $min_contig --cores 16 --sequence $file --work_dir $out_dir/$output
fi

# Visit the output directory, move the gene prediction files to the main output directory
# and rename the files to include the species name
for d in $out_dir/*; do
    if [ -d "$d" ]; then
        species=$(basename $d)
        mv $d/*.gtf $out_dir/genemark.${species}.gtf # Gene prediction file
        mv $d/*.log $out_dir/${species}.log # Log file
        # Remove the directory
        rm -r $d
    fi
done

