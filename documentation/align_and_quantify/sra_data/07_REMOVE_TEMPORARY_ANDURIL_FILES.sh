#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 02-NOV-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Deletes intermediate/temporary Anduril data files.
# WARNING: DO ONLY EXECUTE THIS SCRIPT WHEN YOU HAVE VERIFIED THAT ANDURIL FINISHED WITHOUT ERRORS 
# FOR ALL FILES, ALL REQUIRED DATA WERE MOVED TO A PERSISTENT DIRECTORY AND THE TEMPORARY DATA 
# DIRECTORY DOES NOT CONTAIN ANY MORE IMPORTANT FILES!


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"

# Set other parameters
tmpDataDir="${root}/.tmp/analyzedData/align_and_quantify/sra_data"
logDir="${root}/logFiles/analyzedData/align_and_quantify/sra_data"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile; "touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

# Write log
echo "Deleting Anduril data in temporary directory '$tmpDataDir'..." >> "$logFile"

# Move output files to (persistent) target directory
rm -r "${tmpDataDir}/"*


#############
###  END  ###
#############

echo "Cleaned directory: $tmpDataDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
