#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 31-JAN-2017                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Plot fold change heatmaps.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))))"

# Set script path
script="${root}/scriptsSoftware/generic/plot_heatmaps.R"

# Set input files
inDirRoot="${root}/analyzedData/dgea/edgeR/sra_data/merged"
inFileHsaByStudy="${inDirRoot}/hsa.by_study_and_condition.fc.tsv"
inFileMmuByStudy="${inDirRoot}/mmu.by_study_and_condition.fc.tsv"
inFilePtrByStudy="${inDirRoot}/ptr.by_study_and_condition.fc.tsv"
inFileMergedByStudy="${inDirRoot}/orthologous_genes/merged.by_study_and_condition.orthologous_genes.fc.tsv"

# Set output directories
outDirRoot="${root}/analyzedData/dgea/heatmaps/sra_data"
outDirHsaUnfiltered="${outDirRoot}/hsa/by_study_and_condition/unfiltered"
outDirMmuUnfiltered="${outDirRoot}/mmu/by_study_and_condition/unfiltered"
outDirPtrUnfiltered="${outDirRoot}/ptr/by_study_and_condition/unfiltered"
outDirMergedUnfiltered="${outDirRoot}/merged/by_study_and_condition/unfiltered"
outDirHsaFold10="${outDirRoot}/hsa/by_study_and_condition/mean_fold_change_10x"
outDirMmuFold10="${outDirRoot}/mmu/by_study_and_condition/mean_fold_change_10x"
outDirPtrFold10="${outDirRoot}/ptr/by_study_and_condition/mean_fold_change_10x"
outDirMergedFold10="${outDirRoot}/merged/by_study_and_condition/mean_fold_change_10x"
tmpDir="${root}/.tmp/analyzedData/dgea/heatmaps/sra_data"
logDir="${root}/logFiles/analyzedData/analyze_distributions/sra_data"

# Set other script parameters
colPrefixHsa="hsa.by_study_and_condition."
colPrefixMmu="mmu.by_study_and_condition."
colPrefixPtr="ptr.by_study_and_condition."
runIdHsa="heatmap.hsa.by_study_and_condition"
runIdMmu="heatmap.mmu.by_study_and_condition"
runIdPtr="heatmap.ptr.by_study_and_condition"
runIdMerged="heatmap.merged.by_study_and_condition"
colAnno="${root}/internalResources/sra_data/samples.comparisons.tsv"
colAnnoIdCol=3
colAnnoNameCol=8
colAnnoNameColMerged=9
colAnnoCatCols=6
colAnnoSidebarColorCatCol=5
rowAnnoHsa="${root}/publicResources/genome_resources/hsa.GRCh38_84/hsa.GRCh38_84.genes.id_to_symbol.tsv.gz"
rowAnnoMmu="${root}/publicResources/genome_resources/mmu.GRCm38_84/mmu.GRCm38_84.genes.id_to_symbol.tsv.gz"
rowAnnoPtr="${root}/publicResources/genome_resources/ptr.CHIMP2.1.4_84/ptr.CHIMP2.1.4_84.genes.id_to_symbol.tsv.gz"
subsetDirRoot="${root}/publicResources/go_terms/members_per_term"
subsetDirHsa="${subsetDirRoot}/hsa"
subsetDirMmu="${subsetDirRoot}/mmu"
subsetDirPtr="${subsetDirRoot}/ptr"
subsetDirMerged="${subsetDirRoot}/union"
subsetGlobHsa="hsa.*.ensembl_gene_ids"
subsetGlobMmu="mmu.*.ensembl_gene_ids"
subsetGlobPtr="ptr.*.ensembl_gene_ids"
subsetGlobMerged="*.common_gene_symbols"
subsetAnno="${root}/publicResources/go_terms/go_terms"
logThreshold=3.3219
logThresholdPerOrganism="or"
fileFormatUnfiltered="png"
fileFormatFiltered="svg"
colorKeyXLabel="Log fold change"
columnLabelAngle=60
columnLabelCharExp=0.8


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir -p "$outDirRoot"
mkdir -p "$tmpDir"
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

## UNCOMPRESS GENE SYMBOL LOOKUP TABLES
echo "Extracting Ensembl gene identifier to gene symbol conversion tables..." >> "$logFile"
rowAnnoHsaTmp="${tmpDir}/hsa.GRCh38_84.genes.id_to_symbol.tsv"
rowAnnoMmuTmp="${tmpDir}/mmu.GRCm38_84.genes.id_to_symbol.tsv"
rowAnnoPtrTmp="${tmpDir}/ptr.CHIMP2.1.4_84.genes.id_to_symbol.tsv"
gunzip --stdout "$rowAnnoHsa" > "$rowAnnoHsaTmp"
gunzip --stdout "$rowAnnoMmu" > "$rowAnnoMmuTmp"
gunzip --stdout "$rowAnnoPtr" > "$rowAnnoPtrTmp"

