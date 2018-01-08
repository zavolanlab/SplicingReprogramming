#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 30-NOV-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Gets genes corresponding to a list of GO terms

###########################################################################
# THE RESULTS OF THIS SCRIPT MAY NOT BE REPRODUCIBLE AS THE CURRENT STATE #
# OF THE GO DATABASE IS QUERIED!                                          #
# RUN DATE: 2017-06-28                                                    #
###########################################################################

####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))"

# Set organisms
declare -A organisms=( [hsa]="Homo sapiens" [mmu]="Mus musculus" [ptr]="Pan troglodytes" )

# Set GO terms file
goTerms="${root}/internalResources/sra_data/go_terms"

# Set Ensembl gene ID > gene symbols lookup files
declare -A idTables=( [hsa]="${root}/publicResources/genome_resources/hsa.GRCh38_84/hsa.GRCh38_84.transcripts.tsv.gz" [mmu]="${root}/publicResources/genome_resources/mmu.GRCm38_84/mmu.GRCm38_84.transcripts.tsv.gz" [ptr]="${root}/publicResources/genome_resources/ptr.CHIMP2.1.4_84/ptr.CHIMP2.1.4_84.transcripts.tsv.gz" )
commonSymbols="${root}/publicResources/genome_resources/ensembl_84/orthologous_genes/ensembl_84.orthologous_genes.gene_IDs.common_gene_symbols.tsv.gz"
declare -A idCols=( [hsa]=1 [mmu]=2 [ptr]=3 )
commonSymCol=7

# Set output directories
outDir="${root}/publicResources/go_terms/members_per_term"
outDirUnion="${outDir}/union"
tmpDir="${root}/.tmp/publicResources/go_terms"
logDir="${root}/logFiles/publicResources/go_terms"

# GO URL fragments
url_start="http://golr.geneontology.org/select?defType=edismax&wt=csv&rows=100000&csv.separator=%09&csv.header=false&csv.mv.separator=%7C&fl=source,bioentity_internal_id,bioentity_label,qualifier,annotation_class,reference,evidence_type,evidence_with,aspect,bioentity_name,bioentity,synonym,type,taxon,date,assigned_by,annotation_extension_class,bioentity_isoform&fq=document_category:%22annotation%22&qf=annotation_class%5E2&qf=regulates_closure%5E1&fq=taxon_subset_closure_label:%22"
url_mid="%22&q=GO:"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir --parents "$outDir"
mkdir --parents "$outDirUnion"
mkdir --parents "$tmpDir"
mkdir --parents "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

## DOWNLOAD GO DATA FOR EACH TERM

# Log status
echo "Downloading GO data, extracing gene symbols and looking up corresponding Ensembl gene IDs..." >> "$logFile"

# Iterate over terms
while read term; do

    # Log status
    echo "..Processing GO term '$term'..." >> "$logFile"

    # Trim term ID
    term_short="$(echo $term | cut -f2 -d":")"

    # Iterate over organisms
    for short_name in "${!organisms[@]}"; do

        # Log status
        echo "....Processing organism '${organisms[$short_name]}'..." >> "$logFile"

        # Set and create output subdirectory
        out_subdir="${outDir}/${short_name}"
        mkdir -p "$out_subdir"

        # Build URL
        org=$(echo "${organisms[$short_name]}" | sed 's/\s/%20/g')
        url=${url_start}${org}${url_mid}${term}

        # Download GO data
        out_file_go="${out_subdir}/${short_name}.${term_short}.gaf"
        #DEBUG echo "URL for term '$term': $url" &>> "$logFile"
        wget -q -O "$out_file_go" "$url" > /dev/null 2>> "$logFile"

        # Extract gene symbols
        out_file_sym="${out_subdir}/${short_name}.${term_short}.gene_symbols"
        cut -f3 "$out_file_go" | sort -u > "$out_file_sym" 2>> "$logFile"

        # Convert to Ensembl gene IDs
        out_file_ids="${out_subdir}/${short_name}.${term_short}.ensembl_gene_ids"
        awk 'BEGIN{ FS="\t"; OFS="\n" } NR==FNR { if (a[$8] == "") { a[$8]=$6 } else if ( a[$8] != $6 ) { a[$8]=a[$8]"\n"$6 }; next } { if ($0 in a) { print a[$0] } }' <(zcat "${idTables[$short_name]}") "$out_file_sym" | sort -u > "$out_file_ids"

        # Convert to merged ortholog gene symbols
        out_file_common_sym="${tmpDir}/${short_name}.${term_short}.common_gene_symbols"
        awk -v key=${idCols[$short_name]} -v val=$commonSymCol 'NR==FNR { if (a[$key] == "") { a[$key]=$val } else { a[$key]=a[$key]"\n"$val }; next } { if ($0 in a) { print a[$0] } }' <(zcat "$commonSymbols") "$out_file_ids" | sort -u > "$out_file_common_sym"

    done

    # Combine merged ortholog gene symbols across organisms
    out_file_common_sym="${outDirUnion}/${term_short}.common_gene_symbols"
    cat "${tmpDir}/"*".${term_short}.common_gene_symbols" | sort -u > "$out_file_common_sym"

done < <(cut -f1 "$goTerms")


#############
###  END  ###
#############

echo "Output files stored in: $outDir" >> "$logFile"
echo "Temporary data stored in: $tmpDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
