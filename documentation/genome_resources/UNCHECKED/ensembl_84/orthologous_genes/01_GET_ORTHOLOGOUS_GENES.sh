#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 30-NOV-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Obtains and processes IDs of orthologous sets of genes
# Organisms: human, monkey, chimpanzee


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))))"

# Set output file path particles
ensemblRelease="ensembl_84"
dataType="orthologous_genes"
orgHsa="hsa"
orgMmu="mmu"
orgPtr="ptr"
prefixHM="hsa_mmu_only"

# Set output directories
outDir="${root}/publicResources/genome_resources/${ensemblRelease}/${dataType}"
tmpDir="${root}/.tmp/publicResources/genome_resources/${ensemblRelease}/${dataType}"
logDir="${root}/logFiles/publicResources/genome_resources/${ensemblRelease}/${dataType}"

# Set output prefixes
outPrefixHsa="${outDir}/${ensemblRelease}.${dataType}.${orgHsa}"
outPrefixMmu="${outDir}/${ensemblRelease}.${dataType}.${orgMmu}"
outPrefixPtr="${outDir}/${ensemblRelease}.${dataType}.${orgPtr}"
outPrefixAll="${outDir}/${ensemblRelease}.${dataType}"


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

## DOWNLOAD ORTHOLOGOUS GENES FROM BIOMART

# Human gene IDs as reference
echo "Downloading corresponding gene IDs for human genes..." >> "$logFile"
outfile_hsa="${outPrefixHsa}.tsv.gz"
url='http://mar2016.archive.ensembl.org/biomart/martservice?query=<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE Query><Query  virtualSchemaName = "default" formatter = "TSV" header = "0" uniqueRows = "0" count = "" datasetConfigVersion = "0.6" completionStamp = "1" ><Dataset name = "hsapiens_gene_ensembl" interface = "default" ><Attribute name = "ensembl_gene_id" /><Attribute name = "mmusculus_homolog_ensembl_gene" /><Attribute name = "ptroglodytes_homolog_ensembl_gene" /></Dataset></Query>'
wget -qO- "$url" | sort | gzip > "$outfile_hsa"

# Mouse gene IDs as reference
echo "Downloading corresponding gene IDs for mouse genes..." >> "$logFile"
outfile_mmu="${outPrefixMmu}.tsv.gz"
url='http://mar2016.archive.ensembl.org/biomart/martservice?query=<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE Query><Query  virtualSchemaName = "default" formatter = "TSV" header = "0" uniqueRows = "0" count = "" datasetConfigVersion = "0.6" completionStamp = "1" ><Dataset name = "mmusculus_gene_ensembl" interface = "default" ><Attribute name = "ensembl_gene_id" /><Attribute name = "hsapiens_homolog_ensembl_gene" /><Attribute name = "ptroglodytes_homolog_ensembl_gene" /></Dataset></Query>'
wget -qO- "$url" | sort | gzip > "$outfile_mmu"

# Chimpanzee gene IDs as reference
echo "Downloading corresponding gene IDs for chimpanzee genes..." >> "$logFile"
outfile_ptr="${outPrefixPtr}.tsv.gz"
url='http://mar2016.archive.ensembl.org/biomart/martservice?query=<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE Query><Query  virtualSchemaName = "default" formatter = "TSV" header = "0" uniqueRows = "0" count = "" datasetConfigVersion = "0.6" completionStamp = "1" ><Dataset name = "ptroglodytes_gene_ensembl" interface = "default" ><Attribute name = "ensembl_gene_id" /><Attribute name = "hsapiens_homolog_ensembl_gene" /><Attribute name = "mmusculus_homolog_ensembl_gene" /></Dataset></Query>'
wget -qO- "$url" | sort | gzip > "$outfile_ptr"

# Human gene IDs as reference; human & mouse only
echo "Downloading corresponding mouse gene IDs for human genes..." >> "$logFile"
outfile_hsa_HM="${outPrefixHsa}.${prefixHM}.tsv.gz"
url='http://mar2016.archive.ensembl.org/biomart/martservice?query=<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE Query><Query  virtualSchemaName = "default" formatter = "TSV" header = "0" uniqueRows = "0" count = "" datasetConfigVersion = "0.6" completionStamp = "1" ><Dataset name = "hsapiens_gene_ensembl" interface = "default" ><Attribute name = "ensembl_gene_id" /><Attribute name = "mmusculus_homolog_ensembl_gene" /></Dataset></Query>'
wget -qO- "$url" | sort | gzip > "$outfile_hsa_HM"

