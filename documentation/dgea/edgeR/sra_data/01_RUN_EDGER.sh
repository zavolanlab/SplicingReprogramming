#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 19-DEC-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Runs differential gene expression analysis with edgeR.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))))"

# Set script path
script="${root}/scriptsSoftware/dgea/dgea_edgeR.R"

# Set input files
annoRaw="${root}/internalResources/sra_data/samples.annotations.tsv"
compRaw="${root}/internalResources/sra_data/samples.comparisons.tsv"
cntsHsa="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/counts/Homo_sapiens.genes.counts"
cntsMmu="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/counts/Mus_musculus.genes.counts"
cntsPtr="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/counts/Pan_troglodytes.genes.counts"
cntsAll="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/counts/all.orthologous_genes.counts"
excl="${root}/analyzedData/align_and_quantify/sra_data/stats/samples_to_filter"

# Set output directories
outDirRoot="${root}/analyzedData/dgea/edgeR/sra_data"
outDirHsaByStudy="${outDirRoot}/hsa/by_study_and_condition"
outDirMmuByStudy="${outDirRoot}/mmu/by_study_and_condition"
outDirPtrByStudy="${outDirRoot}/ptr/by_study_and_condition"
outDirAllByStudy="${outDirRoot}/all/by_study_and_condition"
outDirHsaByCellType="${outDirRoot}/hsa/by_cell_type_only"
outDirMmuByCellType="${outDirRoot}/mmu/by_cell_type_only"
outDirPtrByCellType="${outDirRoot}/ptr/by_cell_type_only"
outDirAllByCellType="${outDirRoot}/all/by_cell_type_only"
tmpDir="${root}/.tmp/analyzedData/dgea/edgeR/sra_data"
logDir="${root}/logFiles/analyzedData/dgea/edgeR/sra_data"

# Set temporary files
annoHsaByStudy="${tmpDir}/annotations.hsa.by_study_and_condition"
annoMmuByStudy="${tmpDir}/annotations.mmu.by_study_and_condition"
annoPtrByStudy="${tmpDir}/annotations.ptr.by_study_and_condition"
annoAllByStudy="${tmpDir}/annotations.all.by_study_and_condition"
annoHsaByCellType="${tmpDir}/annotations.hsa.by_cell_type_only"
annoMmuByCellType="${tmpDir}/annotations.mmu.by_cell_type_only"
annoPtrByCellType="${tmpDir}/annotations.ptr.by_cell_type_only"
annoAllByCellType="${tmpDir}/annotations.all.by_cell_type_only"
compHsaByStudy="${tmpDir}/comparisons.hsa.by_study_and_condition"
compMmuByStudy="${tmpDir}/comparisons.mmu.by_study_and_condition"
compPtrByStudy="${tmpDir}/comparisons.ptr.by_study_and_condition"
compAllByStudy="${tmpDir}/comparisons.all.by_study_and_condition"

# Set other script parameters
runIdHsaByStudy="hsa.by_study_and_condition"
runIdMmuByStudy="mmu.by_study_and_condition"
runIdPtrByStudy="ptr.by_study_and_condition"
runIdAllByStudy="all.by_study_and_condition"
runIdHsaByCellType="hsa.by_cell_type_only"
runIdMmuByCellType="mmu.by_cell_type_only"
runIdPtrByCellType="ptr.by_cell_type_only"
runIdAllByCellType="all.by_cell_type_only"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir -p "$outDirRoot"
mkdir -p "$outDirHsaByStudy" "$outDirMmuByStudy" "$outDirPtrByStudy" "$outDirAllByStudy"
mkdir -p "$outDirHsaByCellType" "$outDirMmuByCellType" "$outDirPtrByCellType" "$outDirAllByCellType"
mkdir -p "$tmpDir"
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

# Prepare sample annotations for each condition
echo "Preparing sample annotations..." >> "$logFile"
awk 'BEGIN{OFS="\t"} $4 == "Homo_sapiens" {print $1, $2"."$4"."$6}' "$annoRaw" > "$annoHsaByStudy" 2>> "$logFile"
awk 'BEGIN{OFS="\t"} $4 == "Mus_musculus" {print $1, $2"."$4"."$6}' "$annoRaw" > "$annoMmuByStudy" 2>> "$logFile"
awk 'BEGIN{OFS="\t"} $4 == "Pan_troglodytes" {print $1, $2"."$4"."$6}' "$annoRaw" > "$annoPtrByStudy" 2>> "$logFile"
awk 'BEGIN{OFS="\t"} {print $1, $2"."$6}' <(tail -n +2 "$annoRaw") > "$annoAllByStudy" 2>> "$logFile"
awk 'BEGIN{OFS="\t"} $4 == "Homo_sapiens" {print $1, $4"."$7}' "$annoRaw" > "$annoHsaByCellType" 2>> "$logFile"
awk 'BEGIN{OFS="\t"} $4 == "Mus_musculus" {print $1, $4"."$7}' "$annoRaw" > "$annoMmuByCellType" 2>> "$logFile"
awk 'BEGIN{OFS="\t"} $4 == "Pan_troglodytes" {print $1, $4"."$7}' "$annoRaw" > "$annoPtrByCellType" 2>> "$logFile"
awk 'BEGIN{OFS="\t"} {print $1, $7}' <(tail -n +2 "$annoRaw") > "$annoAllByCellType" 2>> "$logFile"

