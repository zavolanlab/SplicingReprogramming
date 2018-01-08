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
root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"

# Set other parameters
script_merge="${root}/scriptsSoftware/generic/merge_common_field_from_multiple_tables_by_id.R"
script_fc="${root}/scriptsSoftware/fold_changes/fold_changes_from_tables.R"
inDir="${root}/publicResources/tcga/expression"
outDir="${root}/analyzedData/fold_changes/tcga"
tmpDir="${root}/.tmp/analyzedData/fold_changes/tcga"
logDir="${root}/logFiles/analyzedData/fold_changes/tcga"
globNorm="*.normals.*"
globTum="*.tumors.*"
idPrefix="expression.RSEM."
idSuffixNorm=".normals.tsv"
idSuffixTum=".tumors.tsv"
outPrefixNorm="expression.RSEM.normals"
outPrefixTum="expression.RSEM.tumors"
outFileExt=".tsv"
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
mkdir -p "$tmpDir"
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

# Merging expression in normal tissues
echo "Merging normal expression..." >> "$logFile"
"$script_merge" \
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
"$script_merge" \
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
out_file="${outDir}/fold_changes.RSEM.tumors_over_normals.tsv"
query="${outDir}/expression.RSEM.tumors.tsv"
reference="${outDir}/expression.RSEM.normals.tsv"
"$script_fc" \
    --query="$query" \
    --reference="$reference" \
    --output-file="$out_file" \
    --in-log=2 \
    --out-log=2 \
    --transpose \
    &>> "$logFile"


#############
###  END  ###
#############

echo "Output written to: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
