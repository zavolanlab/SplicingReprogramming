#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 27-APR-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Obtains and filters genome, gene annotations and transcriptome.


####################
###  PARAMETERS  ###
####################

# Root directory
# --------------
root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"

# Prefix for filenames
# --------------------
# - Downloaded files go to 'rawDir' and keep their original filenames
fileNamePrefix="ptr.CHIMP2.1.4_84"

# Other directories
# -----------------
resDir="${root}/publicResources/genome_resources/${fileNamePrefix}"
rawDir="${resDir}/raw"
tmpDir="${root}/.tmp/genome_resources/${fileNamePrefix}"
logDir="${root}/logFiles/genome_resources/${fileNamePrefix}"

# URLs
# ----
# - All URLs variables represent Bash arrays, so that multiple URLs can be provided; in that case, 
# files are concatenated after download
# - It is assumed that the specified transcriptome files contain sequences for all transcripts in 
# the (filtered) gene annotations
genomeURLs=("ftp://ftp.ensembl.org/pub/release-84/fasta/pan_troglodytes/dna/Pan_troglodytes.CHIMP2.1.4.dna_sm.toplevel.fa.gz")
geneAnnoURLs=("ftp://ftp.ensembl.org/pub/release-84/gtf/pan_troglodytes/Pan_troglodytes.CHIMP2.1.4.84.gtf.gz")
transcriptomeURLs=("ftp://ftp.ensembl.org/pub/release-85/fasta/pan_troglodytes/cdna/Pan_troglodytes.CHIMP2.1.4.cdna.all.fa.gz" "ftp://ftp.ensembl.org/pub/release-85/fasta/pan_troglodytes/ncrna/Pan_troglodytes.CHIMP2.1.4.ncrna.fa.gz")

# Filters
# -------
# - All filters are positive filters, i.e. entries meeting the specified filters are kept
# - Separate multiple entries by a single space and quote the whole string
# - Set to empty string '""' if no filtering is desired
# - Transcriptome sequences are filtered according to the transcript annotations remaining after 
# applying gene annotation filters
# - Warnings are issued if sequences for annotated transcripts are absent in the transcriptome
# Genome filters
genomeFilterChromosomes="1 2A 2B 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y MT"
# Gene annotation / transcriptome filters
geneAnnoFilterChromosomes="1 2A 2B 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y"
geneAnnoFilterGeneBiotypes="antisense lincRNA processed_transcript protein_coding"
geneAnnoFilterTranscriptBiotypes=""
geneAnnoFilterTranscriptSupportLevels=""


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir --parents "$resDir"
mkdir --parents "$rawDir"
mkdir --parents "$tmpDir"
mkdir --parents "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

## GET & FILTER GENOME

# Get genome files
echo "Downloading genome files..." >> "$logFile"
for url in "${genomeURLs[@]}"; do
    wget "$url" --output-document "${rawDir}/$(basename "$url")" &> /dev/null
done

# Concatenate genome files
echo "Concatenating genome files..." >> "$logFile"
genome="${resDir}/${fileNamePrefix}.genome.fa.gz"
for url in "${genomeURLs[@]}"; do
    cat "${rawDir}/$(basename "$url")" >> "$genome"
done

# Filter genome
genomeFilt="${resDir}/${fileNamePrefix}.genome.filtered.fa.gz"

    # Filter requested chromosomes
    if [ "$genomeFilterChromosomes" != ""  ]; then
        echo "Filtering genome file..." >> "$logFile"
        perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' <(echo "$genomeFilterChromosomes" | sed 's/ /\n/g') <(zcat "$genome") | gzip > "$genomeFilt"
    else
        cp "$genome" "$genomeFilt"
    fi


## GET & FILTER GENE ANNOTATIONS

# Get gene annotation files
echo "Downloading gene annotations..." >> "$logFile"
for url in "${geneAnnoURLs[@]}"; do
    wget "$url" --output-document "${rawDir}/$(basename "$url")" &> /dev/null
done

# Concatenate gene annotation files
echo "Concatenating gene annotation files..." >> "$logFile"
geneAnno="${resDir}/${fileNamePrefix}.gene_annotations.gtf.gz"
for url in "${geneAnnoURLs[@]}"; do
    cat "${rawDir}/$(basename "$url")" >> "$geneAnno"
done

