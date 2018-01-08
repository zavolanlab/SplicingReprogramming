#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 13-JUN-2017                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Runs gene set enrichment analyses on lists of differentially expressed, up- and downregulated 
# genes with ontologizer.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))))"

# Set script
ontologizer="${root}/scriptsSoftware/ontologizer/Ontologizer.jar"

# Set calculation method
calc="Term-For-Term"

# Set obo file
oboRaw="${root}/publicResources/go_terms/go.2016-03-01.obo.gz"

# Set gene annotation files
gafHsa="${root}/publicResources/genome_resources/ensembl_84/go_terms/hsa/ensembl_84.go_terms.hsa.gaf.gz"
gafMmu="${root}/publicResources/genome_resources/ensembl_84/go_terms/mmu/ensembl_84.go_terms.mmu.gaf.gz"
gafPtr="${root}/publicResources/genome_resources/ensembl_84/go_terms/ptr/ensembl_84.go_terms.ptr.gaf.gz"

# Set input root directories
inDirRoot="${root}/analyzedData/dgea/edgeR/sra_data"
inDirHsa="${inDirRoot}/hsa/by_study_and_condition"
inDirMmu="${inDirRoot}/mmu/by_study_and_condition"
inDirPtr="${inDirRoot}/ptr/by_study_and_condition"

# Set output root directories
tmpDir="${root}/.tmp/analyzedData/dgea/gsea/sra_data"
logDir="${root}/logFiles/analyzedData/dgea/gsea/sra_data"
outDirRoot="${root}/analyzedData/dgea/gsea/sra_data"
outDirHsa="${outDirRoot}/hsa"
outDirMmu="${outDirRoot}/mmu"
outDirPtr="${outDirRoot}/ptr"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir -p "$outDirRoot"
mkdir -p "$outDirHsa" "$outDirMmu" "$outDirPtr"
mkdir -p "$tmpDir"
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

# Extract OBO file
echo "Extracting OBO file..." >> "$logFile"
obo="${tmpDir}/go.obo"
zcat "$oboRaw" > "$obo"

# Iterate over experiments
echo "Iterating over human DGEAs..." >> "$logFile"
for dir in "${inDirHsa}/"*"/"; do

    # Set organism specific parameters
    outDir="$outDirHsa"
    prefix="hsa.by_study_and_condition"
    gaf="$gafHsa"

    # Get experiment identifier
    exp=$(basename "$dir")

    # Create output directories
    outDir_exp="${outDir}/${exp}"
    mkdir -p "$outDir_exp"
    outDir_de="${outDir_exp}/de"
    outDir_up="${outDir_exp}/up"
    outDir_dw="${outDir_exp}/down"
    mkdir -p "$outDir_de" "$outDir_up" "$outDir_dw"

    # Find lists of gene identifiers
    bg="${dir}/${prefix}.${exp}.all.ids.tsv"
    de="${dir}/${prefix}.${exp}.differentially_expressed.ids.tsv"
    up="${dir}/${prefix}.${exp}.up.ids.tsv"
    dw="${dir}/${prefix}.${exp}.down.ids.tsv"

    # Run GO term analysis: DE, up, down
    echo "Running GSEA for experiment '$exp'..." >> "$logFile"
    java -jar "$ontologizer" --calculation "$calc" --association "$gaf" --dot --go "$obo" --mtc "Benjamini-Hochberg" --annotation --outdir "$outDir_de" --population "$bg" --studyset "$de" &>> "$logFile"
    java -jar "$ontologizer" --calculation "$calc" --association "$gaf" --dot --go "$obo" --mtc "Benjamini-Hochberg" --annotation --outdir "$outDir_up" --population "$bg" --studyset "$up" &>> "$logFile"
    java -jar "$ontologizer" --calculation "$calc" --association "$gaf" --dot --go "$obo" --mtc "Benjamini-Hochberg" --annotation --outdir "$outDir_dw" --population "$bg" --studyset "$dw" &>> "$logFile"