# Prepare sample contrasts for each condition
echo "Preparing sample comparisons..." >> "$logFile"
awk '$5 == "Homo_sapiens"' "$compRaw" > "$compHsaByStudy" 2>> "$logFile"
awk '$5 == "Mus_musculus"' "$compRaw" > "$compMmuByStudy" 2>> "$logFile"
awk '$5 == "Pan_troglodytes"' "$compRaw" > "$compPtrByStudy" 2>> "$logFile"
awk '$5 == "mixed"' "$compRaw" > "$compAllByStudy" 2>> "$logFile"

# Human: by study and cell type
echo "Comparing gene expression across relevant conditions per study: human..." >> "$logFile"
Rscript "$script" \
    --count-table="$cntsHsa" \
    --output-directory="$outDirHsaByStudy" \
    --run-id="$runIdHsaByStudy" \
    --exclude="$excl" \
    --annotation="$annoHsaByStudy" \
    --comparisons="$compHsaByStudy" \
    --reference-column=2 \
    --query-column=1 \
    --comparison-name-column=3 \
    --verbose &>> "$logFile"

# Mouse: by study and cell type
echo "Comparing gene expression across relevant conditions per study: mouse..." >> "$logFile"
Rscript "$script" \
    --count-table="$cntsMmu" \
    --output-directory="$outDirMmuByStudy" \
    --run-id="$runIdMmuByStudy" \
    --exclude="$excl" \
    --annotation="$annoMmuByStudy" \
    --comparisons="$compMmuByStudy" \
    --reference-column=2 \
    --query-column=1 \
    --comparison-name-column=3 \
    --verbose &>> "$logFile"

# Chimpanzee: by study and cell type
echo "Comparing gene expression across relevant conditions per study: chimpanzee..." >> "$logFile"
Rscript "$script" \
    --count-table="$cntsPtr" \
    --output-directory="$outDirPtrByStudy" \
    --run-id="$runIdPtrByStudy" \
    --exclude="$excl" \
    --annotation="$annoPtrByStudy" \
    --comparisons="$compPtrByStudy" \
    --reference-column=2 \
    --query-column=1 \
    --comparison-name-column=3 \
    --verbose &>> "$logFile"

# Human: By cell type only
echo "Comparing gene expression across cell types: human..." >> "$logFile"
Rscript "$script" \
    --count-table="$cntsHsa" \
    --output-directory="$outDirHsaByCellType" \
    --run-id="$runIdHsaByCellType" \
    --exclude="$excl" \
    --annotation="$annoHsaByCellType" \
    --verbose &>> "$logFile"

# Mouse: By cell type only
echo "Comparing gene expression across cell types: mouse..." >> "$logFile"
Rscript "$script" \
    --count-table="$cntsMmu" \
    --output-directory="$outDirMmuByCellType" \
    --run-id="$runIdMmuByCellType" \
    --exclude="$excl" \
    --annotation="$annoMmuByCellType" \
    --verbose &>> "$logFile"

# Chimpanzee: By cell type only
echo "Comparing gene expression across cell types: chimpanzee..." >> "$logFile"
Rscript "$script" \
    --count-table="$cntsPtr" \
    --output-directory="$outDirPtrByCellType" \
    --run-id="$runIdPtrByCellType" \
    --exclude="$excl" \
    --annotation="$annoPtrByCellType" \
    --verbose &>> "$logFile"

# Across organisms: By cell type only
echo "Comparing gene expression across cell types: across organisms..." >> "$logFile"
Rscript "$script" \
    --count-table="$cntsAll" \
    --output-directory="$outDirAllByCellType" \
    --run-id="$runIdAllByCellType" \
    --exclude="$excl" \
    --annotation="$annoAllByCellType" \
    --verbose &>> "$logFile"


#############
###  END  ###
#############

echo "Output written to: $outDirRoot" >> "$logFile"
echo "Temporary files written to: $tmpDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
