#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 21-SEP-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Downloads raw data in SRA format.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))"

# Set other parameters
scriptDir="${root}/scriptsSoftware/sra_data"
sampleTable="${root}/internalResources/samples.tsv"
outDir="${root}/rawData"
logDir="${root}/logFiles/align_and_quantify"


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

# Download RNA-seq run data
echo "Processing sample table '$sampleTable'..." >> "$logFile"
"${scriptDir}/download_SRA_data_from_sample_table.sh" "$sampleTable" "$outDir" &>> "$logFile"


#############
###  END  ###
#############

echo "Sample table: $sampleTable" >> "$logFile"
echo "Data downloaded to: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
