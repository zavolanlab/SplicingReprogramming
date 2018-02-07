#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 19-JUN-2017                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Downloads normal and tumor samples expression data from TCGA.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))"

# Set other parameters
scriptDir="${root}/scriptsSoftware"
inDir="${root}/rawData/tcga"
outDir="${root}/analyzedData/data_matrices/tcga"
outFileMerge="${outDir}/fold_changes.RSEM.tumors_over_normals.tsv"
logDir="${root}/logFiles/summarize_data"
globNorm="*.normals.*"
globTum="*.tumors.*"
idPrefix="expression.RSEM."
idSuffixNorm=".normals.tsv"
idSuffixTum=".tumors.tsv"
outPrefixNorm="expression.RSEM.normals"
outPrefixTum="expression.RSEM.tumors"
outFileExt=".tsv"
base_in=2
base_out=2
idCol=1
datCol=4


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

# Delete empty files
find "$inDir" -size 0 -delete

# Merging expression in normal tissues
echo "Merging normal expression..." >> "$logFile"
"${scriptDir}/merge_common_field_from_multiple_tables_by_id.R" \
    --input-directory="$inDir" \
    --output-directory="$outDir" \
    --glob="$globNorm" \
    --id-prefix="$idPrefix" \
    --id-suffix="$idSuffixNorm" \
    --prefix-ungrouped="$outPrefixNorm" \
    --out-file-suffix="$outFileExt" \
    --id-column=$idCol \
    --data-column=$datCol \
    --has-header \
    &>> "$logFile"

# Mergin expression in tumor tissues
echo "Merging tumor expression..." >> "$logFile"
"${scriptDir}/merge_common_field_from_multiple_tables_by_id.R" \
    --input-directory="$inDir" \
    --output-directory="$outDir" \
    --glob="$globTum" \
    --id-prefix="$idPrefix" \
    --id-suffix="$idSuffixTum" \
    --prefix-ungrouped="$outPrefixTum" \
    --out-file-suffix="$outFileExt" \
    --id-column=$idCol \
    --data-column=$datCol \
    --has-header \
    &>> "$logFile"

# Merging both
query="${outDir}/expression.RSEM.tumors.tsv"
reference="${outDir}/expression.RSEM.normals.tsv"
"${scriptDir}/fold_changes_from_tables.R" \
    --query="$query" \
    --reference="$reference" \
    --output-file="$outFileMerge" \
    --in-log=$base_in \
    --out-log=$base_out \
    --transpose \
    &>> "$logFile"


#############
###  END  ###
#############

echo "Output written to: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
