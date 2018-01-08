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

# Set input files
sampleAnno="${root}/internalResources/sra_data/samples.annotations.tsv"
sampleComp="${root}/internalResources/sra_data/samples.comparisons.tsv"
#TODO: ioiHsa="${root}/publicResources/genome_resources/hsa.GRCh38_84/indices/SUPPA/hsa.GRCh38_84.gene_annotations.filtered"
#TODO: ioiMmu="${root}/publicResources/genome_resources/mmu.GRCm38_84/indices/SUPPA/mmu.GRCm38_84.gene_annotations.filtered"
#TODO: ioiPtr="${root}/publicResources/genome_resources/ptr.CHIMP2.1.4_84/indices/SUPPA/ptr.CHIMP2.1.4_84.gene_annotations.filtered"
tpmHsa="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/tpm/Homo_sapiens.transcripts.tpm"
tpmMmu="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/tpm/Mus_musculus.transcripts.tpm"
tpmPtr="${root}/analyzedData/align_and_quantify/sra_data/merged/abundances/tpm/Pan_troglodytes.transcripts.tpm"

# Set output directories
outDirRoot="${root}/analyzedData/dsa/SUPPA/sra_data/isoforms"
tmpDir="${root}/.tmp/analyzedData/dsa/SUPPA/sra_data/isoforms"
logDir="${root}/logFiles/analyzedData/dsa/SUPPA/sra_data/isoforms"

# Set other parameters
psiPrefix="${root}/analyzedData/align_and_quantify/sra_data/merged/alternative_splicing/isoforms/psi"
psiSuffixHsa="Homo_sapiens.transcripts"
psiSuffixMmu="Mus_musculus.transcripts"
psiSuffixPtr="Pan_troglodytes.transcripts"
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
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

## BY STUDY AND CONDITION

# Create temporary directory
tmpDirSubsets="$tmpDir/subsets_by_study_and_condition"
#TODO: Uncomment rm -rf "$tmpDirSubsets"
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

    # Set organism-specific index, PSI and TPM files
    case "$org" in
    "Homo_sapiens")
        ioi="$ioiHsa"
        tpm="$tpmHsa"
        psi="${psiPrefix}/${psiSuffixHsa}.${psiExt}"
        ;;
    "Mus_musculus")
        ioi="$ioiMmu"
        tpm="$tpmMmu"
        psi="${psiPrefix}/${psiSuffixMmu}.${psiExt}"
        ;;
    "Pan_troglodytes")
        ioi="$ioiPtr"
        tpm="$tpmPtr"
        psi="${psiPrefix}/${psiSuffixPtr}.${psiExt}"
        ;;
    *)
        echo "[ERROR] No transcript files available for organism '$org'. Execution aborted." >> "$logFile"
        exit 1
    esac

    # Write log message
    echo "Running SUPPA diffSplice for transcript isoforms; organism: '$org'; comparison: '$name'" >> "$logFile"

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
    refPsi="${tmpDirSubsets}/${ref}.psi"
    if [ ! -f "$refPsi" ]; then
        refIdxPsi=( $(awk 'BEGIN {ORS="\n"} NR == FNR { ids[NR] = $1; next } { for (i = 1; i <= length(ids); i++) { for (fld = 1; fld <= NF; fld++) { if ($fld == ids[i]) { print fld + 1 } } } }' <(echo "${ref_ids[*]}") <(head -1 "$psi")) )
        echo "$refHead" > "$refPsi"
        awk 'NR == FNR { idx[NR] = $1; next } { out=$1; for (i = 1; i <= length(idx); i++) { out=out"\t"$idx[i] }; print out }' <(echo "${refIdxPsi[*]}") <(tail -n +2 "$psi") >> "$refPsi"
    fi

    # Subset PSI file: query
    queryPsi="${tmpDirSubsets}/${query}.psi"
    if [ ! -f "$queryPsi" ]; then
        queryIdxPsi=(  $(awk 'NR == FNR { ids[NR] = $1; next } { for (i = 1; i <= length(ids); i++) { for (fld = 1; fld <= NF; fld++) { if ($fld == ids[i]) { print fld + 1 } } } }' <(echo "${query_ids[*]}") <(head -1 "$psi")) )
        echo "$queryHead" > "$queryPsi"
        awk 'NR == FNR { idx[NR] = $1; next } { out=$1; for (i = 1; i <= length(idx); i++) { out=out"\t"$idx[i] }; print out }' <(echo "${queryIdxPsi[*]}") <(tail -n +2 "$psi") >> "$queryPsi"
    fi

    # Restore input field separator
    IFS=$IFS_bak

    # Build output directory
    outDir="${outDirRoot}/${org}/by_study_and_condition/${name}"

    # Create output directory
    mkdir -p "$outDir"

    # Build SUPPA output prefix
    SUPPA_outPrefix="${outDir}/${name}"

    # Run SUPPA diffSplice
    #TODO: Write qsub commands temporarily, but leave just command in general
    # echo "significanceCalculator.py --method \"$SUPPA_method\" --input \"$ioi\" --psi \"$refPsi\" 
    # \"$queryPsi\" --tpm \"$refTpm\" \"$queryTpm\" --area \"$SUPPA_area\" -gc --output 
    # \"$SUPPA_outPrefix\"" &>> "$logFile"
    #significanceCalculator.py --method "$SUPPA_method" --input "$ioi" --psi "$refPsi" "$queryPsi" --tpm "$refTpm" "$queryTpm" --area "$SUPPA_area" -gc --output "$SUPPA_outPrefix" &>> "$logFile"

