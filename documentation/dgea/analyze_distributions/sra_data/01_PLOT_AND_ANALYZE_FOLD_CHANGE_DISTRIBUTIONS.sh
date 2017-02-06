#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 23-JAN-2017                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Plot fold change distributions and calculate statistics.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))))"

# Set script path
script="${root}/scriptsSoftware/dgea/analyze_distributions.R"

# Set input files
inDirRoot="${root}/analyzedData/dgea/edgeR/sra_data/merged"
inFileHsaByStudy="${inDirRoot}/hsa.by_study_and_condition.fc.tsv"
inFileMmuByStudy="${inDirRoot}/mmu.by_study_and_condition.fc.tsv"
inFilePtrByStudy="${inDirRoot}/ptr.by_study_and_condition.fc.tsv"
inFileAllByStudy="${inDirRoot}/all.by_study_and_condition.fc.tsv"
inFileHsaByCellType="${inDirRoot}/hsa.by_cell_type_only.fc.tsv"
inFileMmuByCellType="${inDirRoot}/mmu.by_cell_type_only.fc.tsv"
inFilePtrByCellType="${inDirRoot}/ptr.by_cell_type_only.fc.tsv"
inFileAllByCellType="${inDirRoot}/all.by_cell_type_only.fc.tsv"

# Set output directories
outDirRoot="${root}/analyzedData/dgea/analyze_distributions/sra_data"
outDirHsaByStudy="${outDirRoot}/hsa/by_study_and_condition"
outDirMmuByStudy="${outDirRoot}/mmu/by_study_and_condition"
outDirPtrByStudy="${outDirRoot}/ptr/by_study_and_condition"
outDirAllByStudy="${outDirRoot}/all/by_study_and_condition"
outDirHsaByCellType="${outDirRoot}/hsa/by_cell_type_only"
outDirMmuByCellType="${outDirRoot}/mmu/by_cell_type_only"
outDirPtrByCellType="${outDirRoot}/ptr/by_cell_type_only"
outDirAllByCellType="${outDirRoot}/all/by_cell_type_only"
logDir="${root}/logFiles/analyzedData/analyze_distributions/sra_data"

# Set other script parameters
prefixHsaByStudy="hsa.by_study_and_condition"
prefixMmuByStudy="mmu.by_study_and_condition"
prefixPtrByStudy="ptr.by_study_and_condition"
prefixAllByStudy="all.by_study_and_condition"
prefixHsaByCellType="hsa.by_cell_type_only"
prefixMmuByCellType="mmu.by_cell_type_only"
prefixPtrByCellType="ptr.by_cell_type_only"
prefixAllByCellType="all.by_cell_type_only"
subsetDirRoot="${root}/publicResources/go_terms/members_per_term"
subsetDirHsa="${subsetDirRoot}/hsa"
subsetDirMmu="${subsetDirRoot}/mmu"
subsetDirPtr="${subsetDirRoot}/ptr"
subsetDirAll="${subsetDirRoot}/union"
subsetGlobHsa="hsa.*.ensembl_gene_ids"
subsetGlobMmu="mmu.*.ensembl_gene_ids"
subsetGlobPtr="ptr.*.ensembl_gene_ids"
subsetGlobAll="*.common_gene_symbols"
subsetAnno="${root}/publicResources/go_terms/go_terms"
minGenes=11
xLabel="Log fold change"
verticalBar=0


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
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

## HUMAN: BY STUDY ID AND CONDITION
echo "Analyzing fold changes of human comparisons by study ID and condition..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFileHsaByStudy" \
    --output-directory="$outDirHsaByStudy" \
    --run-id="$prefixHsaByStudy" \
    --subset-directory="$subsetDirHsa" \
    --subset-glob="$subsetGlobHsa" \
    --subset-annotation="$subsetAnno" \
    --column-short-name-prefix="$prefixHsaByStudy." \
    --minimum-number-of-values-per-set="$minGenes" \
    --plot-x-label="$xLabel" \
    --plot-vertical-bar="$verticalBar" \
    --plot-cdf-median-line \
    --plot-cdf-points-subsets \
    --verbose \
    &>> "$logFile"

## MOUSE: BY STUDY ID AND CONDITION
echo "Analyzing fold changes of mouse comparisons by study ID and condition..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFileMmuByStudy" \
    --output-directory="$outDirMmuByStudy" \
    --run-id="$prefixMmuByStudy" \
    --subset-directory="$subsetDirMmu" \
    --subset-glob="$subsetGlobMmu" \
    --subset-annotation="$subsetAnno" \
    --column-short-name-prefix="$prefixMmuByStudy." \
    --minimum-number-of-values-per-set="$minGenes" \
    --plot-x-label="$xLabel" \
    --plot-vertical-bar="$verticalBar" \
    --plot-cdf-median-line \
    --plot-cdf-points-subsets \
    --verbose \
    &>> "$logFile"

