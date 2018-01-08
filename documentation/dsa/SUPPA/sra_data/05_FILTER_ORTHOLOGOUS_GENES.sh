#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 17-FEB-2016                                       ###
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
inDir="${root}/analyzedData/dsa/SUPPA/sra_data/merged"
inputExperimentPrefix="by_study_and_condition"
inputSuffixDPSI="aggregated_by_gene.dpsi.tsv"
inputSuffixP="aggregated_by_gene.p.tsv"

# Set output directories
outDir="${root}/analyzedData/dsa/SUPPA/sra_data/merged/orthologous_genes"
logDir="${root}/logFiles/analyzedData/dsa/SUPPA/sra_data"

# Set output filename parts
outputSuffixDPSI="orthologous_genes.dpsi.tsv"
outputSuffixP="orthologous_genes.p.tsv"
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

## DELTA PSI

# Initialize events hash
declare -A events

# Iterate over input files
for file in "$inDir/"*".${inputExperimentPrefix}."*".$inputSuffixDPSI"; do

    # Log status
    echo "Delta PSI: Processing file '$file'..." >> "$logFile"

    # Get organism and event from filename
    org=$(echo $(basename "$file") | cut -f1 -d".")
    event=$(echo $(basename "$file") | cut -f3 -d".")

    # Add event to events hash
    events[$event]=""

    # Build output filename
    out_file="${outDir}/${org}.${inputExperimentPrefix}.${event}.${outputSuffixDPSI}"

    # Look up common gene symbol
    cat <(head -n 1 "$file") <(awk -v key=${idCols[$org]} -v val=$commonSymCol 'BEGIN { OFS="\t" } NR==FNR { if (a[$key] == "") { a[$key]=$val } else { a[$key]="[None]" }; next } { if ($1 in a) { if (a[$1] != "[None]" ) { $1=a[$1]; print } } }' <(zcat "$commonSymbols") <(tail -n +2 "$file") | sort -u) > "$out_file"

done

## Merge all data tables

# Iterate over array
for event in "${!events[@]}"; do

    # Build output filename
    out_file="${outDir}/${mergedPrefix}.${inputExperimentPrefix}.${event}.${outputSuffixDPSI}"

    # Log status
    echo "Delta PSI: Merging all data tables with event type '$event' and writing to file '$out_file'..." >> "$logFile"

    # Merge data tables
    "${mergeScript}" --input-directory "$outDir" --output-table "$out_file" --glob "*.${event}.${outputSuffixDPSI}" --all-rows --verbose &>> "$logFile"

done


## P VALUES

# Initialize events hash
declare -A events

# Iterate over input files
for file in "$inDir/"*".${inputExperimentPrefix}."*".$inputSuffixP"; do

    # Log status
    echo "P values: Processing file '$file'..." >> "$logFile"

    # Get organism from filename
    org=$(echo $(basename "$file") | cut -f1 -d".")
    event=$(echo $(basename "$file") | cut -f3 -d".")

    # Add event to events hash
    events[$event]=""

    # Build output filename
    out_file="${outDir}/${org}.${inputExperimentPrefix}.${event}.${outputSuffixP}"

    # Look up common gene symbol
    cat <(head -n 1 "$file") <(awk -v key=${idCols[$org]} -v val=$commonSymCol 'BEGIN { OFS="\t" } NR==FNR { if (a[$key] == "") { a[$key]=$val } else { a[$key]="[None]" }; next } { if ($1 in a) { if (a[$1] != "[None]" ) { $1=a[$1]; print } } }' <(zcat "$commonSymbols") <(tail -n +2 "$file") | sort -u) > "$out_file"

done

## Merge all data tables

# Iterate over array
for event in "${!events[@]}"; do

    # Build output filename
    out_file="${outDir}/${mergedPrefix}.${inputExperimentPrefix}.${event}.${outputSuffixP}"

    # Log status
    echo "P values: Merging all data tables with event type '$event' and writing to file '$out_file'..." >> "$logFile"

    # Merge data tables
    "${mergeScript}" --input-directory "$outDir" --output-table "$out_file" --glob "*.${event}.${outputSuffixP}" --all-rows --verbose &>> "$logFile"

done


#############
###  END  ###
#############

echo "Output written to: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
