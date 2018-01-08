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
inDirRoot="${root}/analyzedData/dsa/SUPPA/sra_data"
inDirHsaEvents="${inDirRoot}/events/Homo_sapiens/by_study_and_condition"
inDirMmuEvents="${inDirRoot}/events/Mus_musculus/by_study_and_condition"
inDirPtrEvents="${inDirRoot}/events/Pan_troglodytes/by_study_and_condition"
inDirHsaIso="${inDirRoot}/isoforms/Homo_sapiens/by_study_and_condition"
inDirMmuIso="${inDirRoot}/isoforms/Mus_musculus/by_study_and_condition"
inDirPtrIso="${inDirRoot}/isoforms/Pan_troglodytes/by_study_and_condition"

# Set output directories
outDirRoot="${root}/analyzedData/dsa/SUPPA/sra_data/merged"
outDirEvents="${outDirRoot}/events"
outDirIso="${outDirRoot}/isoforms"
logDir="${root}/logFiles/analyzedData/dsa/SUPPA/sra_data"

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
inFileGlobIso="*.dpsi"
inFileSuffixIso=".dpsi"
outFileSuffix=".tsv"
idColumn=1
colDPSI=2
colP=3
prefixHsa="hsa"
prefixMmu="mmu"
prefixPtr="ptr"
prefixA3="A3"
prefixA5="A5"
prefixAF="AF"
prefixAL="AL"
prefixMX="MX"
prefixRI="RI"
prefixSE="SE"
prefixIso="ISO"
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
mkdir -p "$outDirEvents"
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
    --input-directory="$inDirHsaEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixA3}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixA3}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION: A3
echo "Summarizing event type A3 mouse comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixA3}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixA3}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION: A3
echo "Summarizing event type A3 chimpanzee comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixA3}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA3" \
    --id-suffix="$inFileSuffixA3" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixA3}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY STUDY ID AND CONDITION: A5
echo "Summarizing event type A5 human comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixA5}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixA5}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION: A5
echo "Summarizing event type A5 mouse comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixA5}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixA5}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION: A5
echo "Summarizing event type A5 chimpanzee comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixA5}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobA5" \
    --id-suffix="$inFileSuffixA5" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixA5}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY STUDY ID AND CONDITION: AF
echo "Summarizing event type AF human comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixAF}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixAF}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION: AF
echo "Summarizing event type AF mouse comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixAF}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixAF}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION: AF
echo "Summarizing event type AF chimpanzee comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixAF}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAF" \
    --id-suffix="$inFileSuffixAF" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixAF}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY STUDY ID AND CONDITION: AL
echo "Summarizing event type AL human comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixAL}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixAL}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION: AL
echo "Summarizing event type AL mouse comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixAL}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixAL}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION: AL
echo "Summarizing event type AL chimpanzee comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixAL}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobAL" \
    --id-suffix="$inFileSuffixAL" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixAL}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY STUDY ID AND CONDITION: MX
echo "Summarizing event type MX human comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixMX}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixMX}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION: MX
echo "Summarizing event type MX mouse comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixMX}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixMX}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION: MX
echo "Summarizing event type MX chimpanzee comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixMX}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobMX" \
    --id-suffix="$inFileSuffixMX" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixMX}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY STUDY ID AND CONDITION: RI
echo "Summarizing event type RI human comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixRI}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixRI}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION: RI
echo "Summarizing event type RI mouse comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixRI}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixRI}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION: RI
echo "Summarizing event type RI chimpanzee comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixRI}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobRI" \
    --id-suffix="$inFileSuffixRI" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixRI}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY STUDY ID AND CONDITION: SE
echo "Summarizing event type SE human comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixSE}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixSE}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION: SE
echo "Summarizing event type SE mouse comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixSE}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixSE}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION: SE
echo "Summarizing event type SE chimpanzee comparisons by study ID and condition..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixSE}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrEvents" \
    --recursive \
    --output-directory="$outDirEvents" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobSE" \
    --id-suffix="$inFileSuffixSE" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixSE}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY STUDY ID AND CONDITION: ISOFORMS
echo "Summarizing isoform usages for human comparisons..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaIso" \
    --recursive \
    --output-directory="$outDirIso" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobIso" \
    --id-suffix="$inFileSuffixIso" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixHsa}.${prefixIso}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirHsaIso" \
    --recursive \
    --output-directory="$outDirIso" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobIso" \
    --id-suffix="$inFileSuffixIso" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixHsa}.${prefixIso}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION: ISOFORMS
echo "Summarizing isoform usages for mouse comparisons..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuIso" \
    --recursive \
    --output-directory="$outDirIso" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobIso" \
    --id-suffix="$inFileSuffixIso" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixMmu}.${prefixIso}.${prefixDPSI}" \
    --has-header \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirMmuIso" \
    --recursive \
    --output-directory="$outDirIso" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobIso" \
    --id-suffix="$inFileSuffixIso" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixMmu}.${prefixIso}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION: ISOFORMS
echo "Summarizing isoform usages for chimpanzee comparisons..." >> "$logFile"

# Delta-PSI
echo "Extracting delta-PSI values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrIso" \
    --recursive \
    --output-directory="$outDirIso" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobIso" \
    --id-suffix="$inFileSuffixIso" \
    --id-column="$idColumn" \
    --data-column="$colDPSI" \
    --prefix-ungrouped="${prefixPtr}.${prefixIso}.${prefixDPSI}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
"$script" \
    --input-directory="$inDirPtrIso" \
    --recursive \
    --output-directory="$outDirIso" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlobIso" \
    --id-suffix="$inFileSuffixIso" \
    --id-column="$idColumn" \
    --data-column="$colP" \
    --prefix-ungrouped="${prefixPtr}.${prefixIso}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"


#############
###  END  ###
#############

echo "Output written to: $outDirEvents" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
