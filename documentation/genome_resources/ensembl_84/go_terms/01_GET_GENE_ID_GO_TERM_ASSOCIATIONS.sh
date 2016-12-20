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

# Set output file path particles
ensemblRelease="ensembl_84"
dataType="go_terms"
orgHsa="hsa"
orgMmu="mmu"
orgPtr="ptr"

# Set output directories
outDir="${root}/publicResources/genome_resources/${ensemblRelease}/${dataType}"
logDir="${root}/logFiles/publicResources/genome_resources/${ensemblRelease}/${dataType}"

# Set output prefixes
outPrefixHsa="${outDir}/${ensemblRelease}.${dataType}.${orgHsa}"
outPrefixMmu="${outDir}/${ensemblRelease}.${dataType}.${orgMmu}"
outPrefixPtr="${outDir}/${ensemblRelease}.${dataType}.${orgPtr}"
outPrefixAll="${outDir}/${ensemblRelease}.${dataType}"

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
mkdir --parents "$outDir"
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
outfile_hsa="${outPrefixHsa}.biomart.tsv.gz"
url='http://mar2016.archive.ensembl.org/biomart/martservice?query=<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE Query><Query  virtualSchemaName = "default" formatter = "TSV" header = "0" uniqueRows = "0" count = "" datasetConfigVersion = "0.6" completionStamp = "1" ><Dataset name = "hsapiens_gene_ensembl" interface = "default" ><Attribute name = "ensembl_gene_id" /><Attribute name = "go_id" /><Attribute name = "go_linkage_type" /><Attribute name = "namespace_1003" /><Attribute name = "external_gene_name" /><Attribute name = "description" /></Dataset></Query>'
wget -qO- "$url" | awk -F '\t' '{ for (i=1; i <= 6; i++) {if ($i == "" ) next } print}' | uniq | gzip > "$outfile_hsa"

# Mouse genes
echo "Downloading GO term associations for mouse genes..." >> "$logFile"
outfile_mmu="${outPrefixMmu}.biomart.tsv.gz"
url='http://mar2016.archive.ensembl.org/biomart/martservice?query=<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE Query><Query  virtualSchemaName = "default" formatter = "TSV" header = "0" uniqueRows = "0" count = "" datasetConfigVersion = "0.6" completionStamp = "1" ><Dataset name = "mmusculus_gene_ensembl" interface = "default" ><Attribute name = "ensembl_gene_id" /><Attribute name = "go_id" /><Attribute name = "go_linkage_type" /><Attribute name = "namespace_1003" /><Attribute name = "external_gene_name" /><Attribute name = "description" /></Dataset></Query>'
wget -qO- "$url" | awk -F '\t' '{ for (i=1; i <= 6; i++) {if ($i == "" ) next } print}' | uniq | gzip > "$outfile_mmu"

# Chimpanzee genes
echo "Downloading GO term associations for chimpanzee genes..." >> "$logFile"
outfile_ptr="${outPrefixPtr}.biomart.tsv.gz"
url='http://mar2016.archive.ensembl.org/biomart/martservice?query=<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE Query><Query  virtualSchemaName = "default" formatter = "TSV" header = "0" uniqueRows = "0" count = "" datasetConfigVersion = "0.6" completionStamp = "1" ><Dataset name = "ptroglodytes_gene_ensembl" interface = "default" ><Attribute name = "ensembl_gene_id" /><Attribute name = "go_id" /><Attribute name = "go_linkage_type" /><Attribute name = "namespace_1003" /><Attribute name = "external_gene_name" /><Attribute name = "description" /></Dataset></Query>'
wget -qO- "$url" | awk -F '\t' '{ for (i=1; i <= 6; i++) {if ($i == "" ) next } print}' | uniq | gzip > "$outfile_ptr"


## CONVERT TO GAF FORMAT

# Human
echo "Convert human associations to GAF format..." >> "$logFile"
gaf_hsa="${outPrefixHsa}.gaf.gz"
zcat "$outfile_hsa" | "$script" --db "$db" --symbol $col_sym --name $col_name --taxon "$tax_hsa" --verbose 2>> "$logFile" | uniq | sort -t $'\t' -k5,5 | gzip > "$gaf_hsa" 2>> "$logFile"

# Mouse
echo "Convert mouse associations to GAF format..." >> "$logFile"
gaf_mmu="${outPrefixMmu}.gaf.gz"
zcat "$outfile_mmu" | "$script" --db "$db" --symbol $col_sym --name $col_name --taxon "$tax_mmu" --verbose 2>> "$logFile" | uniq | sort -t $'\t' -k5,5 | gzip > "$gaf_mmu" 2>> "$logFile"

# Chimpanzee
echo "Convert chimpanzee associations to GAF format..." >> "$logFile"
gaf_ptr="${outPrefixPtr}.gaf.gz"
zcat "$outfile_ptr" | "$script" --db "$db" --symbol $col_sym --name $col_name --taxon "$tax_ptr" --verbose 2>> "$logFile" | uniq | sort -t $'\t' -k5,5 | gzip > "$gaf_ptr" 2>> "$logFile"


#############
###  END  ###
#############

echo "Persistent data stored in: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