## PREPARE MERGED FOLD CHANGE TABLE
inFileMergedByStudyTmp="${tmpDir}/merged.orthologous_genes.fc.header_processed.tsv"
sed -r 's/(hsa|mmu|ptr)\.by_study_and_condition\.//g' "$inFileMergedByStudy" > "$inFileMergedByStudyTmp"

## HUMAN: UNFILTERED
echo "Plotting fold changes of human comparisons by study ID and condition..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFileHsaByStudy" \
    --data-has-header \
    --column-id-prefix="$colPrefixHsa" \
    --run-id="$runIdHsa" \
    --output-directory="$outDirHsaUnfiltered" \
    --column-annotation="$colAnno" \
    --column-annotation-has-header \
    --column-annotation-id-column="$colAnnoIdCol" \
    --column-annotation-name-column="$colAnnoNameCol" \
    --column-annotation-category-columns="$colAnnoCatCols" \
    --row-annotation="$rowAnnoHsaTmp" \
    --subset-directory="$subsetDirHsa" \
    --subset-glob="$subsetGlobHsa" \
    --subset-annotation="$subsetAnno" \
    --plot-file-format="$fileFormatUnfiltered" \
    --plot-key-x-label="$colorKeyXLabel" \
    --plot-color-median="white" \
    --plot-column-label-angle="$columnLabelAngle" \
    --plot-column-label-expansion-factor="$columnLabelCharExp" \
    --verbose \
    &>> "$logFile"

## MOUSE: UNFILTERED
echo "Plotting fold changes of mouse comparisons by study ID and condition..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFileMmuByStudy" \
    --data-has-header \
    --column-id-prefix="$colPrefixMmu" \
    --run-id="$runIdMmu" \
    --output-directory="$outDirMmuUnfiltered" \
    --column-annotation="$colAnno" \
    --column-annotation-has-header \
    --column-annotation-id-column="$colAnnoIdCol" \
    --column-annotation-name-column="$colAnnoNameCol" \
    --column-annotation-category-columns="$colAnnoCatCols" \
    --row-annotation="$rowAnnoMmuTmp" \
    --subset-directory="$subsetDirMmu" \
    --subset-glob="$subsetGlobMmu" \
    --subset-annotation="$subsetAnno" \
    --plot-file-format="$fileFormatUnfiltered" \
    --plot-key-x-label="$colorKeyXLabel" \
    --plot-color-median="white" \
    --plot-column-label-angle="$columnLabelAngle" \
    --plot-column-label-expansion-factor="$columnLabelCharExp" \
    --verbose \
    &>> "$logFile"

## CHIMPANZEE: UNFILTERED
echo "Plotting fold changes of chimpanzee comparisons by study ID and condition..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFilePtrByStudy" \
    --data-has-header \
    --column-id-prefix="$colPrefixPtr" \
    --run-id="$runIdPtr" \
    --output-directory="$outDirPtrUnfiltered" \
    --column-annotation="$colAnno" \
    --column-annotation-has-header \
    --column-annotation-id-column="$colAnnoIdCol" \
    --column-annotation-name-column="$colAnnoNameCol" \
    --column-annotation-category-columns="$colAnnoCatCols" \
    --row-annotation="$rowAnnoPtrTmp" \
    --subset-directory="$subsetDirPtr" \
    --subset-glob="$subsetGlobPtr" \
    --subset-annotation="$subsetAnno" \
    --plot-file-format="$fileFormatUnfiltered" \
    --plot-key-x-label="$colorKeyXLabel" \
    --plot-color-median="white" \
    --plot-column-label-angle="$columnLabelAngle" \
    --plot-column-label-expansion-factor="$columnLabelCharExp" \
    --verbose \
    &>> "$logFile"

## MERGED: UNFILTERED
echo "Plotting fold changes of comparisons across organisms by study ID and condition..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFileMergedByStudyTmp" \
    --data-has-header \
    --run-id="$runIdMerged" \
    --output-directory="$outDirMergedUnfiltered" \
    --column-annotation="$colAnno" \
    --column-annotation-has-header \
    --column-annotation-id-column="$colAnnoIdCol" \
    --column-annotation-name-column="$colAnnoNameColMerged" \
    --column-annotation-category-columns="$colAnnoCatCols" \
    --column-annotation-sidebar-color-category-column="$colAnnoSidebarColorCatCol" \
    --subset-directory="$subsetDirMerged" \
    --subset-glob="$subsetGlobMerged" \
    --subset-annotation="$subsetAnno" \
    --plot-file-format="$fileFormatUnfiltered" \
    --plot-key-x-label="$colorKeyXLabel" \
    --plot-color-median="white" \
    --plot-column-label-angle="$columnLabelAngle" \
    --plot-column-label-expansion-factor="$columnLabelCharExp" \
    --verbose \
    &>> "$logFile"