done

# Iterate over experiments
echo "Iterating over mouse DGEAs..." >> "$logFile"
for dir in "${inDirMmu}/"*"/"; do

    # Set organism specific parameters
    outDir="$outDirMmu"
    prefix="mmu.by_study_and_condition"
    gaf="$gafMmu"

    # Get experiment identifier
    exp=$(basename "$dir")

    # Create output directories
    outDir_exp="${outDir}/${exp}"
    mkdir -p "$outDir_exp"
    outDir_de="${outDir_exp}/de"
    outDir_up="${outDir_exp}/up"
    outDir_dw="${outDir_exp}/down"
    mkdir -p "$outDir_de" "$outDir_up" "$outDir_dw"

    # Find lists of gene identifiers
    bg="${dir}/${prefix}.${exp}.all.ids.tsv"
    de="${dir}/${prefix}.${exp}.differentially_expressed.ids.tsv"
    up="${dir}/${prefix}.${exp}.up.ids.tsv"
    dw="${dir}/${prefix}.${exp}.down.ids.tsv"

    # Run GO term analysis: DE, up, down
    java -jar "$ontologizer" --calculation "$calc" --association "$gaf" --dot --go "$obo" --mtc "Benjamini-Hochberg" --annotation --outdir "$outDir_de" --population "$bg" --studyset "$de" &>> "$logFile"
    java -jar "$ontologizer" --calculation "$calc" --association "$gaf" --dot --go "$obo" --mtc "Benjamini-Hochberg" --annotation --outdir "$outDir_up" --population "$bg" --studyset "$up" &>> "$logFile"
    java -jar "$ontologizer" --calculation "$calc" --association "$gaf" --dot --go "$obo" --mtc "Benjamini-Hochberg" --annotation --outdir "$outDir_dw" --population "$bg" --studyset "$dw" &>> "$logFile"

done

# Iterate over experiments
echo "Iterating over chimpanzee DGEAs..." >> "$logFile"
for dir in "${inDirPtr}/"*"/"; do

    # Set organism specific parameters
    outDir="$outDirPtr"
    prefix="ptr.by_study_and_condition"
    gaf="$gafPtr"

    # Get experiment identifier
    exp=$(basename "$dir")

    # Create output directories
    outDir_exp="${outDir}/${exp}"
    mkdir -p "$outDir_exp"
    outDir_de="${outDir_exp}/de"
    outDir_up="${outDir_exp}/up"
    outDir_dw="${outDir_exp}/down"
    mkdir -p "$outDir_de" "$outDir_up" "$outDir_dw"

    # Find lists of gene identifiers
    bg="${dir}/${prefix}.${exp}.all.ids.tsv"
    de="${dir}/${prefix}.${exp}.differentially_expressed.ids.tsv"
    up="${dir}/${prefix}.${exp}.up.ids.tsv"
    dw="${dir}/${prefix}.${exp}.down.ids.tsv"

    # Run GO term analysis: DE, up, down
    java -jar "$ontologizer" --calculation "$calc" --association "$gaf" --dot --go "$obo" --mtc "Benjamini-Hochberg" --annotation --outdir "$outDir_de" --population "$bg" --studyset "$de" &>> "$logFile"
    java -jar "$ontologizer" --calculation "$calc" --association "$gaf" --dot --go "$obo" --mtc "Benjamini-Hochberg" --annotation --outdir "$outDir_up" --population "$bg" --studyset "$up" &>> "$logFile"
    java -jar "$ontologizer" --calculation "$calc" --association "$gaf" --dot --go "$obo" --mtc "Benjamini-Hochberg" --annotation --outdir "$outDir_dw" --population "$bg" --studyset "$dw" &>> "$logFile"

done


#############
###  END  ###
#############

echo "Output written to: $outDirRoot" >> "$logFile"
echo "Temporary files written to: $tmpDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
