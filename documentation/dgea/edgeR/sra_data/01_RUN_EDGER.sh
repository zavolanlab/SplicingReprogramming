#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 19-DEC-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Runs differential gene expression analysis with edgeR.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))))"

# Set script path
script="${root}/scriptsSoftware/dgea/dgea_edgeR.R"

# Set input files
counts_hsa="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/counts/Homo_sapiens.genes.counts"
counts_mmu="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/counts/Mus_musculus.genes.counts"
counts_ptr="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/counts/Pan_troglodytes.genes.counts"
sample_annotations="${root}/internalResources/sra_data/samples.annotations.tsv"
sample_contrasts="${root}/internalResources/sra_data/samples.contrasts.tsv"

# Set output directories
outDir="${root}/analyzedData/dgea/edgeR/sra_data"
tmpDir="${root}/.tmp/analyzedData/dgea/edgeR/sra_data"
logDir="${root}/logFiles/analyzedData/dgea/edgeR/sra_data"

# Set temporary files
contrasts_hsa="${tmpDir}/contrasts.hsa"
contrasts_mmu="${tmpDir}/contrasts.mmu"
contrasts_ptr="${tmpDir}/contrasts.ptr"

# Set other script parameters
prefix_hsa="Homo_sapiens"
prefix_mmu="Mus_musculus"
prefix_ptr="Pan_troglodytes"


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
rm -f "$logFile; "touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

# Filter sample contrasts for each organism
echo "Filtering samples contrasts..." >> "$logFile"
cat <(head -n 1 "$sample_contrasts") <(awk '$2 == "Homo_sapiens"' "$sample_contrasts") > "$contrasts_hsa" 2>> "$logFile"
cat <(head -n 1 "$sample_contrasts") <(awk '$2 == "Mus_musculus"' "$sample_contrasts") > "$contrasts_mmu" 2>> "$logFile"
cat <(head -n 1 "$sample_contrasts") <(awk '$2 == "Pan_troglodytes"' "$sample_contrasts") > "$contrasts_ptr" 2>> "$logFile"

# Run differential gene expression analysis with edgeR
echo "Running differential gene expression analyses with 'edgeR'..." >> "$logFile"
Rscript "$script" "$prefix_hsa" "$counts_hsa" "$sample_annotations" "$contrasts_hsa" "$outDir" &>> "$logFile"
Rscript "$script" "$prefix_mmu" "$counts_mmu" "$sample_annotations" "$contrasts_mmu" "$outDir" &>> "$logFile"
Rscript "$script" "$prefix_ptr" "$counts_ptr" "$sample_annotations" "$contrasts_ptr" "$outDir" &>> "$logFile"


#############
###  END  ###
#############

echo "Output written to: $outDir" >> "$logFile"
echo "Temporary files written to: $tmpDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
