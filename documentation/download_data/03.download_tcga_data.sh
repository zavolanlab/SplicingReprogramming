#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 19-JUN-2017                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Downloads normal and tumor samples expression data from TCGA.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))"

# Set other parameters
prefix="http://firebrowse.org/api/v1/Analyses/mRNASeq/Quartiles"
form="tsv"
prot="RSEM"
tum="tumors"
norm="normals"
inFile="${root}/internalResources/splice_factors_of_interest.tsv"
outDir="${root}/rawData/tcga"
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

# Iterate over genes of interest
while read line; do

    # Get gene symbol
    IFS=$'\t' read -r -a gene_names <<< "$line"
    gene_print="${gene_names[0]}"
    gene_search="${gene_names[1]}"

    # Write log message
    echo "Getting expression data for gene '$gene_print'..." >> "$logFile"

    # Download expression data in normal tissue in TSV format
    outfile_n="${outDir}/expression.${prot}.${gene_print}.${norm}.${form}"
    wget --output-document "$outfile_n" "${prefix}?format=${form}&gene=${gene_search}&protocol=${prot}&sample_type=${norm}" &>> "$logFile"

    # Download expression data in tumor tissue in TSV format
    outfile_t="${outDir}/expression.${prot}.${gene_print}.${tum}.${form}"
    wget --output-document "$outfile_t" "${prefix}?format=${form}&gene=${gene_search}&protocol=${prot}&sample_type=${tum}" &>> "$logFile"

done < "$in_file"


#############
###  END  ###
#############

echo "Expression data in: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