# Mouse gene IDs as reference; human & mouse only
echo "Downloading corresponding human gene IDs for mouse genes..." >> "$logFile"
outfile_mmu_HM="${outPrefixMmu}.${prefixHM}.tsv.gz"
url='http://mar2016.archive.ensembl.org/biomart/martservice?query=<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE Query><Query  virtualSchemaName = "default" formatter = "TSV" header = "0" uniqueRows = "0" count = "" datasetConfigVersion = "0.6" completionStamp = "1" ><Dataset name = "mmusculus_gene_ensembl" interface = "default" ><Attribute name = "ensembl_gene_id" /><Attribute name = "hsapiens_homolog_ensembl_gene" /></Dataset></Query>'
wget -qO- "$url" | sort | gzip > "$outfile_mmu_HM"


## AGGREGATE TO ONE REFERENCE ID PER LINE

# Status message
echo "Aggregating multiple reference ID entries..." >> "$logFile"

# Human
outfile_one_to_many_hsa="${outPrefixHsa}.one_to_many.tsv.gz"
awk 'BEGIN{FS="\t"; OFS="\t"} {a1[$1]=$1; if (a2[$1] == "") {a2[$1]=$2} else {a2[$1]=a2[$1]"|"$2}; if (a3[$1] == "") {a3[$1]=$3} else {a3[$1]=a3[$1]"|"$3}} END{for (id in a1) {print id, a2[id], a3[id]}}' <(zcat "$outfile_hsa") | sort | gzip > "$outfile_one_to_many_hsa"

# Mouse
outfile_one_to_many_mmu="${outPrefixMmu}.one_to_many.tsv.gz"
awk 'BEGIN{FS="\t"; OFS="\t"} {a1[$1]=$1; if (a2[$1] == "") {a2[$1]=$2} else {a2[$1]=a2[$1]"|"$2}; if (a3[$1] == "") {a3[$1]=$3} else {a3[$1]=a3[$1]"|"$3}} END{for (id in a1) {print id, a2[id], a3[id]}}' <(zcat "$outfile_mmu") | sort | gzip > "$outfile_one_to_many_mmu"

# Chimpanzee
outfile_one_to_many_ptr="${outPrefixPtr}.one_to_many.tsv.gz"
awk 'BEGIN{FS="\t"; OFS="\t"} {a1[$1]=$1; if (a2[$1] == "") {a2[$1]=$2} else {a2[$1]=a2[$1]"|"$2}; if (a3[$1] == "") {a3[$1]=$3} else {a3[$1]=a3[$1]"|"$3}} END{for (id in a1) {print id, a2[id], a3[id]}}' <(zcat "$outfile_ptr") | sort | gzip > "$outfile_one_to_many_ptr"

# Human; human & mouse only
outfile_one_to_many_hsa_HM="${outPrefixHsa}.one_to_many.${prefixHM}.tsv.gz"
awk 'BEGIN{FS="\t"; OFS="\t"} {a1[$1]=$1; if (a2[$1] == "") {a2[$1]=$2} else {a2[$1]=a2[$1]"|"$2}} END{for (id in a1) {print id, a2[id]}}' <(zcat "$outfile_hsa_HM") | sort | gzip > "$outfile_one_to_many_hsa_HM"

# Mouse; human & mouse only
outfile_one_to_many_mmu_HM="${outPrefixMmu}.one_to_many.${prefixHM}.tsv.gz"
awk 'BEGIN{FS="\t"; OFS="\t"} {a1[$1]=$1; if (a2[$1] == "") {a2[$1]=$2} else {a2[$1]=a2[$1]"|"$2}} END{for (id in a1) {print id, a2[id]}}' <(zcat "$outfile_mmu_HM") | sort | gzip > "$outfile_one_to_many_mmu_HM"


## FILTER ONE-TO-ONE RELATIONS PER REFERENCE

# Status message
echo "Filtering only one-to-one relations for each reference..." >> "$logFile"

