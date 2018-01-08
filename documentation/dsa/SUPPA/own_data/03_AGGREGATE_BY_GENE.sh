#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 17-FEB-2017                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Summarize differential splicing analysis results.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))))"

# Set script path
script="${root}/scriptsSoftware/suppa/suppa_diff_splice_aggregate_by_gene.R"

# Set input files
inDir="${root}/analyzedData/dsa/SUPPA/own_data/merged"

# Set output directories
outDir="$inDir"
logDir="${root}/logFiles/analyzedData/dsa/SUPPA/own_data"

# Set other script parameters
suffixDPSI=".dpsi.tsv"
suffixP=".p.tsv"
outFileSuffix="aggregated_by_gene"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir -p "$outDir"
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

## Delta PSI
echo "Aggregating dPSI value tables..." >> "$logFile"

# Iterate over files
for file in "${inDir}/"*"${suffixDPSI}"; do

    # Get output filename
    out_file=${outDir}/$(basename "$file" "$suffixDPSI").${outFileSuffix}${suffixDPSI}

    # Aggregate
    "$script" \
        --input-file "$file" \
        --output-file "$out_file" \
        --verbose \
        &>> "$logFile"

done


## P
echo "Aggregating P value tables..." >> "$logFile"

# Iterate over files
for file in "${inDir}/"*"${suffixP}"; do

    # Get output filename
    out_file=${outDir}/$(basename "$file" "$suffixP").${outFileSuffix}${suffixP}

    # Aggregate
    "$script" \
        --input-file "$file" \
        --output-file "$out_file" \
        --p-values \
        --verbose \
        &>> "$logFile"

done

#############
###  END  ###
#############

echo "Output written to: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