## HUMAN: FILTERED: MEAN FOLD CHANGE: 10x
echo "Plotting fold changes of human comparisons by study ID and condition..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFileHsaByStudy" \
    --data-has-header \
    --column-id-prefix="$colPrefixHsa" \
    --run-id="$runIdHsa" \
    --output-directory="$outDirHsaFold10" \
    --column-annotation="$colAnno" \
    --column-annotation-has-header \
    --column-annotation-id-column="$colAnnoIdCol" \
    --column-annotation-name-column="$colAnnoNameCol" \
    --column-annotation-category-columns="$colAnnoCatCols" \
    --row-annotation="$rowAnnoHsaTmp" \
    --subset-directory="$subsetDirHsa" \
    --subset-glob="$subsetGlobHsa" \
    --subset-annotation="$subsetAnno" \
    --threshold-rowmeans-above="$logThreshold" \
    --threshold-absolute-rowmeans \
    --plot-file-format="$fileFormatFiltered" \
    --plot-key-x-label="$colorKeyXLabel" \
    --plot-color-median="white" \
    --plot-column-label-angle="$columnLabelAngle" \
    --plot-column-label-expansion-factor="$columnLabelCharExp" \
    --verbose \
    &>> "$logFile"

## MOUSE: FILTERED: MEAN FOLD CHANGE: 10x
echo "Plotting fold changes of mouse comparisons by study ID and condition..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFileMmuByStudy" \
    --data-has-header \
    --column-id-prefix="$colPrefixMmu" \
    --run-id="$runIdMmu" \
    --output-directory="$outDirMmuFold10" \
    --column-annotation="$colAnno" \
    --column-annotation-has-header \
    --column-annotation-id-column="$colAnnoIdCol" \
    --column-annotation-name-column="$colAnnoNameCol" \
    --column-annotation-category-columns="$colAnnoCatCols" \
    --row-annotation="$rowAnnoMmuTmp" \
    --subset-directory="$subsetDirMmu" \
    --subset-glob="$subsetGlobMmu" \
    --subset-annotation="$subsetAnno" \
    --threshold-rowmeans-above="$logThreshold" \
    --threshold-absolute-rowmeans \
    --plot-file-format="$fileFormatFiltered" \
    --plot-key-x-label="$colorKeyXLabel" \
    --plot-color-median="white" \
    --plot-column-label-angle="$columnLabelAngle" \
    --plot-column-label-expansion-factor="$columnLabelCharExp" \
    --verbose \
    &>> "$logFile"

## CHIMPANZEE: FILTERED: MEAN FOLD CHANGE: 10x
echo "Plotting fold changes of chimpanzee comparisons by study ID and condition..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFilePtrByStudy" \
    --data-has-header \
    --column-id-prefix="$colPrefixPtr" \
    --run-id="$runIdPtr" \
    --output-directory="$outDirPtrFold10" \
    --column-annotation="$colAnno" \
    --column-annotation-has-header \
    --column-annotation-id-column="$colAnnoIdCol" \
    --column-annotation-name-column="$colAnnoNameCol" \
    --column-annotation-category-columns="$colAnnoCatCols" \
    --row-annotation="$rowAnnoPtrTmp" \
    --subset-directory="$subsetDirPtr" \
    --subset-glob="$subsetGlobPtr" \
    --subset-annotation="$subsetAnno" \
    --threshold-rowmeans-above="$logThreshold" \
    --threshold-absolute-rowmeans \
    --plot-file-format="$fileFormatFiltered" \
    --plot-key-x-label="$colorKeyXLabel" \
    --plot-color-median="white" \
    --plot-column-label-angle="$columnLabelAngle" \
    --plot-column-label-expansion-factor="$columnLabelCharExp" \
    --verbose \
    &>> "$logFile"

## MERGED: FILTERED: MEAN FOLD CHANGE: 10x
echo "Plotting fold changes of comparisons across organisms by study ID and condition..." >> "$logFile"
Rscript "$script" \
    --data-matrix="$inFileMergedByStudyTmp" \
    --data-has-header \
    --run-id="$runIdMerged" \
    --output-directory="$outDirMergedFold10" \
    --column-annotation="$colAnno" \
    --column-annotation-has-header \
    --column-annotation-id-column="$colAnnoIdCol" \
    --column-annotation-name-column="$colAnnoNameColMerged" \
    --column-annotation-category-columns="$colAnnoCatCols" \
    --column-annotation-sidebar-color-category-column="$colAnnoSidebarColorCatCol" \
    --subset-directory="$subsetDirMerged" \
    --subset-glob="$subsetGlobMerged" \
    --subset-annotation="$subsetAnno" \
    --threshold-rowmeans-above="$logThreshold" \
    --threshold-absolute-rowmeans \
    --threshold-rowmeans-per-column-sidebar-category="$logThresholdPerOrganism" \
    --plot-file-format="$fileFormatFiltered" \
    --plot-key-x-label="$colorKeyXLabel" \
    --plot-color-median="white" \
    --plot-column-label-angle="$columnLabelAngle" \
    --plot-column-label-expansion-factor="$columnLabelCharExp" \
    --verbose \
    &>> "$logFile"


#############
###  END  ###
#############

echo "Temporary data written to: $tmpDir" >> "$logFile"
echo "Output written to: $outDirRoot" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