## CHIMPANZEE: BY STUDY ID AND CONDITION
echo "Analyzing fold changes of chimpanzee comparisons by study ID and condition..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFilePtrByStudy" \
    --output-directory="$outDirPtrByStudy" \
    --run-id="$prefixPtrByStudy" \
    --subset-directory="$subsetDirPtr" \
    --subset-glob="$subsetGlobPtr" \
    --subset-annotation="$subsetAnno" \
    --column-short-name-prefix="$prefixPtrByStudy." \
    --minimum-number-of-values-per-set="$minGenes" \
    --plot-x-label="$xLabel" \
    --plot-vertical-bar="$verticalBar" \
    --plot-cdf-median-line \
    --plot-cdf-points-subsets \
    --verbose \
    &>> "$logFile"

## ALL: BY STUDY ID AND CONDITION
echo "Summarizing fold changes of comparisons across organisms by study ID and condition..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFileAllByStudy" \
    --output-directory="$outDirAllByStudy" \
    --run-id="$prefixAllByStudy" \
    --subset-directory="$subsetDirAll" \
    --subset-glob="$subsetGlobAll" \
    --subset-annotation="$subsetAnno" \
    --column-short-name-prefix="$prefixAllByStudy." \
    --minimum-number-of-values-per-set="$minGenes" \
    --plot-x-label="$xLabel" \
    --plot-vertical-bar="$verticalBar" \
    --plot-cdf-median-line \
    --plot-cdf-points-subsets \
    --verbose \
    &>> "$logFile"

## HUMAN: BY CELL TYPE
echo "Summarizing fold changes of human comparisons by cell type..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFileHsaByCellType" \
    --output-directory="$outDirHsaByCellType" \
    --run-id="$prefixHsaByCellType" \
    --subset-directory="$subsetDirHsa" \
    --subset-glob="$subsetGlobHsa" \
    --subset-annotation="$subsetAnno" \
    --column-short-name-prefix="$prefixHsaByCellType." \
    --minimum-number-of-values-per-set="$minGenes" \
    --plot-x-label="$xLabel" \
    --plot-vertical-bar="$verticalBar" \
    --plot-cdf-median-line \
    --plot-cdf-points-subsets \
    --verbose \
    &>> "$logFile"

## MOUSE: BY CELL TYPE
echo "Summarizing fold changes of mouse comparisons by cell type..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFileMmuByCellType" \
    --output-directory="$outDirMmuByCellType" \
    --run-id="$prefixMmuByCellType" \
    --subset-directory="$subsetDirMmu" \
    --subset-glob="$subsetGlobMmu" \
    --subset-annotation="$subsetAnno" \
    --column-short-name-prefix="$prefixMmuByCellType." \
    --minimum-number-of-values-per-set="$minGenes" \
    --plot-x-label="$xLabel" \
    --plot-vertical-bar="$verticalBar" \
    --plot-cdf-median-line \
    --plot-cdf-points-subsets \
    --verbose \
    &>> "$logFile"

## CHIMPANZEE: BY CELL TYPE
echo "Summarizing fold changes of chimpanzee comparisons by cell type..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFilePtrByCellType" \
    --output-directory="$outDirPtrByCellType" \
    --run-id="$prefixPtrByCellType" \
    --subset-directory="$subsetDirPtr" \
    --subset-glob="$subsetGlobPtr" \
    --subset-annotation="$subsetAnno" \
    --column-short-name-prefix="$prefixPtrByCellType." \
    --minimum-number-of-values-per-set="$minGenes" \
    --plot-x-label="$xLabel" \
    --plot-vertical-bar="$verticalBar" \
    --plot-cdf-median-line \
    --plot-cdf-points-subsets \
    --verbose \
    &>> "$logFile"

## ALL: BY CELL TYPE
echo "Summarizing fold changes of comparisons across organisms by cell type..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFileAllByCellType" \
    --output-directory="$outDirAllByCellType" \
    --run-id="$prefixAllByCellType" \
    --subset-directory="$subsetDirAll" \
    --subset-glob="$subsetGlobAll" \
    --subset-annotation="$subsetAnno" \
    --column-short-name-prefix="$prefixAllByCellType." \
    --minimum-number-of-values-per-set="$minGenes" \
    --plot-x-label="$xLabel" \
    --plot-vertical-bar="$verticalBar" \
    --plot-cdf-median-line \
    --plot-cdf-points-subsets \
    --verbose \
    &>> "$logFile"


#############
###  END  ###
#############

echo "Output written to: $outDirRoot" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
