#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 20-JUN-2015                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Perform CLIPZ "mRNA site extraction" analysis and process results


####################
###  PARAMETERS  ###
####################

root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"
tmpDir="${root}/.tmp/analyzedData/clip_1"
analDir="${root}/analyzedData/clip_1/mRNA_site_extraction"
scriptDir="${root}/scriptsSoftware"
resDir="${root}/publicResources/mmuGenomeResources"
transcriptome="${resDir}/mmu.GRCm38_84.transcriptome.fa.gz"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir --parents "$tmpDir"
mkdir --parents "$analDir"


########################
###  PRE-PROCESSING  ###
########################

# Extract gene annotations
transcriptomeTmp="${tmpDir}/$(basename "$transcriptome" ".gz")"
gunzip --stdout "$transcriptome" | awk 'BEGIN {FS="."} {if ($1 ~ /^>/) {print $1} else {print $0}}' | "${scriptDir}/fasta_unwrap.pl" > "$transcriptomeTmp"


#######################
###  EXTRACT SITES  ###
#######################

## 13340 ##

# CLIPZ 2.0 -> "Tools" -> "mRNA site extraction"
# ----------------------------------------------
# http://www2.bc2.unibas.ch/~clipz/newClipz4/index.php?r=tools/siteExtraction/index
# * Background samples
# ID      Name
# 12739   Day5_NI
# 13060   Day4_NI
#
# * Foreground samples
# ID      Name
# 13340   Esrp2_CLIP_runs_1_2
#
# * Result files
# fg_13340_mRNA_site_extraction.tab
# fg_13340_statisticalEnrichment.png

# Sample parameters
sample="13340"
n_sites=500

# Generate sample directory
analDirSample="${analDir}/${sample}"; mkdir --parents "$analDirSample"

# Download results
wget --output-document "${analDirSample}/mRNA_site_extraction.tab" "http://users.scicore.unibas.ch/~clipz/newClipz6/public/tmp/1839229387/fg_13340_mRNA_site_extraction.tab"
wget --output-document "${analDirSample}/mRNA_site_extraction.png" "http://www2.bc2.unibas.ch/~clipz/newClipz6/public/tmp/1348361066/fg_13340_statisticalEnrichment.png"

# Convert CLIPZ site files to BED-like format
# -------------------------------------------
# - column 7: log posterior
"${scriptDir}/CLIPZ_mRNA_site_extraction_to_BED.sh" "${analDirSample}/mRNA_site_extraction.tab"

# Get top sites by fold enrichment
sort --key 5,5 --numeric-sort --reverse "${analDirSample}/mRNA_site_extraction.bed" | head -n $n_sites > "${analDirSample}/top_${n_sites}_sites.bed"

# Get sequences
bedtools getfasta -name -fi "$transcriptomeTmp" -bed "${analDirSample}/top_${n_sites}_sites.bed" -fo "${analDirSample}/top_${n_sites}_sites.fa"
