#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 07-DEC-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Filters orthologous genes and replaces Ensembl gene IDs with merged gene symbols.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))"

# Set script path
mergeScript="${root}/scriptsSoftware/generic/merge_multiple_tables_by_id.R"

# Set input files
inputPrefixTpm="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/tpm"
inputPrefixCounts="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/counts"
inputSuffixTpm=".genes.tpm"
inputSuffixCounts=".genes.counts"

# Set output directories
outDirTpm="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/tpm"
outDirCounts="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/counts"
logDir="${root}/logFiles/analyzedData/align_and_quantify/sra_data"

# Set output filename parts
outputSuffixTpm=".orthologous_genes.tpm"
outputSuffixCounts=".orthologous_genes.counts"
mergedPrefix="all"

# Ensembl gene ID to merged gene symbols map
commonSymbols="${root}/publicResources/genome_resources/ensembl_84/orthologous_genes/ensembl_84.orthologous_genes.gene_IDs.common_gene_symbols.tsv.gz"
declare -A idCols=( [Homo_sapiens]=1 [Mus_musculus]=2 [Pan_troglodytes]=3 )
commonSymCol=7


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir -p "$outDirTpm" "$outDirCounts"
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile; "touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

## TPM

# Iterate over input files
for file in "$inputPrefixTpm/"*"$inputSuffixTpm"; do

    # Log status
    echo "TPM: Processing file '$file'..." >> "$logFile"

    # Get organism from filename
    org="$(basename "$file" "$inputSuffixTpm")"

    # Build output filename
    out_file="${outDirTpm}/${org}${outputSuffixTpm}"

    # Look up common gene symbol
    cat <(head -n 1 "$file") <(awk -v key=${idCols[$org]} -v val=$commonSymCol 'BEGIN { OFS="\t" } NR==FNR { if (a[$key] == "") { a[$key]=$val } else { a[$key]="[None]" }; next } { if ($1 in a) { if (a[$1] != "[None]" ) { $1=a[$1]; print } } }' <(zcat "$commonSymbols") <(tail -n +2 "$file") | sort -u) > "$out_file"

done

## Merge all data tables

# Build output filename
out_file="${outDirTpm}/${mergedPrefix}${outputSuffixTpm}"

# Log status
echo "TPM: Merging all data tables and writing to file '$out_file'..." >> "$logFile"

# Merge data tables
"${mergeScript}" --input-directory "$inputPrefixTpm" --output-table "$out_file" --glob "*$outputSuffixTpm" --verbose &>> "$logFile"

## COUNTS

# Iterate over input files
for file in "$inputPrefixCounts/"*"$inputSuffixCounts"; do

    # Log status
    echo "Counts: Processing file '$file'..." >> "$logFile"

    # Get organism from filename
    org="$(basename "$file" "$inputSuffixCounts")"

    # Build output filename
    out_file="${outDirCounts}/${org}${outputSuffixCounts}"

    # Look up common gene symbol
    cat <(head -n 1 "$file") <(awk -v key=${idCols[$org]} -v val=$commonSymCol 'BEGIN { OFS="\t" } NR==FNR { if (a[$key] == "") { a[$key]=$val } else { a[$key]="[None]" }; next } { if ($1 in a) { if (a[$1] != "[None]" ) { $1=a[$1]; print } } }' <(zcat "$commonSymbols") <(tail -n +2 "$file") | sort -u) > "$out_file"

done

## Merge all data tables

# Build output filename
out_file="${outDirCounts}/${mergedPrefix}${outputSuffixCounts}"

# Log status
echo "Counts: Merging all data tables and writing to file '$out_file'..." >> "$logFile"

# Merge data tables
"${mergeScript}" --input-directory "$inputPrefixCounts" --output-table "$out_file" --glob "*$outputSuffixCounts" --verbose &>> "$logFile"


#############
###  END  ###
#############

echo "TPM output written to: $outDirTpm" >> "$logFile"
echo "Count output written to: $outDirCounts" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
