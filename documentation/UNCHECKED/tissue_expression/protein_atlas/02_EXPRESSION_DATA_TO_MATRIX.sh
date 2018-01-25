#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 20-JUN-2017                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Transform expression data from The Human Protein Atlas to matrix format.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"

# Set other parameters
script="${root}/scriptsSoftware/generic/reshape_three_columns_to_matrix.R"
outDir="${root}/publicResources/protein_atlas/rna_expression"
outFile="${outDir}/rna_expression.tissues.tpa.gene_level.tsv"
logDir="${root}/logFiles/publicResources/protein_atlas/rna_expression"
inFile="${root}/publicResources/protein_atlas/rna_expression/rna_expression.tissues.tpa.gene_level.tsv.gz"
colVert=1
colHoriz=3
colVal=4


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
"$script" \
    --input-file="$inFile" \
    --output-file="$outFile" \
    --vertical="$colVert" \
    --horizontal="$colHoriz" \
    --values="$colVal" \
    --input-gzipped \
    --verbose \
    &>> "$logFile"


#############
###  END  ###
#############

echo "Expression matrix written to: $outFile" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
