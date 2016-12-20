#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 20-JUN-2015                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Perform MEME motif analysis on CLIPZ sites.


####################
###  PARAMETERS  ###
####################

root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"
sample="${root}/analyzedData/clip_1/mRNA_site_extraction/13340/top_2000_sites.fa"
outDir="${root}/analyzedData/clip_1/MEME"
MEME_maxsize_cluster=100
MEME_minsites_fract=0.5
MEME_mod="zoops"
MEME_nmotifs=5
MEME_minw=6
MEME_maxw=8


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir --parents "$outDir"


#####################
###  FIND MOTIFS  ###
#####################

## 13340 ##

# Calculate missing MEME parameters
MEME_sites=$(grep -c "^>" "$sample")
MEME_maxsize=$(($MEME_sites * $MEME_maxsize_cluster))
MEME_minsites=$(perl -e "use POSIX; print ceil($MEME_sites * $MEME_minsites_fract)")
MEME_oc="${outDir}/$(basename ${sample%.*}).dna.maxsize_${MEME_maxsize}.mod_${MEME_mod}.nmotifs_${MEME_nmotifs}.minw_${MEME_minw}.maxw_${MEME_maxw}.minsites_${MEME_minsites}"

# Run MEME
meme "$sample" -dna -maxsize $MEME_maxsize -mod "$MEME_mod" -nmotifs $MEME_nmotifs -minw $MEME_minw -maxw $MEME_maxw -minsites $MEME_minsites -oc "$MEME_oc"
