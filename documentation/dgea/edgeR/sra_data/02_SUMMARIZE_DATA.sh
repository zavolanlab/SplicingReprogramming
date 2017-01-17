#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 10-JAN-2017                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Summarize differential expression analysis results.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))))"

# Set script path
script="${root}/scriptsSoftware/generic/merge_common_field_from_multiple_tables_by_id.R"

# Set input files
inDirRoot="${root}/analyzedData/dgea/edgeR/sra_data"
inDirHsaByStudy="${inDirRoot}/hsa/by_study_and_condition"
inDirMmuByStudy="${inDirRoot}/mmu/by_study_and_condition"
inDirPtrByStudy="${inDirRoot}/ptr/by_study_and_condition"
inDirAllByStudy="${inDirRoot}/all/by_study_and_condition"
inDirHsaByCellType="${inDirRoot}/hsa/by_cell_type_only"
inDirMmuByCellType="${inDirRoot}/mmu/by_cell_type_only"
inDirPtrByCellType="${inDirRoot}/ptr/by_cell_type_only"
inDirAllByCellType="${inDirRoot}/all/by_cell_type_only"

# Set output directories
outDir="${root}/analyzedData/dgea/edgeR/sra_data/summarized"
logDir="${root}/logFiles/analyzedData/dgea/edgeR/sra_data"

# Set other script parameters
inFileGlob="*.fold_changes.tsv"
inFileSuffix=".fold_changes.tsv"
outFileSuffix=".tsv"
idColumn=1
prefixHsa="hsa"
prefixMmu="mmu"
prefixPtr="ptr"
prefixAll="all"
prefixByStudy="by_study_and_condition"
prefixByCellType="by_cell_type_only"
prefixFC="fc"
prefixP="p"
prefixFDR="fdr"
prefixDE="de"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir -p "$outDir"
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

## HUMAN: BY STUDY ID AND CONDITION
echo "Summarizing human comparisons by study ID and condition..." >> "$logFile"

# Fold changes
echo "Extracting fold changes..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=2 \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixFC}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=4 \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# FDRs
echo "Extracting false discovery rates..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=5 \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixFDR}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# Differential expression flags
echo "Extracting differential expression flags (-1, 0, 1)..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirHsaByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=6 \
    --prefix-ungrouped="${prefixHsa}.${prefixByStudy}.${prefixDE}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY STUDY ID AND CONDITION
echo "Summarizing mouse comparisons by study ID and condition..." >> "$logFile"

# Fold changes
echo "Extracting fold changes..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=2 \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixFC}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=4 \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# FDRs
echo "Extracting false discovery rates..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=5 \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixFDR}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# Differential expression flags
echo "Extracting differential expression flags (-1, 0, 1)..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirMmuByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=6 \
    --prefix-ungrouped="${prefixMmu}.${prefixByStudy}.${prefixDE}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY STUDY ID AND CONDITION
echo "Summarizing chimpanzee comparisons by study ID and condition..." >> "$logFile"

# Fold changes
echo "Extracting fold changes..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=2 \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixFC}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=4 \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# FDRs
echo "Extracting false discovery rates..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=5 \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixFDR}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# Differential expression flags
echo "Extracting differential expression flags (-1, 0, 1)..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirPtrByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=6 \
    --prefix-ungrouped="${prefixPtr}.${prefixByStudy}.${prefixDE}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## ALL: BY STUDY ID AND CONDITION
echo "Summarizing comparisons across organisms by study ID and condition..." >> "$logFile"

# Fold changes
echo "Extracting fold changes..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirAllByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=2 \
    --prefix-ungrouped="${prefixAll}.${prefixByStudy}.${prefixFC}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirAllByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=4 \
    --prefix-ungrouped="${prefixAll}.${prefixByStudy}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# FDRs
echo "Extracting false discovery rates..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirAllByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=5 \
    --prefix-ungrouped="${prefixAll}.${prefixByStudy}.${prefixFDR}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# Differential expression flags
echo "Extracting differential expression flags (-1, 0, 1)..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirAllByStudy" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=6 \
    --prefix-ungrouped="${prefixAll}.${prefixByStudy}.${prefixDE}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## HUMAN: BY CELL TYPE
echo "Summarizing human comparisons by cell type..." >> "$logFile"

# Fold changes
echo "Extracting fold changes..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=2 \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixFC}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=4 \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# FDRs
echo "Extracting false discovery rates..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=5 \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixFDR}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# Differential expression flags
echo "Extracting differential expression flags (-1, 0, 1)..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirHsaByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=6 \
    --prefix-ungrouped="${prefixHsa}.${prefixByCellType}.${prefixDE}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## MOUSE: BY CELL TYPE
echo "Summarizing mouse comparisons by cell type..." >> "$logFile"

# Fold changes
echo "Extracting fold changes..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=2 \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixFC}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=4 \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# FDRs
echo "Extracting false discovery rates..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=5 \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixFDR}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# Differential expression flags
echo "Extracting differential expression flags (-1, 0, 1)..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirMmuByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=6 \
    --prefix-ungrouped="${prefixMmu}.${prefixByCellType}.${prefixDE}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## CHIMPANZEE: BY CELL TYPE
echo "Summarizing chimpanzee comparisons by cell type..." >> "$logFile"

# Fold changes
echo "Extracting fold changes..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=2 \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixFC}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=4 \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# FDRs
echo "Extracting false discovery rates..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=5 \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixFDR}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# Differential expression flags
echo "Extracting differential expression flags (-1, 0, 1)..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirPtrByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=6 \
    --prefix-ungrouped="${prefixPtr}.${prefixByCellType}.${prefixDE}" \
    --has-header \
    --verbose \
    &>> "$logFile"


## ALL: BY CELL TYPE
echo "Summarizing comparisons across organisms by cell type..." >> "$logFile"

# Fold changes
echo "Extracting fold changes..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirAllByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=2 \
    --prefix-ungrouped="${prefixAll}.${prefixByCellType}.${prefixFC}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# P values
echo "Extracting P values..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirAllByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=4 \
    --prefix-ungrouped="${prefixAll}.${prefixByCellType}.${prefixP}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# FDRs
echo "Extracting false discovery rates..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirAllByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=5 \
    --prefix-ungrouped="${prefixAll}.${prefixByCellType}.${prefixFDR}" \
    --has-header \
    --verbose \
    &>> "$logFile"

# Differential expression flags
echo "Extracting differential expression flags (-1, 0, 1)..." >> "$logFile"
Rscript "$script" \
    --input-directory="$inDirAllByCellType" \
    --recursive \
    --output-directory="$outDir" \
    --out-file-suffix="$outFileSuffix" \
    --glob="$inFileGlob" \
    --id-suffix="$inFileSuffix" \
    --id-column="$idColumn" \
    --data-column=6 \
    --prefix-ungrouped="${prefixAll}.${prefixByCellType}.${prefixDE}" \
    --has-header \
    --verbose \
    &>> "$logFile"


#############
###  END  ###
#############

echo "Output written to: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
