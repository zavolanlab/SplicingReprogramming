#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 19-DEC-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Generates gene ontology associations in GAF format
# Organisms: human, monkey, chimpanzee


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))))"

# Set input files
goTerms="${root}/publicResources/go_terms/go_terms"

# Set output file path particles
ensemblRelease="ensembl_84"
dataType="go_terms"
orgHsa="hsa"
orgMmu="mmu"
orgPtr="ptr"

# Set output directories
outDir="${root}/publicResources/genome_resources/${ensemblRelease}/${dataType}"
outDirHsa="${outDir}/${orgHsa}"
outDirMmu="${outDir}/${orgMmu}"
outDirPtr="${outDir}/${orgPtr}"
logDir="${root}/logFiles/publicResources/genome_resources/${ensemblRelease}/${dataType}"

# Set output prefixes
outPrefixHsa="${ensemblRelease}.${dataType}.${orgHsa}"
outPrefixMmu="${ensemblRelease}.${dataType}.${orgMmu}"
outPrefixPtr="${ensemblRelease}.${dataType}.${orgPtr}"

# Set GAF generation script
script="/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/scriptsSoftware/genomic_resources/generate_gene_associations_file_from_table.py"

# Set script parameters
db="Ensembl"
col_sym=5
col_name=6
tax_hsa="taxon:9606"
tax_mmu="taxon:10090"
tax_ptr="taxon:9598"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir --parents "$outDir" "$outDirHsa" "$outDirMmu" "$outDirPtr"
mkdir --parents "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

## DOWNLOAD GENE ID <> GO TERM ASSOCIATIONS FROM BIOMART

# Human genes
echo "Downloading GO term associations for human genes..." >> "$logFile"
outfile_hsa="${outDirHsa}/${outPrefixHsa}.biomart.tsv.gz"
url='http://mar2016.archive.ensembl.org/biomart/martservice?query=<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE Query><Query  virtualSchemaName = "default" formatter = "TSV" header = "0" uniqueRows = "0" count = "" datasetConfigVersion = "0.6" completionStamp = "1" ><Dataset name = "hsapiens_gene_ensembl" interface = "default" ><Attribute name = "ensembl_gene_id" /><Attribute name = "go_id" /><Attribute name = "go_linkage_type" /><Attribute name = "namespace_1003" /><Attribute name = "external_gene_name" /><Attribute name = "description" /></Dataset></Query>'
wget -qO- "$url" | awk -F '\t' '{ for (i=1; i <= 6; i++) {if ($i == "" ) next } print }' | uniq | gzip > "$outfile_hsa"

# Mouse genes
echo "Downloading GO term associations for mouse genes..." >> "$logFile"
outfile_mmu="${outDirMmu}/${outPrefixMmu}.biomart.tsv.gz"
url='http://mar2016.archive.ensembl.org/biomart/martservice?query=<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE Query><Query  virtualSchemaName = "default" formatter = "TSV" header = "0" uniqueRows = "0" count = "" datasetConfigVersion = "0.6" completionStamp = "1" ><Dataset name = "mmusculus_gene_ensembl" interface = "default" ><Attribute name = "ensembl_gene_id" /><Attribute name = "go_id" /><Attribute name = "go_linkage_type" /><Attribute name = "namespace_1003" /><Attribute name = "external_gene_name" /><Attribute name = "description" /></Dataset></Query>'
wget -qO- "$url" | awk -F '\t' '{ for (i=1; i <= 6; i++) {if ($i == "" ) next } print }' | uniq | gzip > "$outfile_mmu"

# Chimpanzee genes
echo "Downloading GO term associations for chimpanzee genes..." >> "$logFile"
outfile_ptr="${outDirPtr}/${outPrefixPtr}.biomart.tsv.gz"
url='http://mar2016.archive.ensembl.org/biomart/martservice?query=<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE Query><Query  virtualSchemaName = "default" formatter = "TSV" header = "0" uniqueRows = "0" count = "" datasetConfigVersion = "0.6" completionStamp = "1" ><Dataset name = "ptroglodytes_gene_ensembl" interface = "default" ><Attribute name = "ensembl_gene_id" /><Attribute name = "go_id" /><Attribute name = "go_linkage_type" /><Attribute name = "namespace_1003" /><Attribute name = "external_gene_name" /><Attribute name = "description" /></Dataset></Query>'
wget -qO- "$url" | awk -F '\t' '{ for (i=1; i <= 6; i++) {if ($i == "" ) next } print }' | uniq | gzip > "$outfile_ptr"


