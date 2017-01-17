#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 21-SEP-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Downloads raw data in SRA format given a table of study and run IDs.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"

# Set other parameters
scriptDir="${root}/scriptsSoftware/sra_data"
sampleTable="${root}/internalResources/sra_data/samples.tsv"
outDir="${root}/rawData/sra_data"
logDir="${root}/logFiles/analyzedData/align_and_quantify/sra_data"


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

echo "Processed sample table: $sampleTable" >> "$logFile"
echo "Data downloaded to: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
