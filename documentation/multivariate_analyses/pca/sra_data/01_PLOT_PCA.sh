#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 10-JAN-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Do principal component analysis.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))))"

# Set script path
script="${root}/scriptsSoftware/multivariate_analyses/pca.R"

# Set input files
exprHsa="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/tpm/Homo_sapiens.genes.tpm"
exprMmu="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/tpm/Mus_musculus.genes.tpm"
exprPtr="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/tpm/Pan_troglodytes.genes.tpm"
anno="${root}/internalResources/sra_data/samples.annotations.tsv"
goDirRoot="${root}/publicResources/go_terms/members_per_term"
goDirHsa="${goDirRoot}/hsa"
goDirMmu="${goDirRoot}/mmu"
goDirPtr="${goDirRoot}/ptr"
goTerms="${root}/publicResources/go_terms/go_terms"

# Set output directories
outDirRoot="${root}/analyzedData/multivariate_analyses/pca/sra_data"
outDirHsa="${outDirRoot}/hsa"
outDirMmu="${outDirRoot}/mmu"
outDirPtr="${outDirRoot}/ptr"
logDir="${root}/logFiles/analyzedData/multivariate_analyses/pca/sra_data"

# Set other script parameters
runIdHsa="pca.hsa"
runIdMmu="pca.mmu"
runIdPtr="pca.ptr"
goGlobHsa="hsa.*.ensembl_gene_ids"
goGlobMmu="mmu.*.ensembl_gene_ids"
goGlobPtr="ptr.*.ensembl_gene_ids"
componentNo=3
idCol=1
repCol=7
colCatCol=8
symCatCol=2


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir -p "$outDirHsa" "$outDirMmu" "$outDirPtr"
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

# Do PCA: Human
echo "Running PCA: Human..." >> "$logFile"
Rscript "$script" \
    --expression="$exprHsa" \
    --output-directory="$outDirHsa" \
    --run-id="$runIdHsa" \
    --annotation="$anno" \
    --sample-id-column=$idCol \
    --replicate-column=$repCol \
    --color-category-column=$colCatCol \
    --symbol-category-column=$symCatCol \
    --subset-directory="$goDirHsa" \
    --subset-glob="$goGlobHsa" \
    --subset-annotation="$goTerms" \
    --plot-components $componentNo \
    --include-means \
    --write-tables \
    --verbose &>> "$logFile"

# Do PCA: Mouse
echo "Running PCA: Mouse..." >> "$logFile"
Rscript "$script" \
    --expression="$exprMmu" \
    --output-directory="$outDirMmu" \
    --run-id="$runIdMmu" \
    --annotation="$anno" \
    --sample-id-column=$idCol \
    --replicate-column=$repCol \
    --color-category-column=$colCatCol \
    --symbol-category-column=$symCatCol \
    --subset-directory="$goDirMmu" \
    --subset-glob="$goGlobMmu" \
    --subset-annotation="$goTerms" \
    --plot-components $componentNo \
    --include-means \
    --write-tables \
    --verbose &>> "$logFile"

# Do PCA: Chimpanzee
echo "Running PCA: Chimpanzee..." >> "$logFile"
Rscript "$script" \
    --expression="$exprPtr" \
    --output-directory="$outDirPtr" \
    --run-id="$runIdPtr" \
    --annotation="$anno" \
    --sample-id-column=$idCol \
    --replicate-column=$repCol \
    --color-category-column=$colCatCol \
    --symbol-category-column=$symCatCol \
    --subset-directory="$goDirPtr" \
    --subset-glob="$goGlobPtr" \
    --subset-annotation="$goTerms" \
    --plot-components $componentNo \
    --include-means \
    --write-tables \
    --verbose &>> "$logFile"


#############
###  END  ###
#############

echo "Output written to: $outDirRoot" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