## CONVERT TO GAF FORMAT

# Human
echo "Convert human associations to GAF format..." >> "$logFile"
gaf_hsa="${outDirHsa}/${outPrefixHsa}.gaf.gz"
zcat "$outfile_hsa" | "$script" --db "$db" --symbol $col_sym --name $col_name --taxon "$tax_hsa" --verbose 2>> "$logFile" | uniq | sort -t $'\t' -k5,5 | gzip > "$gaf_hsa" 2>> "$logFile"

# Mouse
echo "Convert mouse associations to GAF format..." >> "$logFile"
gaf_mmu="${outDirMmu}/${outPrefixMmu}.gaf.gz"
zcat "$outfile_mmu" | "$script" --db "$db" --symbol $col_sym --name $col_name --taxon "$tax_mmu" --verbose 2>> "$logFile" | uniq | sort -t $'\t' -k5,5 | gzip > "$gaf_mmu" 2>> "$logFile"

# Chimpanzee
echo "Convert chimpanzee associations to GAF format..." >> "$logFile"
gaf_ptr="${outDirPtr}/${outPrefixPtr}.gaf.gz"
zcat "$outfile_ptr" | "$script" --db "$db" --symbol $col_sym --name $col_name --taxon "$tax_ptr" --verbose 2>> "$logFile" | uniq | sort -t $'\t' -k5,5 | gzip > "$gaf_ptr" 2>> "$logFile"


## EXTRACT ENSEMBL GENE IDS & GENE SYMBOLS PER GO CATEGORY OF INTEREST

# Human
while read -r term; do
    term_short=$(echo $term | cut -f 2 -d ":")
    out_dir="${outDirHsa}/gene_members_per_category"
    mkdir -p "$out_dir"
    ids_hsa="${out_dir}/${outPrefixHsa}.${term_short}.ensembl_gene_ids"
    sym_hsa="${out_dir}/${outPrefixHsa}.${term_short}.gene_symbols"
    awk -v term=$term '$2 == term { print $1 }' <(zcat "$outfile_hsa") | sort -u > "$ids_hsa"
    awk -v term=$term '$2 == term { print $5 }' <(zcat "$outfile_hsa") | sort -u > "$sym_hsa"
done < <(cut -f1 "$goTerms")

# Mouse
while read -r term; do
    term_short=$(echo $term | cut -f 2 -d ":")
    out_dir="${outDirMmu}/gene_members_per_category"
    mkdir -p "$out_dir"
    ids_mmu="${out_dir}/${outPrefixMmu}.${term_short}.ensembl_gene_ids"
    sym_mmu="${out_dir}/${outPrefixMmu}.${term_short}.gene_symbols"
    awk -v term=$term '$2 == term { print $1 }' <(zcat "$outfile_mmu") | sort -u > "$ids_mmu"
    awk -v term=$term '$2 == term { print $5 }' <(zcat "$outfile_mmu") | sort -u > "$sym_mmu"
done < <(cut -f1 "$goTerms")

# Human
while read -r term; do
    term_short=$(echo $term | cut -f 2 -d ":")
    out_dir="${outDirPtr}/gene_members_per_category"
    mkdir -p "$out_dir"
    ids_ptr="${out_dir}/${outPrefixPtr}.${term_short}.ensembl_gene_ids"
    sym_ptr="${out_dir}/${outPrefixPtr}.${term_short}.gene_symbols"
    awk -v term=$term '$2 == term { print $1 }' <(zcat "$outfile_ptr") | sort -u > "$ids_ptr"
    awk -v term=$term '$2 == term { print $5 }' <(zcat "$outfile_ptr") | sort -u > "$sym_ptr"
done < <(cut -f1 "$goTerms")


#############
###  END  ###
#############

echo "Persistent data stored in: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
