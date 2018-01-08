#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 05-JAN-2017                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Summarize, calculate and/or process "align and quantify" pipeline statistics and compile list of
# samples not meeting quality requirements.

# Note that QC thresholds are defined in the individual processing scripts.

####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"

# Set base directories
scriptDir="${root}/scriptsSoftware/align_and_quantify"
dataDir="${root}/analyzedData/align_and_quantify/own_data/merged"
outDir="${root}/analyzedData/align_and_quantify/own_data/stats"
logDir="${root}/logFiles/analyzedData/align_and_quantify/own_data"

# Set scripts
scriptPolyA="${scriptDir}/process_stats.polyA_removal.R"
scriptAlign="${scriptDir}/process_stats.alignments.own_data.R"

# Set input files
inFilePolyA="${dataDir}/processing/polyA_removal/stats/processing.polyA_removal.stats"
inFileAlign="${dataDir}/alignments/stats/alignments.stats"

# Set output directories and prefixes
outDirPolyA="${outDir}/polyA_removal"
outDirAlign="${outDir}/alignments"
prefixPolyA="polyA_removal"
prefixAlign="alignments"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir -p "$outDir"
mkdir -p "$outDirPolyA" "$outDirAlign"
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

# Calculate/process polyA removal stats
# Set quality control thresholds manually in "$scriptPolyA"
echo "Processing polyA removal statistics..." >> "$logFile"
Rscript "$scriptPolyA" "$inFilePolyA" "$outDirPolyA" "$prefixPolyA" &>> "$logFile"

# Calculate/process alignments stats
# Set quality control thresholds manually in "$scriptAlign"
echo "Processing alignment statistics..." >> "$logFile"
Rscript "$scriptAlign" "$inFileAlign" "$outDirAlign" "$prefixAlign" &>> "$logFile"

# Compile list of samples to filter out
echo "Compiling list of samples not meeting quality control requirements..." >> "$logFile"
filter_polyA="${outDirPolyA}/${prefixPolyA}.samples_to_filter"
filter_align="${outDirAlign}/${prefixAlign}.samples_to_filter"
filter_all="${outDir}/samples_to_filter"
cat <(tail -n +2 "$filter_polyA" | cut -f 1) <(tail -n +2 "$filter_align" | cut -f 1) | sort -u > "$filter_all"


#############
###  END  ###
#############

echo "Poly(A) tail removal statistics plots created in: $outDirPolyA" >> "$logFile"
echo "Alignment statistics plots created in: $outDirAlign" >> "$logFile"
echo "IDs of samples that failed quality control written to: $filter_all" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
