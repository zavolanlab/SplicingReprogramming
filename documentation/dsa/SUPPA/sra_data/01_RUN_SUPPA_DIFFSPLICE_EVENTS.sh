#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 07-FEB-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Runs differential splicing analysis with SUPPA.


######################
###  DEPENDENCIES  ###
######################

# SUPPA 2.2.0


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))))"

commands="$root/commands_SUPPA_diffSplice"

# Set input files
sampleAnno="${root}/internalResources/sra_data/samples.annotations.tsv"
sampleComp="${root}/internalResources/sra_data/samples.comparisons.tsv"
ioeDirHsa="${root}/publicResources/genome_resources/hsa.GRCh38_84/indices/SUPPA/hsa.GRCh38_84.gene_annotations.filtered"
ioeDirMmu="${root}/publicResources/genome_resources/mmu.GRCm38_84/indices/SUPPA/mmu.GRCm38_84.gene_annotations.filtered"
ioeDirPtr="${root}/publicResources/genome_resources/ptr.CHIMP2.1.4_84/indices/SUPPA/ptr.CHIMP2.1.4_84.gene_annotations.filtered"
tpmHsa="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/tpm/Homo_sapiens.transcripts.tpm"
tpmMmu="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/tpm/Mus_musculus.transcripts.tpm"
tpmPtr="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/tpm/Pan_troglodytes.transcripts.tpm"

# Set output directories
outDirRoot="${root}/analyzedData/dsa/SUPPA/sra_data/events"
tmpDir="${root}/.tmp/analyzedData/dsa/SUPPA/sra_data/events"
logDir="${root}/logFiles/analyzedData/dsa/SUPPA/sra_data/events"

# Set other parameters
ioeGlob=_??_strict.ioe
psiPrefix="${root}/analyzedData/align_and_quantify/sra_data/merged/alternative_splicing/events"
psiSuffixHsa="psi/Homo_sapiens.alternative_splicing_events"
psiSuffixMmu="psi/Mus_musculus.alternative_splicing_events"
psiSuffixPtr="psi/Pan_troglodytes.alternative_splicing_events"
psiExt="psi"
SUPPA_method="empirical"
SUPPA_area=1000


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir -p "$tmpDir"
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
#rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

## BY STUDY AND CONDITION

# Create temporary directory
tmpDirSubsets="$tmpDir/subsets_by_study_and_condition"
rm -rf "$tmpDirSubsets"
mkdir -p "$tmpDirSubsets"

# Backup input field separator
IFS_bak=$IFS

# Iterate over comparisons file
while read line; do

    # Get organism
    ref=$(cut -f2 <(echo "$line"))
    query=$(cut -f1 <(echo "$line"))
    name=$(cut -f3 <(echo "$line"))
    org=$(cut -f5 <(echo "$line"))

    # Get sample IDs for reference and query
    ref_ids=( $(awk -v nm="$ref" '$2"."$4"."$6 == nm {print $1}' "$sampleAnno") )
    query_ids=( $(awk -v nm="$query" '$2"."$4"."$6 == nm {print $1}' "$sampleAnno") )

    # Set organism-specific event, PSI and TPM files
    case "$org" in
    "Homo_sapiens")
        ioeDir="$ioeDirHsa"
        tpm="$tpmHsa"
        psiSuffix="$psiSuffixHsa"
        ;;
    "Mus_musculus")
        ioeDir="$ioeDirMmu"
        tpm="$tpmMmu"
        psiSuffix="$psiSuffixMmu"
        ;;
    "Pan_troglodytes")
        ioeDir="$ioeDirPtr"
        tpm="$tpmPtr"
        psiSuffix="$psiSuffixPtr"
        ;;
    *)
        echo "[ERROR] No event files available for organism '$org'. Execution aborted." >> "$logFile"
        exit 1
    esac

    # Iterate over event files
    for ioe in "${ioeDir}/"$ioeGlob; do

        # Get event identifier
        event=$(echo $(basename "$ioe") | cut -f2 -d "_")

        # Write log message
        echo "Running SUPPA diffSplice; organism: '$org'; event type: '$event'; comparison: '$name'" >> "$logFile"

        # Get PSI file
        psi="${psiPrefix}/${event}/${psiSuffix}.${event}.${psiExt}"
