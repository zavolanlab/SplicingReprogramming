#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 20-JUN-2017                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Summarize data from The Human Protein Atlas.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))"

# Set other parameters
scriptDir="${root}/scriptsSoftware"
outDir="${root}/analyzedData/summarized_data/thpa"
outFile="${outDir}/rna_expression.tissues.tpa.gene_level.tsv"
outFile_log="${outDir}/rna_expression.tissues.tpa.gene_level.log.tsv"
logDir="${root}/logFiles/summarize_data"
inFile="${root}/rawData/thpa/rna_expression.tissues.tpa.gene_level.tsv.gz"
colVert=1
colHoriz=3
colVal=4
base=2
pseudo=0.1


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

# Convert expression data table to matrix
"${scriptDir}/reshape_three_columns_to_matrix.R" \
    --input-file="$inFile" \
    --output-file="$outFile" \
    --vertical="$colVert" \
    --horizontal="$colHoriz" \
    --values="$colVal" \
    --input-gzipped \
    --verbose \
    &>> "$logFile"

# Log-transform matrix
"${scriptDir}/log_transform_matrix.R" \
    --input-file="$outFile" \
    --output-file="$outFile_log" \
    --base="$base" \
    --pseudo="$pseudo" \
    --verbose \
    &>> "$logFile"


#############
###  END  ###
#############

echo "Output files written to: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
