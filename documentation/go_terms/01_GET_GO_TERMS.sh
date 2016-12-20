#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 06-DEC-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Get list of relevant GO terms


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))"

# Set output directories
outDir="${root}/publicResources/go_terms"
tmpDir="${root}/.tmp/publicResources/go_terms"
logDir="${root}/logFiles/publicResources/go_terms"

# Set other parameters
# TODO


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir --parents "$outDir"
mkdir --parents "$tmpDir"
mkdir --parents "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

# Compile list of relevant GO terms
outFile="${outDir}/go_terms"
echo "Compiling list of relevant GO terms..." >> "$logFile"
cat > "$outFile" <<- EOF
GO:0010467
GO:0010468
GO:0006396
GO:0008380
GO:0043484
GO:0006397
GO:0050684
GO:0000398
GO:0048024
GO:0003723
GO:1905214
GO:0003729
GO:1902415
GO:0003730
GO:1903837
EOF


#############
###  END  ###
#############

echo "Relevant GO terms: $outFile" >> "$logFile"
echo "Temporary data stored in: $tmpDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
