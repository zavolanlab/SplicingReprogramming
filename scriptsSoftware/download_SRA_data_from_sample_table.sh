#!/usr/bin/env bash
# Alexander Kanitz, University of Basel
# alexander.kanitz@alumni.ethz.ch
# 05-NOV-2016

# Usage: download_SRA_data_from_sample_table.sh <SAMPLE_TABLE> <OUTPUT_DIRECTORY>

# Usage notes:
# - Sample table requires a grouping ID (e.g. study ID) in the first and the SRA run ID
#   (starting with DRR, ERR or SRR) in the second column of a tab-delimited file.
# - Run data (in SRA format) will be downloaded to subdirectories according to the grouping
#   ID of each run.

# CLI arguments
in_file="$1"
out_dir="$2"

# Set constants
sra_root="ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByRun/sra"
timeout=10
tries=30

# Shell options
set -e
set -u
set -o pipefail

## MAIN ##

# Create output directory
mkdir -p "$out_dir"

# Iterate over individual runs
while read line; do

    # Get study and run ID
    std_id=$(echo "$line" | cut -f 1)
    run_id=$(echo "$line" | cut -f 2)

    # Write status
    >&2 echo "Downloading run '$run_id' from study '$std_id'..."

    # Create study output directory
    out_prefix="${out_dir}/${std_id}"
    mkdir -p "$out_prefix"

    # Build output filename
    out_file="${out_prefix}/${run_id}.sra"

    # Download file if it does not exist
    if [ ! -e "$out_file" ]; then

        # Build URL
        db="$(expr substr "$run_id" 1 3)"
        d1="$(expr substr "$run_id" 1 6)"
        d2="$run_id"
        url="${sra_root}/${db}/${d1}/${d2}/${run_id}.sra"

        # Write status
        >&2 echo "Downloading ${run_id}..."

        # Download file
        wget --quiet --timeout $timeout --tries $tries --output-document "$out_file" "$url"

    # Else skip run
    else

        # Write status
        >&2 echo "[WARNING] File '${run_id}.sra' exists. Run skipped."

    fi

done < <(tail -n +2 "$in_file")

# Write status
>&2 echo "Done".
