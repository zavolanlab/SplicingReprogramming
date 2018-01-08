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
script="${root}/scriptsSoftware/generic/merge_common_field_from_multiple_tables_by_id.R"

# Set input files
inDirRoot="${root}/analyzedData/dsa/SUPPA/own_data"
inDirHsaByStudy="${inDirRoot}/Homo_sapiens/by_study_and_condition"
inDirMmuByStudy="${inDirRoot}/Mus_musculus/by_study_and_condition"
inDirPtrByStudy="${inDirRoot}/Pan_troglodytes/by_study_and_condition"
inDirHsaByCellType="${inDirRoot}/Homo_sapiens/by_cell_type_only"
inDirMmuByCellType="${inDirRoot}/Mus_musculus/by_cell_type_only"
inDirPtrByCellType="${inDirRoot}/Pan_troglodytes/by_cell_type_only"

# Set output directories
outDir="${root}/analyzedData/dsa/SUPPA/own_data/merged"
logDir="${root}/logFiles/analyzedData/dsa/SUPPA/own_data"

# Set other script parameters
inFileGlobA3="*.A3.dpsi"
inFileSuffixA3=".A3.dpsi"
inFileGlobA5="*.A5.dpsi"
inFileSuffixA5=".A5.dpsi"
inFileGlobAF="*.AF.dpsi"
inFileSuffixAF=".AF.dpsi"
inFileGlobAL="*.AL.dpsi"
inFileSuffixAL=".AL.dpsi"
inFileGlobMX="*.MX.dpsi"
inFileSuffixMX=".MX.dpsi"
inFileGlobRI="*.RI.dpsi"
inFileSuffixRI=".RI.dpsi"
inFileGlobSE="*.SE.dpsi"
inFileSuffixSE=".SE.dpsi"
outFileSuffix=".tsv"
idColumn=1
colDPSI=2
colP=3
prefixHsa="hsa"
prefixMmu="mmu"
prefixPtr="ptr"
prefixByStudy="by_study_and_condition"
prefixByCellType="by_cell_type_only"
prefixA3="A3"
prefixA5="A5"
prefixAF="AF"
prefixAL="AL"
prefixMX="MX"
prefixRI="RI"
prefixSE="SE"
prefixDPSI="dpsi"
prefixP="p"


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

## HUMAN: BY STUDY ID AND CONDITION: A3
echo "Summarizing event type A3 human comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixA3}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixA3}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION: A3
echo "Summarizing event type A3 mouse comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixA3}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixA3}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION: A3
echo "Summarizing event type A3 chimpanzee comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixA3}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixA3}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY CELL TYPE: A3
echo "Summarizing event type A3 human comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixA3}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixA3}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY CELL TYPE: A3
echo "Summarizing event type A3 mouse comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixA3}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixA3}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY CELL TYPE: A3
echo "Summarizing event type A3 chimpanzee comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixA3}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixA3}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY STUDY ID AND CONDITION: A5
echo "Summarizing event type A5 human comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixA5}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixA5}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION: A5
echo "Summarizing event type A5 mouse comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixA5}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixA5}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION: A5
echo "Summarizing event type A5 chimpanzee comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixA5}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixA5}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY CELL TYPE: A5
echo "Summarizing event type A5 human comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixA5}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixA5}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY CELL TYPE: A5
echo "Summarizing event type A5 mouse comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixA5}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixA5}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY CELL TYPE: A5
echo "Summarizing event type A5 chimpanzee comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixA5}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixA5}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY STUDY ID AND CONDITION: AF
echo "Summarizing event type AF human comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixAF}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixAF}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION: AF
echo "Summarizing event type AF mouse comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixAF}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixAF}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION: AF
echo "Summarizing event type AF chimpanzee comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixAF}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixAF}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY CELL TYPE: AF
echo "Summarizing event type AF human comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixAF}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixAF}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY CELL TYPE: AF
echo "Summarizing event type AF mouse comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixAF}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixAF}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY CELL TYPE: AF
echo "Summarizing event type AF chimpanzee comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixAF}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixAF}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY STUDY ID AND CONDITION: AL
echo "Summarizing event type AL human comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixAL}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixAL}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION: AL
echo "Summarizing event type AL mouse comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixAL}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixAL}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION: AL
echo "Summarizing event type AL chimpanzee comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixAL}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixAL}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY CELL TYPE: AL
echo "Summarizing event type AL human comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixAL}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixAL}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY CELL TYPE: AL
echo "Summarizing event type AL mouse comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixAL}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixAL}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY CELL TYPE: AL
echo "Summarizing event type AL chimpanzee comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixAL}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixAL}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY STUDY ID AND CONDITION: MX
echo "Summarizing event type MX human comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixMX}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixMX}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION: MX
echo "Summarizing event type MX mouse comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixMX}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixMX}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION: MX
echo "Summarizing event type MX chimpanzee comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixMX}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixMX}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY CELL TYPE: MX
echo "Summarizing event type MX human comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixMX}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixMX}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY CELL TYPE: MX
echo "Summarizing event type MX mouse comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixMX}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixMX}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY CELL TYPE: MX
echo "Summarizing event type MX chimpanzee comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixMX}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixMX}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY STUDY ID AND CONDITION: RI
echo "Summarizing event type RI human comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixRI}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixRI}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION: RI
echo "Summarizing event type RI mouse comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixRI}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixRI}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION: RI
echo "Summarizing event type RI chimpanzee comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixRI}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixRI}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY CELL TYPE: RI
echo "Summarizing event type RI human comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixRI}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixRI}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY CELL TYPE: RI
echo "Summarizing event type RI mouse comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixRI}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixRI}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY CELL TYPE: RI
echo "Summarizing event type RI chimpanzee comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixRI}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixRI}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY STUDY ID AND CONDITION: SE
echo "Summarizing event type SE human comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixSE}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixSE}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION: SE
echo "Summarizing event type SE mouse comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixSE}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixSE}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION: SE
echo "Summarizing event type SE chimpanzee comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixSE}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixSE}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY CELL TYPE: SE
echo "Summarizing event type SE human comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixSE}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixSE}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY CELL TYPE: SE
echo "Summarizing event type SE mouse comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixSE}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixSE}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY CELL TYPE: SE
echo "Summarizing event type SE chimpanzee comparisons by cell type..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixSE}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixSE}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


#############
###  END  ###
#############

echo "Output written to: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