if [ ! -f "$psi" ]; then echo "WHAT?!!"; fi

        # Set input field separator
        IFS=$'\t'

        # Get headers for reference and query
        refHead=$(echo "${ref_ids[*]}")
        queryHead=$(echo "${query_ids[*]}")

        # Set input field separator
        IFS=$'\n'

                    # Subset TPM file: reference
                    refTpm="${tmpDirSubsets}/${ref}.tpm"
                    if [ ! -f "$refTpm" ]; then
                        refIdxTpm=( $(awk 'BEGIN {ORS="\n"} NR == FNR { ids[NR] = $1; next } { for (i = 1; i <= length(ids); i++) { for (fld = 1; fld <= NF; fld++) { if ($fld == ids[i]) { print fld + 1 } } } }' <(echo "${ref_ids[*]}") <(head -1 "$tpm")) )
                        echo "$refHead" > "$refTpm"
                        awk 'NR == FNR { idx[NR] = $1; next } { out=$1; for (i = 1; i <= length(idx); i++) { out=out"\t"$idx[i] }; print out }' <(echo "${refIdxTpm[*]}") <(tail -n +2 "$tpm") >> "$refTpm"
                    fi

                    # Subset TPM file: query
                    queryTpm="${tmpDirSubsets}/${query}.tpm"
                    if [ ! -f "$queryTpm" ]; then
                        queryIdxTpm=( $(awk 'BEGIN {ORS="\n"} NR == FNR { ids[NR] = $1; next } { for (i = 1; i <= length(ids); i++) { for (fld = 1; fld <= NF; fld++) { if ($fld == ids[i]) { print fld + 1 } } } }' <(echo "${query_ids[*]}") <(head -1 "$tpm")) )
                        echo "$queryHead" > "$queryTpm"
                        awk 'NR == FNR { idx[NR] = $1; next } { out=$1; for (i = 1; i <= length(idx); i++) { out=out"\t"$idx[i] }; print out }' <(echo "${queryIdxTpm[*]}") <(tail -n +2 "$tpm") >> "$queryTpm"
                    fi

                    # Subset PSI file: reference
                    refPsi="${tmpDirSubsets}/${ref}.${event}.psi"
                    if [ ! -f "$refPsi" ]; then
                        refIdxPsi=( $(awk 'BEGIN {ORS="\n"} NR == FNR { ids[NR] = $1; next } { for (i = 1; i <= length(ids); i++) { for (fld = 1; fld <= NF; fld++) { if ($fld == ids[i]) { print fld + 1 } } } }' <(echo "${ref_ids[*]}") <(head -1 "$psi")) )
                        echo "$refHead" > "$refPsi"
                        awk 'NR == FNR { idx[NR] = $1; next } { out=$1; for (i = 1; i <= length(idx); i++) { out=out"\t"$idx[i] }; print out }' <(echo "${refIdxPsi[*]}") <(tail -n +2 "$psi") >> "$refPsi"
                    fi

                    # Subset PSI file: query
                    queryPsi="${tmpDirSubsets}/${query}.${event}.psi"
                    if [ ! -f "$queryPsi" ]; then
                        queryIdxPsi=(  $(awk 'NR == FNR { ids[NR] = $1; next } { for (i = 1; i <= length(ids); i++) { for (fld = 1; fld <= NF; fld++) { if ($fld == ids[i]) { print fld + 1 } } } }' <(echo "${query_ids[*]}") <(head -1 "$psi")) )
                        echo "$queryHead" > "$queryPsi"
                        awk 'NR == FNR { idx[NR] = $1; next } { out=$1; for (i = 1; i <= length(idx); i++) { out=out"\t"$idx[i] }; print out }' <(echo "${queryIdxPsi[*]}") <(tail -n +2 "$psi") >> "$queryPsi"
                    fi

                    # Restore input field separator
                    IFS=$IFS_bak

                    # Build output directory
                    outDir="${outDirRoot}/${org}/by_study_and_condition/${name}.${event}"

                    # Create output directory
                    mkdir -p "$outDir"

                    # Build SUPPA output prefix
                    SUPPA_outPrefix="${outDir}/${name}.${event}"

                    # Run SUPPA diffSplice
                    echo "significanceCalculator.py --method \"$SUPPA_method\" --input \"$ioe\" --psi \"$refPsi\" \"$queryPsi\" --tpm \"$refTpm\" \"$queryTpm\" --area \"$SUPPA_area\" -gc --output \"$SUPPA_outPrefix\"" &>> "$commands"

    done

done < <(tail -n +2 "$sampleComp")


#############
###  END  ###
#############

echo "Output written to: $outDirRoot" >> "$logFile"
echo "Temporary files written to: $tmpDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
