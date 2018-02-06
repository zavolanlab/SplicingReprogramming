#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 20-JUN-2017                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Download gene-level RNA expression data from The Human Protein Atlas.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"

# Set other parameters
url="http://www.proteinatlas.org/download/rna_tissue.csv.zip"
outDir="${root}/rawData/thpa"
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

# Download data
outFileCSV="${outDir}/rna_expression.tissues.tpa.gene_level.csv.zip"
echo "Downloading data to file '$outFileCSV'..." >> "$logFile"
wget --output-document "$outFileCSV" "$url" 2> /dev/null >> "$logFile"

# Convert to TSV
outFileTSV="${outDir}/rna_expression.tissues.tpa.gene_level.tsv.gz"
echo "Converting to TSV file '$outFileTSV'..." >> "$logFile"
unzip -p "$outFileCSV" | sed -e 's/cervix, uterine/cervix uterine/' -e 's/"//g' -e 's/,/\t/g' | gzip > "$outFileTSV"


#############
###  END  ###
#############

echo "Expression data in: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
