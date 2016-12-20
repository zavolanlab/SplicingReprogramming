#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 08-JUN-2015                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# In-depth analysis of the CLIP results for the Cd44 locus.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"
resDir="${root}/publicResources/mmuGenomeResources"
geneResDir="${resDir}/genes"
scriptsDir="${root}/scriptsSoftware"
geneAnno="${resDir}/mmu.GRCm38_84.gene_annotations.gtf.gz"
genome="${resDir}/mmu.GRCm38_84.genome.fa.gz"
tmpDir="${root}/.tmp/publicResources/mmuGenomeResources"

########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir --parents "$tmpDir"


##############################
###  GET EXON INFORMATION  ###
##############################

### CD44 ###

# Extract unique Cd44 exon coordinates and convert them to BED format
# Exon IDs for internal use are given according to the following rules:
# - Exons are labelled with a serial number starting with the 5' most exon (i.e. 'exon_1')
# - IDs of overlapping but not identical exons are sequentially suffixed with lower case characters
#   according to how common a given exon variant is, starting with 'a' (i.e. the most common variant
#   of 'exon_1' would be labelled 'exon_1a')
# - In case of a tie, the bigger exon variant gets the smaller character (e.g. the two variants of
#   exon 3 are used in only one transcript each; the bigger of the variants would thus get the id
#   'exon_3a', while the smaller would be labelled 'exon_3b'
Cd44Dir="${geneResDir}/Cd44"; mkdir --parents "$Cd44Dir"
Cd44Exons="${Cd44Dir}/Cd44.exons.bed"
zcat "$geneAnno" | grep 'gene_id "ENSMUSG00000005087"' | awk '$3 == "exon"' | cut -f 1,4,5,7 | sort -k3,3n | sort -k2,2n --stable -u | awk 'BEGIN{OFS="\t"} {if (FNR == NR) {exonIDs[FNR]=$1} else {print $1, $2-1, $3, "Cd44_exon_"exonIDs[FNR], "0", $4}}' <(echo "19b 19d 19e 19c 19f 19a 18 17 16 15 14 13 12 11 10 9 8 7 6 5b 5a 4 3 2 1" | sed 's/ /\n/g') - > "$Cd44Exons"

# Get chromosome sizes
chrSizeTab="${tmpDir}/mmu.GRCm38_84.genome.chr_sizes.tab"
"${scriptsDir}/fasta_seq_lengths.pl" --trim <(zcat "$genome") > "$chrSizeTab"

# Get regions flanking the exons
# Exons +/- 200 nt
# Scheme:   |-200   upstream intron   -1|   exon   |+1   downstream intron   +200|
Cd44ExonsFlank200="${Cd44Dir}/Cd44.exons_flanked_200.bed"
bedtools slop -b 200 -i "$Cd44Exons" -g "$chrSizeTab" > "$Cd44ExonsFlank200"

# Upstream introns (-200nt)
# Scheme:   |-200   upstream intron   -1|
Cd44UpstreamIntrons200="${Cd44Dir}/Cd44.upstream_introns_200.bed"
bedtools flank -l 200 -r 0 -s -i "$Cd44Exons" -g "$chrSizeTab" > "$Cd44UpstreamIntrons200"

# Downstrem introns (+200nt)
# Scheme:   |+1   downstream intron   +200|
Cd44DownstreamIntrons200="${Cd44Dir}/Cd44.downstream_introns_200.bed"
bedtools flank -l 0 -r 200 -s -i "$Cd44Exons" -g "$chrSizeTab" > "$Cd44DownstreamIntrons200"
