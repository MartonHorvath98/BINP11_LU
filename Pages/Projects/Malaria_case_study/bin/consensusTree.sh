#!bin/bash

# This script is used to create a consensus tree using the orthologous genes. First,
# the scripts screens the input folder and creates a soft link to every .contree file
# found to the output folder. Then, the script runs the consense program from the phylip
# package to create a consensus tree.

# Flags: i -> input directory, o -> output directory, h -> help, 
# m -> min_outgroup (default false): if true the script removes any tree with the outgroup
# from the full tree file
 
while getopts i:o: flag
do
    case "${flag}" in
        i) input_dir=${OPTARG};;
        o) output_dir=${OPTARG};;
        m) min_outgroup=${OPTARG};;
        h) echo "Usage: consensusTree.sh -i <input_dir> -o <output_dir> [-m <min_outgroup>]"; exit;;
    esac
done

# Create a directory to store the consensus trees
mkdir -p ${output_dir}

# Create a soft link to every .contree file found in the input folder
for f in $(find $input_dir -name "*.contree"); do
    if [ -f "$f" ]; then
        cp $f $output_dir
    fi
done

# Concatenate all the .contree files and create a consensus tree
cat ${output_dir}*.contree | sed 's/[0-9]*_g_//g' > ${output_dir}/full_tree.contree 

if  [ "$min_outgroup" = true ]; then
    # Remove any tree with the outgroup from the full tree file
    grep -v "Tg" ${output_dir}/full_tree.contree > ${output_dir}/tmp.full_tree.contree
    mv ${output_dir}/tmp.full_tree.contree ${output_dir}/full_tree.contree
fi

# Run phylip consense on the full tree
echo -e "Running phylip consense on the full tree - intree file: ${output_dir}/full_tree.contree\n"
phylip consense 