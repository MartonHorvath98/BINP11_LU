#!/bin/bash

# The path to the input file
input_file="$1"

# Guess the delimiter by examining the first line of the file
delimiter=$(head -n 1 "$input_file" | grep -q "," && echo "," || echo "\t")

# If the delimiter is a comma, replace it with a tab
if [ "$delimiter" = "," ]; then
    sed -i 's/,/\t/g' "$input_file"
fi
# check how many columns are in the file
num_columns=$(head -n 1 "$input_file" | tr -cd "$delimiter" | wc -c)
# If the file has 4 columns, split the 4th column into two columns
if [ "$num_columns" -eq 3 ]; then
    file=$(awk -v FS="$delimiter" -v OFS="$delimiter" '
    NR> 1 && $1 ~ /^rs/ && $2 ~ /^(MT|0|26)$/ {
        split($4, chars, "");
        print $1, $3, chars[1], chars[2]
    }' "$input_file")
fi
# else if there are 5 columns it is already the correct format
if [ "$num_columns" -eq 4 ]; then
    file=$(awk -v FS="$delimiter" -v OFS="$delimiter" '
    NR > 1 && $1 ~ /^rs/ && $2 ~ /^(MT|0|26)$/ {
        print $1, $3, $4, $5
    }' "$input_file")
fi

output=$(echo -e "rsid\tposition\tallele1\tallele2\n$file")
echo "$output"