# Filter gene annotations
geneAnnoFilt="${resDir}/${fileNamePrefix}.gene_annotations.filtered.gtf.gz"
geneAnnoFiltTmp="${tmpDir}/${fileNamePrefix}.gene_annotations.filtered.gtf.gz.tmp"
cp "$geneAnno" "$geneAnnoFiltTmp"

    # Filter requested chromosomes
    # ----------------------------
    # - If filter provided, filters comments and matching chromosomes
    if [ "$geneAnnoFilterChromosomes" != ""  ]; then
        echo "Filtering gene annotations by chromosomes..." >> "$logFile"
        perl -ane 'if(!@ARGV){if(/^#\!/){print}else{$keep=$chr{$F[0]}}}$keep?print:chomp;$chr{$_}=1 if @ARGV' <(echo "$geneAnnoFilterChromosomes" | sed 's/ /\n/g') <(zcat $geneAnnoFiltTmp) | gzip > "$geneAnnoFilt"
        cp "$geneAnnoFilt" "$geneAnnoFiltTmp"
    fi

    # Filter requested gene biotypes
    # ------------------------------
    # - If filter provided, filters comments and matching gene biotypes
    if [ "$geneAnnoFilterGeneBiotypes" != ""  ]; then
        echo "Filtering gene annotations by gene biotypes..." >> "$logFile"
        perl -ne 'if(/^#\!/){print;$keep=0}elsif(/gene_biotype\s\"(\S+)\"/){$keep=$type{$1}}else{$keep=0}$keep?print:chomp;$type{$_}=1 if @ARGV' <(echo "$geneAnnoFilterGeneBiotypes" | sed 's/ /\n/g') <(zcat $geneAnnoFiltTmp) | gzip > "$geneAnnoFilt"
        cp "$geneAnnoFilt" "$geneAnnoFiltTmp"
    fi

    # Filter requested transcript biotypes
    # ------------------------------------
    # - If filter provided, filters 'gene' entries, commentss and matching transcript biotypes
    if [ "$geneAnnoFilterTranscriptBiotypes" != ""  ]; then
        echo "Filtering annotations by transcript biotypes..." >> "$logFile"
        perl -ane 'if(/^#\!/||$F[2] eq "gene"){print;$keep=0}elsif(/transcript_biotype\s\"(\S+)\"/){$keep=$type{$1}}else{$keep=0}$keep?print:chomp;$type{$_}=1 if @ARGV' <(echo "$geneAnnoFilterTranscriptBiotypes" | sed 's/ /\n/g') <(zcat $geneAnnoFiltTmp) | gzip > "$geneAnnoFilt"
        cp "$geneAnnoFilt" "$geneAnnoFiltTmp"
    fi

    # Filter requested transcript support levels
    # ------------------------------------------
    # - If filter provided, filters 'gene' entries, comments and matching transcript support levels
    if [ "$geneAnnoFilterTranscriptSupportLevels" != ""  ]; then
        echo "Filtering annotations by transcript support levels..." >> "$logFile"
        perl -ane 'if(/^#\!/||$F[2] eq "gene"){print;$keep=0}elsif(/transcript_support_level\s\"(\S+?)\"?/){$keep=$level{$1}}else{$keep=0}$keep?print:chomp;$level{$_}=1 if @ARGV' <(echo "$geneAnnoFilterTranscriptSupportLevels" | sed 's/ /\n/g') <(zcat $geneAnnoFiltTmp) | gzip > "$geneAnnoFilt"
        cp "$geneAnnoFilt" "$geneAnnoFiltTmp"
    fi

    # Remove orphan 'genes' (i.e. 'genes' with all child entries removed) & temporary file
    echo "Removing 'orphan' genes..." >> "$logFile"
    perl -ane 'if ($F[2] eq "gene"){$prev=$_}else{print $prev,$_; $prev=""}' <(zcat $geneAnnoFiltTmp) | gzip > "$geneAnnoFilt"
    rm "$geneAnnoFiltTmp"

# Get transcript identifiers
echo "Extracting transcript identifiers..." >> "$logFile"
geneAnnoTrxIDs="${tmpDir}/${fileNamePrefix}.gene_annotations.filtered.trx_ids"
if [ -s $geneAnnoFilt ]; then
    awk -F'\t| |"|;' '$3 == "transcript" {print $21}' <(zcat "$geneAnnoFilt") | sort --unique > "$geneAnnoTrxIDs"
else
    awk -F'\t| |"|;' '$3 == "transcript" {print $21}' <(zcat "$geneAnno") | sort --unique > "$geneAnnoTrxIDs"
fi


## GET & FILTER TRANSCRIPTOME

# Get transcriptome files
echo "Downloading transcriptome..." >> "$logFile"
for url in "${transcriptomeURLs[@]}"; do
    wget "$url" --output-document "${rawDir}/$(basename "$url")" &> /dev/null
done

# Concatenate transcriptome files
echo "Concatenating transcriptome files..." >> "$logFile"
transcriptome="${resDir}/${fileNamePrefix}.transcriptome.fa.gz"
for url in "${transcriptomeURLs[@]}"; do
    cat "${rawDir}/$(basename "$url")" >> "$transcriptome"
done

