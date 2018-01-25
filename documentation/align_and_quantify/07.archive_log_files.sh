#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 02-NOV-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Reorganizes and archives Anduril log files.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))"

# Set other parameters
sourceDir="${root}/logFiles/align_and_quantify/anduril"
globPattern=???
tmpDir="${sourceDir}"
archive="${root}/logFiles/align_and_quantify/anduril.tgz"
logDir="${root}/logFiles/align_and_quantify"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

## Create directories
mkdir -p "$tmpDir"
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

# Write log
echo "Removing global log files..." >> "$logFile"

# Remove global log files
find "$sourceDir" -mindepth 2 -name \*"_global" -type f -delete

# Write log
echo "Moving log files to single directory '$tmpDir'..." >> "$logFile"

# Move log files to temporary directory
find "$sourceDir" -type f -exec mv {} "$tmpDir" \;

# Write log
echo "Removing empty directories..." >> "$logFile"

# Remove empty directories
find "$sourceDir" -mindepth 1 -type d -delete

# Write log
echo "Reorganizing sample table log files..." >> "$logFile"

# Move sample tables to common directory
tmpTableDir="${tmpDir}/sample_tables"; mkdir -p "$tmpTableDir"
find "$tmpDir" -maxdepth 1 -name \*"sample_table_"\* -type f -exec mv {} "$tmpTableDir" \;

# Write log
echo "Reorganzing log files into study_ID/run_ID hierarchy..." >> "$logFile"

# Iterate over log files
# TODO: abstract/generalize this
for file in "${tmpDir}/"*"_"?"RP"*"_"?"RR"*; do

    # Get study and run IDs
    study_id=$(grep -P -o "\wRP\d+" <(echo "$file") | xargs | cut -f1 -d " ")
    run_id=$(  grep -P -o "\wRR\d+" <(echo "$file") | xargs | cut -f1 -d " ")

    # Build output directory path
    tmpDirTmp="${tmpDir}/${study_id}/${run_id}"

    # Create output directory
    mkdir -p "$tmpDirTmp"

    # Move file
    mv "$file" "$tmpDirTmp"

done

# Write log
echo "Archiving log files in file '$archive'..." >> "$logFile"

# Traverse to log directory
cd "$tmpDir"

# Create archive
tar -czf "$archive" ?"RP"* "sample_tables" 2>> "$logFile"

# Remove uncompressed log files
rm -r ?"RP"* "sample_tables"

# Move back to previous location
cd -

# Try to remove temporary directory if empty
rmdir --ignore-fail-on-non-empty "$tmpDir"


#############
###  END  ###
#############

echo "Anduril log directory (root): $sourceDir" >> "$logFile"
echo "Temporary directory: $tmpDir" >> "$logFile"
echo "Target archive: $archive" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
