#!/bin/bash

# This script is used to run the QC pipeline for the RNA-seq data
while getopts d:f:o: flag
do
    case "${flag}" in
        d) dir=${OPTARG};;
        f) file=${OPTARG};;
        o) out_dir=${OPTARG};;
    esac
done

# Read in files from the input file or directory using -f or -d flags
if [ -z "$file" ]
then
    for f in $dir/*; do
        if [ -f "$f" ]; then
            echo "Processing $f file..."
            # Run the QC pipeline
            seqkit stats $f -Ta >> $out_dir/stats.tsv
        fi
    done
else
    echo "Processing $file file..."
    # Run the QC pipeline
    seqkit stats $file -Ta >> $out_dir/stats.txt
fi

# Clean seqkit output: remove repetitive headers and remove the path from the file name
stat_file=$out_dir/stats.txt
awk 'NR==1 || NR%2==0' $stat_file | awk -F'\t' -v OFS='\t' '{sub(".*/", "", $1)} 1' > $out_dir/stats_table.tsv 
rm $stat_file