# Filter transcriptome according to filtered gene annotations
echo "Filtering transcriptome..." >> "$logFile"
transcriptomeFilt="${resDir}/${fileNamePrefix}.transcriptome.filtered.fa.gz"
perl -ne 'if(/^>(\w+)/){$keep=$id{$1};$_=">$1\n"}$keep?print:chomp;$id{$_}=1 if @ARGV' "$geneAnnoTrxIDs" <(zcat "$transcriptome") | gzip > "$transcriptomeFilt"

# Throw warnings for missing transcripts & annotations
echo "Verifying transcriptome completeness..." >> "$logFile"
transcriptomeTrxIDs="${tmpDir}/${fileNamePrefix}.transcriptome.filtered.trx_ids"
transcriptomeTrxIDsMissing="${tmpDir}/${fileNamePrefix}.transcriptome.filtered.missing_trx_ids"
perl -lne 'if(/^>(\w+)/){print "$1"}' <(zcat $transcriptomeFilt) | sort --unique > "$transcriptomeTrxIDs"
comm -23 "$geneAnnoTrxIDs" "$transcriptomeTrxIDs" > "$transcriptomeTrxIDsMissing"
if [ -s "$transcriptomeTrxIDsMissing" ]; then
    echo "[WARNING] There are transcripts missing from the transcriptome. Check '$transcriptomeTrxIDsMissing' for details." >> "$logFile"
fi


## COMPILE TRANSCRIPT TABLE

# Compile table
echo "Compiling transcript table..." >> "$logFile"
trxTable="${resDir}/${fileNamePrefix}.transcripts.tsv.gz"
trxTableFilt="${resDir}/${fileNamePrefix}.transcripts.filtered.tsv.gz"
zcat "$geneAnno" | awk '$3 == "transcript"' | awk -v OFS="\t" '{
    for (field = 9; field <= NF; field++) {
        if ($field == "transcript_id")            trxID       = $(field+1)
        if ($field == "transcript_version")       trxVersion  = $(field+1)
        if ($field == "transcript_name")          trxName     = $(field+1)
        if ($field == "transcript_biotype")       trxType     = $(field+1)
        if ($field == "transcript_support_level") trxSuppLvl  = $(field+1)
        if ($field == "gene_id")                  geneID      = $(field+1)
        if ($field == "gene_version")             geneVersion = $(field+1)
        if ($field == "gene_name")                geneName    = $(field+1)
        if ($field == "gene_biotype")            geneType    = $(field+1)
    }
    print trxID, trxVersion, trxName, trxType, trxSuppLvl, geneID, geneVersion, geneName, geneType
}' | sed -e 's/"//g' -e 's/;//g' | sort -u -k1,1 | gzip > "${trxTable}"
zcat "$geneAnnoFilt" | awk '$3 == "transcript"' | awk -v OFS="\t" '{
    for (field = 9; field <= NF; field++) {
        if ($field == "transcript_id")            trxID       = $(field+1)
        if ($field == "transcript_version")       trxVersion  = $(field+1)
        if ($field == "transcript_name")          trxName     = $(field+1)
        if ($field == "transcript_biotype")       trxType     = $(field+1)
        if ($field == "transcript_support_level") trxSuppLvl  = $(field+1)
        if ($field == "gene_id")                  geneID      = $(field+1)
        if ($field == "gene_version")             geneVersion = $(field+1)
        if ($field == "gene_name")                geneName    = $(field+1)
        if ($field == "gene_biotype")            geneType    = $(field+1)
    }
    print trxID, trxVersion, trxName, trxType, trxSuppLvl, geneID, geneVersion, geneName, geneType
}' | sed -e 's/"//g' -e 's/;//g' | sort -u -k1,1 | gzip > "${trxTableFilt}"


### COMPILE GENE SYMBOL LOOKUP TABLE

## Compile table
echo "Compiling gene ID > gene symbol lookup table..." >> "$logFile"
idSymTable="${resDir}/${fileNamePrefix}.genes.id_to_symbol.tsv.gz"
idSymTableFilt="${resDir}/${fileNamePrefix}.genes.id_to_symbol.tsv.gz"
awk -F"\t" '{print $8"\t"$6}' <(zcat $trxTable) | sort -u | awk 'BEGIN{FS="\t"; OFS="\t"} {a1[$1]=$1; if (a2[$1] == "") {a2[$1]=$2} else {a2[$1]=a2[$1]"|"$2}} END{for (id in a1) {print a2[id], id}}' | grep -v "|" | sort | gzip > "$idSymTable"
awk -F"\t" '{print $8"\t"$6}' <(zcat $trxTableFilt) | sort -u | awk 'BEGIN{FS="\t"; OFS="\t"} {a1[$1]=$1; if (a2[$1] == "") {a2[$1]=$2} else {a2[$1]=a2[$1]"|"$2}} END{for (id in a1) {print a2[id], id}}' | grep -v "|" | sort | gzip > "$idSymTableFilt"


############
###  END  ###
#############

echo "Original data in: $rawDir" >> "$logFile"
echo "Processed data in: $resDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
