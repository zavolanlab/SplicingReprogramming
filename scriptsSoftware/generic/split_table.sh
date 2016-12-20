#!/usr/bin/env bash
# Alexander Kanitz, University of Basel
# alexander.kanitz@alumni.ethz.ch
# 29-OCT-2016

# CLI arguments
in_table="$1"
out_dir="$2"
prefix="$3"
file_ext="$4"
chunk_size="$5"

# Set parameters
header_size=1
suffix_len=3

# Shell options
set -e
set -u
set -o pipefail

## MAIN ##

# Write status
>&2 echo "Generating table chunks in '$out_dir'..."

# Create output directory
mkdir --parents "$out_dir"

# Get header
header=$(head -n "$header_size" "$in_table")

# Split table by desired number of lines
split --lines "$chunk_size" --numeric-suffixes --suffix-length "$suffix_len" <( tail -n +$(($header_size + 1)) "$in_table") "${out_dir}/${prefix}"

# Generate pattern for globbing table chunk files
glob_pattern=$(head -c $suffix_len < /dev/zero | tr '\0' '?')

# Iterate over table chunk files
for file in "${out_dir}/${prefix}"$glob_pattern; do

    # Add header and append file extension
    cat <(echo "$header") "$file" > "${file}${file_ext}"

    # Remove headerless files
    rm "$file"

done

# Write status
>&2 echo "Done."
