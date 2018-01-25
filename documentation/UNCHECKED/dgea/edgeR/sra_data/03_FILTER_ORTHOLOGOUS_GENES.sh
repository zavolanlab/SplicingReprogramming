#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 27-JAN-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Filters orthologous genes and replaces Ensembl gene IDs with merged gene symbols.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))))"

# Set script path
mergeScript="${root}/scriptsSoftware/generic/merge_multiple_tables_by_id.R"

# Set input files
inDir="${root}/analyzedData/dgea/edgeR/sra_data/merged"
inputSuffixDe=".by_study_and_condition.de.tsv"
inputSuffixFc=".by_study_and_condition.fc.tsv"
inputSuffixFdr=".by_study_and_condition.fdr.tsv"
inputSuffixP=".by_study_and_condition.p.tsv"

# Set output directories
outDir="${root}/analyzedData/dgea/edgeR/sra_data/merged/orthologous_genes"
logDir="${root}/logFiles/analyzedData/dgea/edgeR/sra_data"

# Set output filename parts
outputSuffixDe=".by_study_and_condition.orthologous_genes.de.tsv"
outputSuffixFc=".by_study_and_condition.orthologous_genes.fc.tsv"
outputSuffixFdr=".by_study_and_condition.orthologous_genes.fdr.tsv"
outputSuffixP=".by_study_and_condition.orthologous_genes.p.tsv"
mergedPrefix="merged"

# Ensembl gene ID to merged gene symbols map
commonSymbols="${root}/publicResources/genome_resources/ensembl_84/orthologous_genes/ensembl_84.orthologous_genes.gene_IDs.common_gene_symbols.tsv.gz"
declare -A idCols=( [hsa]=1 [mmu]=2 [ptr]=3 )
commonSymCol=7


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
rm -f "$logFile; "touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

## DIFFERENTIAL EXPRESSION FLAG

# Iterate over input files
for file in "$inDir/"*"$inputSuffixDe"; do

    # Log status
    echo "Differential expression flag: Processing file '$file'..." >> "$logFile"

    # Get organism from filename
    org="$(basename "$file" "$inputSuffixDe")"

    # Build output filename
    out_file="${outDir}/${org}${outputSuffixDe}"

    # Look up common gene symbol
    cat <(head -n 1 "$file") <(awk -v key=${idCols[$org]} -v val=$commonSymCol 'BEGIN { OFS="\t" } NR==FNR { if (a[$key] == "") { a[$key]=$val } else { a[$key]="[None]" }; next } { if ($1 in a) { if (a[$1] != "[None]" ) { $1=a[$1]; print } } }' <(zcat "$commonSymbols") <(tail -n +2 "$file") | sort -u) > "$out_file"

done

## Merge all data tables

# Build output filename
out_file="${outDir}/${mergedPrefix}${outputSuffixDe}"

# Log status
echo "Differential expression flag: Merging all data tables and writing to file '$out_file'..." >> "$logFile"

# Merge data tables
"${mergeScript}" --input-directory "$outDir" --output-table "$out_file" --glob "*$outputSuffixDe" --verbose &>> "$logFile"


## FOLD CHANGES

# Iterate over input files
for file in "$inDir/"*"$inputSuffixFc"; do

    # Log status
    echo "Fold changes: Processing file '$file'..." >> "$logFile"

    # Get organism from filename
    org="$(basename "$file" "$inputSuffixFc")"

    # Build output filename
    out_file="${outDir}/${org}${outputSuffixFc}"

    # Look up common gene symbol
    cat <(head -n 1 "$file") <(awk -v key=${idCols[$org]} -v val=$commonSymCol 'BEGIN { OFS="\t" } NR==FNR { if (a[$key] == "") { a[$key]=$val } else { a[$key]="[None]" }; next } { if ($1 in a) { if (a[$1] != "[None]" ) { $1=a[$1]; print } } }' <(zcat "$commonSymbols") <(tail -n +2 "$file") | sort -u) > "$out_file"

done

## Merge all data tables

# Build output filename
out_file="${outDir}/${mergedPrefix}${outputSuffixFc}"

# Log status
echo "Fold changes: Merging all data tables and writing to file '$out_file'..." >> "$logFile"

# Merge data tables
"${mergeScript}" --input-directory "$outDir" --output-table "$out_file" --glob "*$outputSuffixFc" --verbose &>> "$logFile"


## FALSE DISCOVERY RATES

# Iterate over input files
for file in "$inDir/"*"$inputSuffixFdr"; do

    # Log status
    echo "False discovery rates: Processing file '$file'..." >> "$logFile"

    # Get organism from filename
    org="$(basename "$file" "$inputSuffixFdr")"

    # Build output filename
    out_file="${outDir}/${org}${outputSuffixFdr}"

    # Look up common gene symbol
    cat <(head -n 1 "$file") <(awk -v key=${idCols[$org]} -v val=$commonSymCol 'BEGIN { OFS="\t" } NR==FNR { if (a[$key] == "") { a[$key]=$val } else { a[$key]="[None]" }; next } { if ($1 in a) { if (a[$1] != "[None]" ) { $1=a[$1]; print } } }' <(zcat "$commonSymbols") <(tail -n +2 "$file") | sort -u) > "$out_file"

done

## Merge all data tables

# Build output filename
out_file="${outDir}/${mergedPrefix}${outputSuffixFdr}"

# Log status
echo "False discovery rates: Merging all data tables and writing to file '$out_file'..." >> "$logFile"

# Merge data tables
"${mergeScript}" --input-directory "$outDir" --output-table "$out_file" --glob "*$outputSuffixFdr" --verbose &>> "$logFile"


## P VALUES

# Iterate over input files
for file in "$inDir/"*"$inputSuffixP"; do

    # Log status
    echo "P values: Processing file '$file'..." >> "$logFile"

    # Get organism from filename
    org="$(basename "$file" "$inputSuffixP")"

    # Build output filename
    out_file="${outDir}/${org}${outputSuffixP}"

    # Look up common gene symbol
    cat <(head -n 1 "$file") <(awk -v key=${idCols[$org]} -v val=$commonSymCol 'BEGIN { OFS="\t" } NR==FNR { if (a[$key] == "") { a[$key]=$val } else { a[$key]="[None]" }; next } { if ($1 in a) { if (a[$1] != "[None]" ) { $1=a[$1]; print } } }' <(zcat "$commonSymbols") <(tail -n +2 "$file") | sort -u) > "$out_file"

done

## Merge all data tables

# Build output filename
out_file="${outDir}/${mergedPrefix}${outputSuffixP}"

# Log status
echo "P values: Merging all data tables and writing to file '$out_file'..." >> "$logFile"

# Merge data tables
"${mergeScript}" --input-directory "$outDir" --output-table "$out_file" --glob "*$outputSuffixP" --verbose &>> "$logFile"


#############
###  END  ###
#############

echo "Output written to: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
