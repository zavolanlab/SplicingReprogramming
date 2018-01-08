#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 30-NOV-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Generates a combined gene symbol for each set of orthologous one-to-one related genes


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))))"

# Set input files
relations="${root}/publicResources/genome_resources/ensembl_84/orthologous_genes/ensembl_84.orthologous_genes.one_to_one.tsv.gz"
relationsHM="${root}/publicResources/genome_resources/ensembl_84/orthologous_genes/ensembl_84.orthologous_genes.one_to_one.hsa_mmu_only.tsv.gz"
idTableHsa="${root}/publicResources/genome_resources/hsa.GRCh38_84/hsa.GRCh38_84.transcripts.tsv.gz"
idTableMmu="${root}/publicResources/genome_resources/mmu.GRCm38_84/mmu.GRCm38_84.transcripts.tsv.gz"
idTablePtr="${root}/publicResources/genome_resources/ptr.CHIMP2.1.4_84/ptr.CHIMP2.1.4_84.transcripts.tsv.gz"

# Set output file path particles
ensemblRelease="ensembl_84"
dataType="orthologous_genes"

# Set output directories
outDir="${root}/publicResources/genome_resources/${ensemblRelease}/${dataType}"
tmpDir="${root}/.tmp/publicResources/genome_resources/${ensemblRelease}/${dataType}"
logDir="${root}/logFiles/publicResources/genome_resources/${ensemblRelease}/${dataType}"

# Set output prefixes
outPrefix="${outDir}/${ensemblRelease}.${dataType}"

# Set other parameters
script="${root}/scriptsSoftware/generic/get_common_gene_symbol_from_orthologous_ensembl_gene_ids.R"


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

# Uncompress input data
echo "Extracting data..." >> "$logFile"
rel="${tmpDir}/ensembl_84.orthologous_genes.one_to_one.tsv"
relHM="${tmpDir}/ensembl_84.orthologous_genes.one_to_one.hsa_mmu_only.tsv"
ids_hsa="${tmpDir}/hsa.GRCh38_84.transcripts.tsv"
ids_mmu="${tmpDir}/mmu.GRCm38_84.transcripts.tsv"
ids_ptr="${tmpDir}/ptr.CHIMP2.1.4_84.transcripts.tsv"
gunzip --stdout "$relations"   > "$rel"
gunzip --stdout "$relationsHM" > "$relHM"
gunzip --stdout "$idTableHsa"  > "$ids_hsa"
gunzip --stdout "$idTableMmu"  > "$ids_mmu"
gunzip --stdout "$idTablePtr"  > "$ids_ptr"

# Get merged gene symbols for orthologous genes (all organisms: hsa, mmu & ptr)
echo "Build lookup table for merged gene symbols of orthologous genes..." >> "$logFile"
out_file_tmp="${tmpDir}/gene_IDs.common_gene_symbols.tsv"
out_file="${outPrefix}.gene_IDs.common_gene_symbols.tsv.gz"
Rscript "$script" --input-table "$rel" --output-table "$out_file_tmp" --grouping-tables "${ids_hsa},${ids_mmu},${ids_ptr}" --group-id-columns 6 --group-symbol-columns 8 --verbose &>> "$logFile"
gzip --stdout "$out_file_tmp" > "$out_file" 2>> "$logFile"

# Get merged gene symbols for orthologous genes (all organisms: hsa, mmu & ptr)
echo "Build lookup table for merged gene symbols of orthologous genes..." >> "$logFile"
out_file_tmp_HM="${tmpDir}/gene_IDs.common_gene_symbols.hsa_mmu_only.tsv"
out_file_HM="${outPrefix}.gene_IDs.common_gene_symbols.hsa_mmu_only.tsv.gz"
Rscript "$script" --input-table "$relHM" --output-table "$out_file_tmp_HM" --grouping-tables "${ids_hsa},${ids_mmu}" --group-id-columns 6 --group-symbol-columns 8 --verbose &>> "$logFile"
gzip --stdout "$out_file_tmp_HM" > "$out_file_HM" 2>> "$logFile"


#############
###  END  ###
#############

echo "Ensembl gene ID > merged gene symbol lookup table: $out_file" >> "$logFile"
echo "Temporary data stored in: $tmpDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
