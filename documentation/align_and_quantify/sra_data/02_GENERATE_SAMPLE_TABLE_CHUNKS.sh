#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 24-OCT-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Generates evenly sized chunks of the sample table.


####################
###  PARAMETERS  ###
####################

root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"

# Set other parameters
scriptDir="${root}/scriptsSoftware/generic"
sampleTable="${root}/internalResources/sra_data/samples.tsv"
outDir="${root}/.tmp/frameworksAuxiliary/anduril/align_and_quantify/sra_data/sample_tables"
logDir="${root}/logFiles/analyzedData/align_and_quantify/sra_data"
sampleTablePrefix="table."
sampleTableSuffix=".tsv"
sampleTableChunkSize="10"


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


############
### MAIN ###
############

# Split sample table into chunks
echo "Processing sample table '$sampleTable'..." >> "$logFile"
"${scriptDir}/split_table.sh" "$sampleTable" "$outDir" "$sampleTablePrefix" "$sampleTableSuffix" "$sampleTableChunkSize" &>> "$logFile"


#############
###  END  ###
#############

echo "Processed sample table: $sampleTable" >> "$logFile"
echo "Sample table chunks in: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
