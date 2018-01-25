#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 20-FEB-2017                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Plot delta PSI heatmaps.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))))"

# Set script path
script="${root}/scriptsSoftware/generic/plot_heatmaps.R"

# Set input directories and files
inDirRoot="${root}/analyzedData/dsa/SUPPA/sra_data/merged"
genResRoot="${root}/publicResources/genome_resources"

# Set output directories
tmpDir="${root}/.tmp/analyzedData/dsa/heatmaps/sra_data"
outDirRoot="${root}/analyzedData/dsa/heatmaps/sra_data"
logDir="${root}/logFiles/analyzedData/dsa/heatmaps/sra_data"

# Set other parameters
declare -A orgs=( [hsa]="hsa.GRCh38_84" [mmu]="mmu.GRCm38_84" [ptr]="ptr.CHIMP2.1.4_84" )
declare -a events=(A3 A5 AF AL MX RI SE)
experiment="by_study_and_condition"
inSuffix="dpsi.tsv"
merged_org="merged"
merged_prefix="orthologous_genes"
unfiltered_suffix="unfiltered"
filtered_suffix="p_val_smaller_than_0-05"
colAnno="${root}/internalResources/sra_data/samples.comparisons.tsv"
colAnnoIdCol=3
colAnnoNameCol=8
colAnnoNameColMerged=9
colAnnoCatCols=6
colAnnoSidebarColorCatCol=5
threshold="0.1"
thresholdPerOrganism="or"
fileFormatUnfiltered="pdf"
fileFormatFiltered="svg"
colorKeyXLabel="Delta PSI"
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


## FOR INDIVIDUAL ORGANISMS

# Iterate over organism
for org in "${!orgs[@]}"; do

    # Get organims version
    org_version=${orgs[$org]}

    # Uncompress gene symbol lookup table
    echo "Extracting Ensembl gene identifier to gene symbol conversion table (organism: '$org')..." >> "$logFile"
    rowAnno="${genResRoot}/${org_version}/${org_version}.genes.id_to_symbol.tsv.gz"
    rowAnnoTmp="${tmpDir}/${org_version}.genes.id_to_symbol.tsv"
    gunzip --stdout "$rowAnno" > "$rowAnnoTmp"

    # Iterate over events
    for event in "${events[@]}"; do

        # Set parameters
        inFile="${inDirRoot}/${org}.${experiment}.${event}.${inSuffix}"
        outDirUnfiltered="${outDirRoot}/${org}/${experiment}/${unfiltered_suffix}"
        outDirFiltered="${outDirRoot}/${org}/${experiment}/${filtered_suffix}"
        colPrefix="${org}.${experiment}."
        runId="heatmap.${org}.${experiment}"

        # Plot heatmaps: unfiltered
        echo "Plotting delta PSIs by study ID and condition (organism: '$org'; data unfiltered)..." >> "$logFile"
        Rscript "$script" \
            --data-matrix="$inFile" \
            --data-has-header \
            --column-id-prefix="$colPrefix" \
            --run-id="$runId" \
            --output-directory="$outDirUnfiltered" \
            --column-annotation="$colAnno" \
            --column-annotation-has-header \
            --column-annotation-id-column="$colAnnoIdCol" \
            --column-annotation-name-column="$colAnnoNameCol" \
            --column-annotation-category-columns="$colAnnoCatCols" \
            --row-annotation="$rowAnnoTmp" \
            --plot-file-format="$fileFormatUnfiltered" \
            --plot-key-x-label="$colorKeyXLabel" \
            --plot-color-median="white" \
            --plot-column-label-angle="$columnLabelAngle" \
            --plot-column-label-expansion-factor="$columnLabelCharExp" \
            --verbose \
            &>> "$logFile"

        # Plot heatmaps: unfiltered
        echo "Plotting delta PSIs by study ID and condition (organism: '$org'; data filtered)..." >> "$logFile"
        Rscript "$script" \
            --data-matrix="$inFile" \
            --data-has-header \
            --column-id-prefix="$colPrefix" \
            --run-id="$runId" \
            --output-directory="$outDirFiltered" \
            --column-annotation="$colAnno" \
            --column-annotation-has-header \
            --column-annotation-id-column="$colAnnoIdCol" \
            --column-annotation-name-column="$colAnnoNameCol" \
            --column-annotation-category-columns="$colAnnoCatCols" \
            --row-annotation="$rowAnnoTmp" \
            --threshold-rowmeans-above="$threshold" \
            --threshold-absolute-rowmeans \
            --plot-file-format="$fileFormatFiltered" \
            --plot-key-x-label="$colorKeyXLabel" \
            --plot-color-median="white" \
            --plot-column-label-angle="$columnLabelAngle" \
            --plot-column-label-expansion-factor="$columnLabelCharExp" \
            --verbose \
            &>> "$logFile"

    done