# Human
outfile_one_to_one_hsa="${outPrefixHsa}.one_to_one.tsv.gz"
awk 'BEGIN{FS="\t"} ($2 != "" && $3 != "" && !/\|/)' <(zcat "$outfile_one_to_many_hsa") | gzip > "$outfile_one_to_one_hsa"

# Mouse
outfile_one_to_one_mmu="${outPrefixMmu}.one_to_one.tsv.gz"
awk 'BEGIN{FS="\t"} ($2 != "" && $3 != "" && !/\|/)' <(zcat "$outfile_one_to_many_mmu") | gzip > "$outfile_one_to_one_mmu"

# Chimpanzee
outfile_one_to_one_ptr="${outPrefixPtr}.one_to_one.tsv.gz"
awk 'BEGIN{FS="\t"} ($2 != "" && $3 != "" && !/\|/)' <(zcat "$outfile_one_to_many_ptr") | gzip > "$outfile_one_to_one_ptr"

# Human; human & mouse only
outfile_one_to_one_hsa_HM="${outPrefixHsa}.one_to_one.${prefixHM}.tsv.gz"
awk 'BEGIN{FS="\t"} ($2 != "" && !/\|/)' <(zcat "$outfile_one_to_many_hsa_HM") | gzip > "$outfile_one_to_one_hsa_HM"

# Mouse; human & mouse only
outfile_one_to_one_mmu_HM="${outPrefixMmu}.one_to_one.${prefixHM}.tsv.gz"
awk 'BEGIN{FS="\t"} ($2 != "" && !/\|/)' <(zcat "$outfile_one_to_many_mmu_HM") | gzip > "$outfile_one_to_one_mmu_HM"


## EXTRACT ONE-TO-ONE RELATIONS ACROSS ALL ORGANISMS

# Status message
echo "Extracting one-to-one relations across all organisms..." >> "$logFile"

# Rearrange one-to-one relations: mouse
outfile_tmp_mmu="${tmpDir}/1_to_1.${orgMmu}"
paste <(cut -f2 <(zcat "$outfile_one_to_one_mmu")) <(cut -f1 <(zcat "$outfile_one_to_one_mmu")) <(cut -f3 <(zcat $outfile_one_to_one_mmu)) | sort > "$outfile_tmp_mmu"

# Rearrange one-to-one relations: chimpanzee
outfile_tmp_ptr="${tmpDir}/1_to_1.${orgPtr}"
paste <(cut -f2 <(zcat "$outfile_one_to_one_ptr")) <(cut -f3 <(zcat "$outfile_one_to_one_ptr")) <(cut -f1 <(zcat $outfile_one_to_one_ptr)) | sort > "$outfile_tmp_ptr"

# Get one-to-one relations: mouse vs chimpanzee
outfile_tmp_mmu_ptr="${tmpDir}/1_to_1.${orgMmu}_${orgPtr}"
comm -12 "$outfile_tmp_mmu" "$outfile_tmp_ptr" > "$outfile_tmp_mmu_ptr"

# Get one-to-one relations: human vs mouse vs chimpanzee
outfile_one_to_one_all="${outPrefixAll}.one_to_one.tsv.gz"
comm -12 <(zcat "$outfile_one_to_one_hsa") "$outfile_tmp_mmu_ptr" | gzip > "$outfile_one_to_one_all"


## EXTRACT ONE-TO-ONE RELATIONS ACROSS HUMAN AND MOUSE

# Status message
echo "Extracting one-to-one relations across human and mouse..." >> "$logFile"

# Rearrange one-to-one relations: mouse
outfile_tmp_mmu_HM="${tmpDir}/1_to_1.${orgMmu}.${prefixHM}"
paste <(cut -f2 <(zcat "$outfile_one_to_one_mmu_HM")) <(cut -f1 <(zcat "$outfile_one_to_one_mmu_HM")) | sort > "$outfile_tmp_mmu_HM"

# Get one-to-one relations: human vs mouse
outfile_one_to_one_hm="${outPrefixAll}.one_to_one.${prefixHM}.tsv.gz"
comm -12 <(zcat "$outfile_one_to_one_hsa_HM") "$outfile_tmp_mmu_HM" | gzip > "$outfile_one_to_one_hm"


#############
###  END  ###
#############

echo "Persistent data stored in: $outDir" >> "$logFile"
echo "Temporary data stored in: $tmpDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
