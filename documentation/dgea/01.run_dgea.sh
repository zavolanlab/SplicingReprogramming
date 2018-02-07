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
root="$(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))"

# Set script path
scriptDir="${root}/scriptsSoftware"

# Set input files
anno="${root}/internalResources/sra_data/samples.annotations.tsv"
comp="${root}/internalResources/sra_data/samples.comparisons.alt.tsv"
cntsHsa="${root}/analyzedData/summarized_data/sra/merged/abundances/counts/Homo_sapiens.genes.counts"
cntsMmu="${root}/analyzedData/summarized_data/sra/merged/abundances/counts/Mus_musculus.genes.counts"
cntsPtr="${root}/analyzedData/summarized_data/sra/merged/abundances/counts/Pan_troglodytes.genes.counts"

# Set output directories
outDirRoot="${root}/analyzedData/dgea"
outDirHsa="${outDirRoot}/hsa"
outDirMmu="${outDirRoot}/mmu"
outDirPtr="${outDirRoot}/ptr"
tmpDir="${root}/.tmp/dgea"
logDir="${root}/logFiles/dgea"

# Set temporary files
annoHsa="${tmpDir}/annotations.hsa.by_study_and_condition"
annoMmu="${tmpDir}/annotations.mmu.by_study_and_condition"
annoPtr="${tmpDir}/annotations.ptr.by_study_and_condition"
compHsa="${tmpDir}/comparisons.hsa.by_study_and_condition"
compMmu="${tmpDir}/comparisons.mmu.by_study_and_condition"
compPtr="${tmpDir}/comparisons.ptr.by_study_and_condition"

# Set other script parameters
runIdHsa="hsa"
runIdMmu="mmu"
runIdPtr="ptr"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir -p "$outDirRoot"
mkdir -p "$outDirHsa" "$outDirMmu" "$outDirPtr"
mkdir -p "$tmpDir"
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

# Prepare sample annotations for each condition
echo "Preparing sample annotations..." >> "$logFile"
awk 'BEGIN{OFS="\t"} $4 == "Homo_sapiens" {print $1, $2"."$4"."$6}' "$anno" > "$annoHsa" 2>> "$logFile"
awk 'BEGIN{OFS="\t"} $4 == "Mus_musculus" {print $1, $2"."$4"."$6}' "$anno" > "$annoMmu" 2>> "$logFile"
awk 'BEGIN{OFS="\t"} $4 == "Pan_troglodytes" {print $1, $2"."$4"."$6}' "$anno" > "$annoPtr" 2>> "$logFile"

# Prepare sample contrasts for each condition
echo "Preparing sample comparisons..." >> "$logFile"
awk '$5 == "Homo_sapiens"' "$comp" > "$compHsa" 2>> "$logFile"
awk '$5 == "Mus_musculus"' "$comp" > "$compMmu" 2>> "$logFile"
awk '$5 == "Pan_troglodytes"' "$comp" > "$compPtr" 2>> "$logFile"

# Human
echo "Comparing gene expression across relevant conditions per study: human..." >> "$logFile"
Rscript "${scriptDir}/dgea_edgeR.R" \
    --count-table="$cntsHsa" \
    --output-directory="$outDirHsa" \
    --run-id="$runIdHsa" \
    --annotation="$annoHsa" \
    --comparisons="$compHsa" \
    --reference-column=2 \
    --query-column=1 \
    --comparison-name-column=3 \
    --verbose &>> "$logFile"

# Mouse
echo "Comparing gene expression across relevant conditions per study: mouse..." >> "$logFile"
Rscript "${scriptDir}/dgea_edgeR.R" \
    --count-table="$cntsMmu" \
    --output-directory="$outDirMmu" \
    --run-id="$runIdMmu" \
    --annotation="$annoMmu" \
    --comparisons="$compMmu" \
    --reference-column=2 \
    --query-column=1 \
    --comparison-name-column=3 \
    --verbose &>> "$logFile"

# Chimpanzee
echo "Comparing gene expression across relevant conditions per study: chimpanzee..." >> "$logFile"
Rscript "${scriptDir}/dgea_edgeR.R" \
    --count-table="$cntsPtr" \
    --output-directory="$outDirPtr" \
    --run-id="$runIdPtr" \
    --annotation="$annoPtr" \
    --comparisons="$compPtr" \
    --reference-column=2 \
    --query-column=1 \
    --comparison-name-column=3 \
    --verbose &>> "$logFile"


#############
###  END  ###
#############

echo "Output written to: $outDirRoot" >> "$logFile"
echo "Temporary files written to: $tmpDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