done < <(tail -n +2 "$sampleComp")


## BY CELL TYPE ONLY

# Create temporary directory
tmpDirSubsets="$tmpDir/subsets_by_cell_type_only"
#TODO: Uncomment rm -rf "$tmpDirSubsets"
mkdir -p "$tmpDirSubsets"

# Backup input field separator
IFS_bak=$IFS

# Get unique organims
orgs=( $(tail -n +2 "$sampleAnno" | cut -f4 | sort -u) )

# Iterate over organisms
for org in "${orgs[@]}"; do

    # Set organism-specific index, PSI and TPM files
    case "$org" in
    "Homo_sapiens")
        ioi="$ioiHsa"
        tpm="$tpmHsa"
        psi="${psiPrefix}/${psiSuffixHsa}.${psiExt}"
        ;;
    "Mus_musculus")
        ioi="$ioiMmu"
        tpm="$tpmMmu"
        psi="${psiPrefix}/${psiSuffixMmu}.${psiExt}"
        ;;
    "Pan_troglodytes")
        ioi="$ioiPtr"
        tpm="$tpmPtr"
        psi="${psiPrefix}/${psiSuffixPtr}.${psiExt}"
        ;;
    *)
        echo "[ERROR] No transcript files available for organism '$org'. Execution aborted." >> "$logFile"
        exit 1
    esac

    # Set input field separator
    IFS=$'\n'

    # Get unique cell types
    types=( $(tail -n +2 "$sampleAnno" | awk -v org="$org" '$4 == org' | cut -f7 | sort -u) )

    # Restore input field separator
    IFS=$IFS_bak

    # Iterate over cell types to obtain reference
    for rType in "${types[@]}"; do

        # Set input field separator
        IFS=$'\n'

        # Extract sample IDs of samples with current organism and cell type
        ref=( $(tail -n +2 "$sampleAnno" | awk -v org="$org" -v type="$rType" '$4 == org && $7 == type { print $1 }') )

        # Restore input field separator
        IFS=$IFS_bak

        # Iterate over cell types to obtain query
        for qType in "${types[@]}"; do

            # Set input field separator
            IFS=$'\n'

            # Extract sample IDs of samples with current organism and cell type
            query=( $(tail -n +2 "$sampleAnno" | awk -v org="$org" -v type="$qType" '$4 == org && $7 == type { print $1 }') )

            # Restore input field separator
            IFS=$IFS_bak

            # Continue with comparison only if reference and query are not equal
            if [ ! "$ref" == "$query" ] ; then

                # Write log message
                echo "Running SUPPA diffSplice for transcript isoforms; organism: '$org'; query: '$qType'; reference: '$rType'" >> "$logFile"

                # Build output file prefix
                tmpPrefix="${tmpDirSubsets}/${org}"

                # Set input field separator
                IFS=$'\t'

                # Get headers for reference and query
                refHead=$(echo "${ref[*]}")
                queryHead=$(echo "${query[*]}")

                # Set input field separator
                IFS=$'\n'

                # Subset TPM file: reference
                refTpm="${tmpPrefix}.${rType}.tpm"
                if [ ! -f "$refTpm" ]; then
                    refIdxTpm=( $(awk 'BEGIN {ORS="\n"} NR == FNR { ids[NR] = $1; next } { for (i = 1; i <= length(ids); i++) { for (fld = 1; fld <= NF; fld++) { if ($fld == ids[i]) { print fld + 1 } } } }' <(echo "${ref[*]}") <(head -1 "$tpm")) )
                    echo "$refHead" > "$refTpm"
                    awk 'NR == FNR { idx[NR] = $1; next } { out=$1; for (i = 1; i <= length(idx); i++) { out=out"\t"$idx[i] }; print out }' <(echo "${refIdxTpm[*]}") <(tail -n +2 "$tpm") >> "$refTpm"
                fi

                # Subset TPM file: query
                queryTpm="${tmpPrefix}.${qType}.tpm"
                if [ ! -f "$queryTpm" ]; then
                    queryIdxTpm=( $(awk 'BEGIN {ORS="\n"} NR == FNR { ids[NR] = $1; next } { for (i = 1; i <= length(ids); i++) { for (fld = 1; fld <= NF; fld++) { if ($fld == ids[i]) { print fld + 1 } } } }' <(echo "${query[*]}") <(head -1 "$tpm")) )
                    echo "$queryHead" > "$queryTpm"
                    awk 'NR == FNR { idx[NR] = $1; next } { out=$1; for (i = 1; i <= length(idx); i++) { out=out"\t"$idx[i] }; print out }' <(echo "${queryIdxTpm[*]}") <(tail -n +2 "$tpm") >> "$queryTpm"
                fi

                # Subset PSI file: reference
                refPsi="${tmpPrefix}.${rType}.psi"
                if [ ! -f "$refPsi" ]; then
                    refIdxPsi=( $(awk 'BEGIN {ORS="\n"} NR == FNR { ids[NR] = $1; next } { for (i = 1; i <= length(ids); i++) { for (fld = 1; fld <= NF; fld++) { if ($fld == ids[i]) { print fld + 1 } } } }' <(echo "${ref[*]}") <(head -1 "$psi")) )
                    echo "$refHead" > "$refPsi"
                    awk 'NR == FNR { idx[NR] = $1; next } { out=$1; for (i = 1; i <= length(idx); i++) { out=out"\t"$idx[i] }; print out }' <(echo "${refIdxPsi[*]}") <(tail -n +2 "$psi") >> "$refPsi"
                fi

                # Subset PSI file: query
                queryPsi="${tmpPrefix}.${qType}.psi"
                if [ ! -f "$queryPsi" ]; then
                    queryIdxPsi=(  $(awk 'NR == FNR { ids[NR] = $1; next } { for (i = 1; i <= length(ids); i++) { for (fld = 1; fld <= NF; fld++) { if ($fld == ids[i]) { print fld + 1 } } } }' <(echo "${query[*]}") <(head -1 "$psi")) )
                    echo "$queryHead" > "$queryPsi"
                    awk 'NR == FNR { idx[NR] = $1; next } { out=$1; for (i = 1; i <= length(idx); i++) { out=out"\t"$idx[i] }; print out }' <(echo "${queryIdxPsi[*]}") <(tail -n +2 "$psi") >> "$queryPsi"
                fi

                # Restore input field separator
                IFS=$IFS_bak

                # Build output directory
                comparison="${org}.${qType}.over.${org}.${rType}"
                outDir="${outDirRoot}/${org}/by_cell_type_only/${comparison}"

                # Create output directory
                mkdir -p "$outDir"

                # Build SUPPA output prefix
                SUPPA_outPrefix="${outDir}/${comparison}"

                # Build job-related names & paths
                jobName="iso.${qType}.vs.${rType}"
                logDirJobs="${logDir}/jobs"
                mkdir -p "$logDirJobs"
                stdout="${logDirJobs}/${comparison}.out"
                stderr="${logDirJobs}/${comparison}.out"

                # Run SUPPA diffSplice
                #TODO: Write qsub commands temporarily, but leave just command in general
                #echo "significanceCalculator.py --method \"$SUPPA_method\" --input \"$ioi\" --psi \"$refPsi\" \"$queryPsi\" --tpm \"$refTpm\" \"$queryTpm\" --area \"$SUPPA_area\" -gc --output \"$SUPPA_outPrefix\"" &>> "$logFile"
                #significanceCalculator.py --method "$SUPPA_method" --input "$ioi" --psi "$refPsi" "$queryPsi" --tpm "$refTpm" "$queryTpm" --area "$SUPPA_area" -gc --output "$SUPPA_outPrefix" &>> "$logFile"

            fi

        done

    done

done

# Restore input field separator
IFS=$IFS_bak


#############
###  END  ###
#############

echo "Output written to: $outDirRoot" >> "$logFile"
echo "Temporary files written to: $tmpDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