done


## MERGED

org="$merged_org"

# Iterate over events
for event in "${events[@]}"; do

    # Set parameters
    inFile="${inDirRoot}/${merged_prefix}/${org}.${experiment}.${event}.${merged_prefix}.${inSuffix}"
    outDirUnfiltered="${outDirRoot}/${org}/${experiment}/${unfiltered_suffix}"
    outDirFiltered="${outDirRoot}/${org}/${experiment}/${filtered_suffix}"
    colPrefix="${org}.${experiment}."
    runId="heatmap.${org}.${experiment}"

    # Process merged input table
    echo "Processing input table for analysis across organisms..." >> "$logFile"
    inFileTmp="${tmpDir}/${org}.${merged_prefix}.header_processed.${event}.${inSuffix}"
    sed -r 's/(hsa|mmu|ptr)\.by_study_and_condition\.//g' "$inFile" > "$inFileTmp"

    # Plot heatmaps: unfiltered
    echo "Plotting delta PSIs by study ID and condition (organisms merged; data unfiltered)..." >> "$logFile"
    Rscript "$script" \
        --data-matrix="$inFile" \
        --data-has-header \
        --run-id="$runId" \
        --output-directory="$outDirUnfiltered" \
        --column-annotation="$colAnno" \
        --column-annotation-has-header \
        --column-annotation-id-column="$colAnnoIdCol" \
        --column-annotation-name-column="$colAnnoNameColMerged" \
        --column-annotation-category-columns="$colAnnoCatCols" \
        --column-annotation-sidebar-color-category-column="$colAnnoSidebarColorCatCol" \
        --plot-file-format="$fileFormatUnfiltered" \
        --plot-key-x-label="$colorKeyXLabel" \
        --plot-color-median="white" \
        --plot-column-label-angle="$columnLabelAngle" \
        --plot-column-label-expansion-factor="$columnLabelCharExp" \
        --verbose \
        &>> "$logFile"

    # Plot heatmaps: filtered
    echo "Plotting delta PSIs by study ID and condition (organisms merged; data unfiltered)..." >> "$logFile"
    Rscript "$script" \
        --data-matrix="$inFile" \
        --data-has-header \
        --run-id="$runId" \
        --output-directory="$outDirFiltered" \
        --column-annotation="$colAnno" \
        --column-annotation-has-header \
        --column-annotation-id-column="$colAnnoIdCol" \
        --column-annotation-name-column="$colAnnoNameColMerged" \
        --column-annotation-category-columns="$colAnnoCatCols" \
        --column-annotation-sidebar-color-category-column="$colAnnoSidebarColorCatCol" \
        --threshold-rowmeans-above="$threshold" \
        --threshold-absolute-rowmeans \
        --threshold-rowmeans-per-column-sidebar-category="$thresholdPerOrganism" \
        --plot-file-format="$fileFormatFiltered" \
        --plot-key-x-label="$colorKeyXLabel" \
        --plot-color-median="white" \
        --plot-column-label-angle="$columnLabelAngle" \
        --plot-column-label-expansion-factor="$columnLabelCharExp" \
        --verbose \
        &>> "$logFile"

done


#############
###  END  ###
#############

echo "Temporary data written to: $tmpDir" >> "$logFile"
echo "Output written to: $outDirRoot" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
