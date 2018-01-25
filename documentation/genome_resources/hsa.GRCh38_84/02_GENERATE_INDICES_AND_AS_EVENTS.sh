#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 27-APR-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Generates indices for sequencing read library annotation.


####################
###  PARAMETERS  ###
####################

root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"
fileNamePrefix="hsa.GRCh38_84"
workflowDir="${root}/.tmp/frameworksAuxiliary/Anduril/get_indices_and_as_events/workflows"
workflow="${workflowDir}/workflow.${fileNamePrefix}.and"
resDir="${root}/publicResources/genome_resources/${fileNamePrefix}"
genome="${resDir}/hsa.GRCh38_84.genome.filtered.fa.gz"
transcriptome="${resDir}/hsa.GRCh38_84.transcriptome.filtered.fa.gz"
geneAnno="${resDir}/hsa.GRCh38_84.gene_annotations.filtered.gtf.gz"
tmpDir="${root}/.tmp/publicResources/genome_resources/${fileNamePrefix}"
bundleDir="${root}/frameworksAuxiliary/Anduril/bundle"
execDir="${tmpDir}/get_indices_and_as_events"
logDir="${root}/logFiles/publicResources/genome_resources/${fileNamePrefix}"
logDirAnduril="${logDir}/get_indices_and_as_events"
targetDir="${resDir}/indices"
sjdb_overhang=200


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir --parents "$workflowDir"
mkdir --parents "$tmpDir"
mkdir --parents "$targetDir"
mkdir --parents "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

## PRE-PROCESSING

# Extract genome
echo "Extracting genome..." >> "$logFile"
genomeTmp="${tmpDir}/$(basename "$genome" ".gz")"
gunzip --stdout "$genome" > "$genomeTmp"

# Extract gene annotations
echo "Extracting gene annotations..." >> "$logFile"
geneAnnoTmp="${tmpDir}/$(basename "$geneAnno" ".gz")"
gunzip --stdout "$geneAnno" | grep -v -P "^#\!" > "$geneAnnoTmp"


## WRITE AND EXECUTE ANDURIL WORKFLOW

# Write Anduril workflow file
# ---------------------------
# - See/set default a component's execution parameters in: "${bundleDir}/components/*/component.xml"
# - Parameter '_execMode="remote"' uses DRMAA to submit jobs to DRM (e.g. Univa Grid Engine); set to
#   "local" if execution on local machine is preferred/required
echo "Creating workflow..." >> "$logFile"
cat > "$workflow" <<- EOF
/*
* Author:      Alexander Kanitz
* Affiliation: Biozentrum, University of Basel
* Email:       alexander.kanitz@alumni.ethz.ch
* Date:        May 2, 2016
* Description: Generate indices and alternative splicing events for RNA-Seq library alignments and
*              quantification:
*              - Alignments: 'STAR' (https://github.com/alexdobin/STAR)
*              - Quantification: 'kallisto' (http://pachterlab.github.io/kallisto/)
*              - AS events: 'SUPPA' (https://bitbucket.org/regulatorygenomicsupf/suppa)
*/


//// ---> SET PARAMETERS <--- ////
genome_path        = "$genomeTmp"
gene_anno_path     = "$geneAnnoTmp"
transcriptome_path = "$transcriptome"


//// ---> IMPORT FILES <--- ////
genome        = INPUT(path = genome_path)
gene_anno     = INPUT(path = gene_anno_path)
transcriptome = INPUT(path = transcriptome_path)


//// ---> PROCESSING <--- ////

// ---> BUILD STAR INDEX: Read length 200 <--- //
index_STAR_200 = STAR (
    INFILE_genomeFastaFiles = genome,
    INFILE_sjdbGTFfile      = gene_anno,
    runMode                 = "genomeGenerate",
    sjdbOverhang            = $sjdb_overhang,
    _OUTDIRMAKE_genomeDir   = "true",
    _execMode               = "remote",
    _cores                  = "8",
    _membycore              = "5G",
    _runtime                = "2:00:00"
)

// ---> BUILD KALLISTO INDEX <--- //
index_kallisto = kallistoIndex (
    INFILE_refseqs = transcriptome,
    _execMode      = "remote",
    _cores         = "1",
    _membycore     = "20G",
    _runtime       = "0:30:00"
)

// ---> GENERATE SUPPA ALTERNATIVE SPLICING EVENTS <--- //
events_SUPPA = SUPPAGenerateEvents(
    INFILE_input_file = gene_anno,
    event_type        = "FL MX RI SE SS",
    _execMode         = "remote",
    _cores            = "1",
    _membycore        = "4G",
    _runtime          = "0:30:00"
)
EOF

# Execute Anduril workflow
echo "Executing workflow..." >> "$logFile"
time anduril "run" "$workflow" --bundle "$bundleDir" --execution-dir "$execDir" --log "$logDirAnduril" --threads 4 &> /dev/null


## COPY RESULTS

# Write log entry
echo "Copying results..." >> "$logFile"

# Copy STAR index directory
echo "STAR..." >> "$logFile"
baseGenome="$(basename "${genomeTmp%.*}")"
targetDirSTAR_200="${targetDir}/STAR/${baseGenome}.gene_annotations.filtered.200"; mkdir --parents "$targetDirSTAR_200"
cp "${execDir}/index_STAR_200/OUTDIRMAKE_genomeDir/"* "$targetDirSTAR_200"

# Copy kallisto index file
echo "kallisto..." >> "$logFile"
baseTranscriptome="$(basename "$transcriptome" ".fa.gz")"
targetDirKallisto="${targetDir}/kallisto"; mkdir --parents "$targetDirKallisto"
cp "${execDir}/index_kallisto/OUTFILE_index" "${targetDirKallisto}/${baseTranscriptome}.idx"

# Copy SUPPA event files
echo "SUPPA..." >> "$logFile"
baseGeneAnno="$(basename "${geneAnnoTmp%.*}")"
targetDirSUPPA="${targetDir}/SUPPA/${baseGeneAnno}"; mkdir --parents "$targetDirSUPPA"
cp "${execDir}/events_SUPPA/OUTDIRMAKE_output_file/"* "$targetDirSUPPA"


#############
###  END  ###
#############

echo "Temporary data in: $execDir" >> "$logFile"
echo "Persistent data in: $targetDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
