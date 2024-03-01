#!/bin/bash

# This script is used to run the QC pipeline for the RNA-seq data
while getopts d:f:o: flag
do
    case "${flag}" in
        d) dir1=${OPTARG};;
        f) file1=${OPTARG};;
        o) out_dir1=${OPTARG};;
    esac
done

echo "$dir1, $file1, $out_dir1"
# Read in files from the input file or directory using -f or -d flags
if [ -z "$file1" ]
then
    for f in $dir1/*; do
        if [ -f "$f" ]; then
            echo "Processing  $(basename $f) file..."
            # Run the QC pipeline
            seqkit stats $f -Ta >> ${out_dir1}/stats.txt
        fi
    done
else
    echo "Processing $file1 file..."
    # Run the QC pipeline
    seqkit stats $file1 -Ta >> $out_dir1/stats.txt
fi

# Clean seqkit output: remove repetitive headers and remove the path from the file name
stat_file=$out_dir1/stats.txt
awk 'NR==1 || NR%2==0' $stat_file | awk -F'\t' -v OFS='\t' '{sub(".*/", "", $1)} 1' > $out_dir1/stats_table.tsv 
rm $stat_file
