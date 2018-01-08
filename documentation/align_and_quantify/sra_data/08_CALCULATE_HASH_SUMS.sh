#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 02-NOV-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Summarizes transcript abundances, alternative splicing and statistics.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"

# Set other parameters
dataRootDir="${root}/analyzedData/align_and_quantify/sra_data"
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
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############fg

# Write log
echo "Calculating md5 hash sums for subdirectories in '$dataRootDir'..." >> "$logFile"

# Save current directory
cwd="$PWD"

# Iterate over subdirectories
find "$dataRootDir" -type d | while read dir; do

    # If directory contains files
    if find "$dir" -maxdepth 1 -type f -print -quit | grep -q "."; then

        # Write log
        echo "Processing files in directory '$dir'" >> "$logFile"

        # Traverse to directory
        cd "$dir"

        # Build output filename
        outFile="$(sed -e "s~^$dataRootDir/~~" -e 's~/~.~g' <(echo $dir)).md5"

        # Calculate and write hash sums
        find . -maxdepth 1 -type f | xargs md5sum | grep -v "$outFile" | sort -k2,2 > "$outFile"

        # Write log
        echo "Checksums written to file '$dir/$outFile'." >> "$logFile"

    fi

done

# Return to original working directory
cd "$cwd"


#############
###  END  ###
#############

echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
