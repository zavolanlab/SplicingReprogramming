#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 21-SEP-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Downloads RNA-Seq data from SRA.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))"

# Set other parameters
scriptDir="${root}/scriptsSoftware"
sampleTable="${root}/internalResources/samples.tsv"
outDir="${root}/rawData/sra"
logDir="${root}/logFiles/download_data"


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

# Replace placeholder path in sample table
sed -i "s~\[\[ROOT\]\]~$root~" "$sampleTable"

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
