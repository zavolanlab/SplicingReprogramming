#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 02-NOV-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Moves Anduril output files to persistent directory and reorganizes them in directories according 
# to the following scheme:
# Anduril output file:
# <sample_id>.<main_categoy>.<sub_category_1>.<...>.<sub_category_n>
# Moved to directory:
# $targetDir/<main_category>/<sub_category_1>/<sub_category_2>/<...>/sub_category_n

####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))"

# Set other parameters
sourceDir="${root}/.tmp/align_and_quantify"
sourceGlobPattern=???
targetDir="${root}/analyzedData/align_and_quantify"
logDir="${root}/logFiles/align_and_quantify"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir -p "$targetDir"
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

# Write log
echo "Moving Anduril output files to persistent directory '$targetDir'..." >> "$logFile"

# Move output files to (persistent) target directory
for file in "${sourceDir}/"${sourceGlobPattern}"/output/"?"RP"*; do
    mv "$file" "$targetDir"
done

# Write log
echo "Reorganizing data files in destination directory..." >> "$logFile"

# Iterate over files
for file in "$targetDir/"?"RP"*; do

    # Extract target directory suffix
    suffix="$(cut --complement --fields=1 --delimiter="." <(basename "$file") | sed 's~\.~/~g')"

    # Create subdirectories
    mkdir -p "${targetDir}/${suffix}"

    # Move file
    mv "$file" "${targetDir}/${suffix}"

done


#############
###  END  ###
#############

echo "Source directory (root): $sourceDir" >> "$logFile"
echo "Destination directory (root): $targetDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
