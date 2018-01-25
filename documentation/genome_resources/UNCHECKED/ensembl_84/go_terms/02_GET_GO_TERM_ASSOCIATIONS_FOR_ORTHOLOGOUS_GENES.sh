#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 20-DEC-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Generates gene ontology associations for orthologous genes in GAF format
# Organisms: human, monkey, chimpanzee


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))))"

# Set input files
orthGenes="${root}/publicResources/genome_resources/ensembl_84/orthologous_genes/ensembl_84.orthologous_genes.gene_IDs.common_gene_symbols.tsv.gz"

# Set output file path particles
ensemblRelease="ensembl_84"
dataType="go_terms"

# Set output directories
outDir="${root}/publicResources/genome_resources/${ensemblRelease}/${dataType}"
tmpDir="${root}/.tmp/publicResources/genome_resources/${ensemblRelease}/${dataType}"
logDir="${root}/logFiles/publicResources/genome_resources/${ensemblRelease}/${dataType}"

# Set other parameters
gaf_header='!gaf-version: 2.0'


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

# Translate gene ID to gene symbol GAF: human
echo "Processing human associations..." >> "$logFile"
gaf_hsa="${outDir}/ensembl_84.go_terms.hsa.gaf.gz"
gaf_hsa_tmp="${tmpDir}/ensembl_84.go_terms.hsa.orthologous_genes.gaf.gz"
awk 'BEGIN {FS="\t"; OFS="\t"} FNR==NR { seen[$1]=$7; next } { if ($2 in seen) { $1="Custom"; $2=seen[$2]; $3=$2; $6="Custom:"$2; split($10, desc, " \\["); $10=desc[1]; $13="taxon:9606|taxon:10090|taxon:9598"; print } }' <(zcat "$orthGenes") <(zcat "$gaf_hsa") 2>> "$logFile" | gzip > "$gaf_hsa_tmp" 2>> "$logFile"

# Translate gene ID to gene symbol GAF: mouse
echo "Processing mouse associations..." >> "$logFile"
gaf_mmu="${outDir}/ensembl_84.go_terms.mmu.gaf.gz"
gaf_mmu_tmp="${tmpDir}/ensembl_84.go_terms.mmu.orthologous_genes.gaf.gz"
awk 'BEGIN {FS="\t"; OFS="\t"} FNR==NR { seen[$2]=$7; next } { if ($2 in seen) { $1="Custom"; $2=seen[$2]; $3=$2; $6="Custom:"$2; split($10, desc, " \\["); $10=desc[1]; $13="taxon:9606|taxon:10090|taxon:9598"; print } }' <(zcat "$orthGenes") <(zcat "$gaf_mmu") 2>> "$logFile" | gzip > "$gaf_mmu_tmp" 2>> "$logFile"

# Translate gene ID to gene symbol GAF: chimpanzee
echo "Processing chimpanzee associations..." >> "$logFile"
gaf_ptr="${outDir}/ensembl_84.go_terms.ptr.gaf.gz"
gaf_ptr_tmp="${tmpDir}/ensembl_84.go_terms.ptr.orthologous_genes.gaf.gz"
awk 'BEGIN {FS="\t"; OFS="\t"} FNR==NR { seen[$3]=$7; next } { if ($2 in seen) { $1="Custom"; $2=seen[$2]; $3=$2; $6="Custom:"$2; split($10, desc, " \\["); $10=desc[1]; $13="taxon:9606|taxon:10090|taxon:9598"; print } }' <(zcat "$orthGenes") <(zcat "$gaf_ptr") 2>> "$logFile" | gzip > "$gaf_ptr_tmp" 2>> "$logFile"

# Compile unique set of associations from all organisms
echo "Compiling unique set of associations..." >> "$logFile"
gaf_all="${outDir}/ensembl_84.go_terms.all.orthologous_genes.gaf.gz"
cat <(echo "$gaf_header") <(zcat "$gaf_hsa_tmp" "$gaf_mmu_tmp" "$gaf_ptr_tmp") | uniq | sort -t $'\t' -k5,5 | gzip > "$gaf_all"


#############
###  END  ###
#############

echo "Gene ontology associations for orthologous genes stored in: $gaf_all" >> "$logFile"
echo "Temporary data stored in: $tmpDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
