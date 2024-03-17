#!/bin/bash

# This script is used to run the gene prediction pipeline for the RNA-seq data
# The gene prediction uses the gmes_petap.pl script from the gmes suite
while getopts d:f:m:o: flag
do
    case "${flag}" in
        d) dir2=${OPTARG};;
        f) file2=${OPTARG};;
        m) min_contig=${OPTARG};;
        o) out_dir2=${OPTARG};;
    esac
done

# Define a function to extract the first letter of each word separated by underscores
get_initials() {
    echo "$1" | awk -F_ '{for (i=1; i<=NF; i++) printf "%s", substr($i,1,1)}'
}


# Read in files from the input file or directory using -f or -d flags
if [ -z "$file2" ]
then
    for f in $dir2/*; do
        if [ -f "$f" ]; then
            echo "Predicting $(basename $f) file..."
            # Create a unique output directory based on the initials of the species name
            output2=$(get_initials "$(basename $f)")
            # Run the gene prediction function
            wd="$out_dir2/$output2"
            mkdir -p ${wd}
            gmes_petap.pl --ES --min_contig ${min_contig} --cores 100 --sequence ${f} --work_dir ${wd}
        fi
    done
else
    echo "Predicting $(basename $file2) file..."
    # Create a unique output directory based on the initials of the species name
    output2=$(get_initials "$(basename $file2)")
    # Run the gene prediction function

    wd="$out_dir2/$output2"
    mkdir -p ${wd}
    gmes_petap.pl --ES --min_contig ${min_contig} --cores 100 --sequence ${file2} --work_dir ${wd}
fi

# Visit the output directory, move the gene prediction files to the main output directory
# and rename the files to include the species name
for d in ${out_dir}/*; do
    if [ -d "$d" ]; then
        species=$(sed 's#.*/##' <<< $d)
        cat "${d}/genemark.gtf" | sed -e "s/\s*length=[[:digit:]]*.*numreads=[[:digit:]]*\b//gm" > "${out_dir}/genemark.${species}.gtf" # Gene prediction file
        mv "${d}/gmes.log" "${out_dir}/${species}.log" # Log file
        # Remove the directory
        #rm -r $d
    fi
done

