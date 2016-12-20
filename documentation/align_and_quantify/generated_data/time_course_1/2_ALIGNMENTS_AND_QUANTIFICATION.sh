#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 16-JUN-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Processes RNA-Seq libraries, align and quantify transcript expression and alternative splicing.


####################
###  PARAMETERS  ###
####################

root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"
docDir="${root}/documentation/time_course_1"
sampleTable="${docDir}/sample_overview.csv"
workflowDir="${root}/documentation/anduril/workflows"
workflow="${workflowDir}/align_and_quantify_1.and"
resDir="${root}/publicResources/mmuGenomeResources"
indexKallisto="${resDir}/indices/kallisto/mmu.GRCm38_84.transcriptome.filtered.idx"
indexSTAR="${resDir}/indices/STAR/mmu.GRCm38_84.genome.gene_annotations_filtered.read_length_101"
eventDirSUPPA="${resDir}/indices/SUPPA/mmu.GRCm38_84.gene_annotations.filtered"
geneAnno="${resDir}/mmu.GRCm38_84.gene_annotations.filtered.gtf.gz"
tmpDir="${root}/.tmp/analyzedData/time_course_1"
bundleDir="${root}/frameworksAuxiliary/Anduril/bundle"
execDir="${tmpDir}/alignmentsAndQuantification"
logDir="${root}/logFiles/time_course_1/alignmentsAndQuantification"
targetDir="${root}/analyzedData/time_course_1"
targetDirAlignments="${targetDir}/alignments"
targetDirAbundances="${targetDir}/abundances"
targetDirIsoUsage="${targetDir}/isoformUsage"
targetDirEventInclusion="${targetDir}/eventInclusion"
scriptDir="${root}/scriptsSoftware"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir --parents "$docDir"
mkdir --parents "$workflowDir"
mkdir --parents "$tmpDir"
mkdir --parents "$targetDirAlignments" "$targetDirAbundances" "$targetDirIsoUsage" "$targetDirEventInclusion"


########################
###  PRE-PROCESSING  ###
########################

# Extract gene annotations
geneAnnoTmp="${tmpDir}/$(basename "$geneAnno" ".gz")"
gunzip --stdout "$geneAnno" | grep -v -P "^#\!" > "$geneAnnoTmp"


#############################
###  CREATE SAMPLE TABLE  ###
#############################

# Compile sample table
# --------------------
# - Fields: sampleName / path / format / adapter / fragLenMean / fragLenSD
# - Fragment length mean and standard deviations were estimated from BioAnalyzer reports here:
#   - ls "${root}/documentation/time_course_1/time_course_1.bioanalyzer_1.pdf"
#   - ls "${root}/documentation/time_course_1/time_course_1.bioanalyzer_2.pdf"
#   - ls "${root}/documentation/time_course_1/time_course_1.bioanalyzer_3.pdf"
cat > "$sampleTable" <<- EOF
sampleName	path	format	adapter	fragLenMean	fragLenSD
Day0_MEFs	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day0_MEFs.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	412	140
Day1C	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day1C.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	426	142
Day1E1	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day1E1.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	388	124
Day1Red	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day1Red.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	422	181
Day2C	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day2C.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	404	130
Day2E1	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day2E1.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	378	102
Day2Red	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day2Red.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	493	147
Day3C	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day3C.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	426	181
Day3E1	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day3E1.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	423	144
Day3Red	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day3Red.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	430	145
Day4C	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day4C.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	387	106
Day4E1	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day4E1.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	438	161
Day4Red	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day4Red.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	471	202
Day5C	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day5C.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	446	180
Day5E1	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day5E1.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	436	198
Day5Red	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day5Red.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	423	147
Day6C	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day6C.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	466	183
Day6E1	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day6E1.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	402	135
Day6Red	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day6Red.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	433	165
Day7C	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day7C.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	390	124
Day7E1	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day7E1.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	457	170
Day7Red	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day7Red.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	451	169
Day8C	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day8C.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	476	247
Day8E1	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day8E1.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	451	208
Day8Red	/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_1/Day8Red.fastq.gz	fastq	TGGAATTCTCGGGTGCCAAGG	445	136
EOF


###########################################
###  PROCESS, ALIGN & QUANTIFY SAMPLES  ###
###########################################

# Write Anduril workflow file
# ---------------------------
# - See/see a component's default execution parameters in: "${bundleDir}/components/*/component.xml"
# - Parameter '_execMode="remote"' uses DRMAA to submit jobs to DRM (e.g. Univa Grid Engine); set to
#   "local" if execution on local machine is preferred/required
cat > "$workflow" <<- EOF
/*
* Author:      Alexander Kanitz
* Affiliation: Biozentrum, University of Basel
* Email:       alexander.kanitz@alumni.ethz.ch
* Date:        Jun 13, 2016
* Description: Given a table of RNA-Seq samples, aligns reads and estimates transcript abundances
*              and alternative splicing:
*              - Alignments: 'STAR' (https://github.com/alexdobin/STAR)
*              - Quantification: 'kallisto' (http://pachterlab.github.io/kallisto/)
*              - AS events: 'SUPPA' (https://bitbucket.org/regulatorygenomicsupf/suppa)
*/


//// ---> SET PARAMETERS <--- ////
sample_table_path     = "$sampleTable"
index_kallisto_path   = "$indexKallisto"
index_STAR_path       = "$indexSTAR"
gene_anno_path        = "$geneAnnoTmp"
event_dir_SUPPA_path  = "$eventDirSUPPA"


//// ---> IMPORT FILES <--- ////
sample_table         = INPUT(path = sample_table_path)
index_kallisto       = INPUT(path = index_kallisto_path)
index_STAR           = INPUT(path = index_STAR_path)
gene_anno            = INPUT(path = gene_anno_path)
event_dir_SUPPA      = INPUT(path = event_dir_SUPPA_path)
ioe_file_array_SUPPA = Folder2Array(event_dir_SUPPA, filePattern = "^_.*\\\\.ioe$")


//// ---> PROCESSING <--- ////

/// ---> ITERATE OVER SAMPLES <--- ///
for sample: std.itercsv(sample_table.in) {

    // ---> IMPORT READ FILE <--- //
    read_file = INPUT(
        path  = sample.path,
        @name = "read_file_" + sample.sampleName
    )

    // ---> REMOVE 3' ADAPTER <--- //
    adapter_cut = Cutadapt(
        INFILE_input   = read_file,
        adapter        = sample.adapter,
        format         = sample.format,
        trim_n         = "{{TRUE}}",
        minimum_length = "30",
        _execMode      = "remote",
        _cores         = "1",
        _membycore     = "1500M",
        _runtime       = "2:00:00",
        @name          = "adapter_cut_" + sample.sampleName
    )

    // ---> REMOVE POLY-A TAIL <--- //
    polyA_cut = Cutadapt(
        INFILE_input   = adapter_cut.OUTFILE_output,
        adapter        = "AAAAAAAAAAAAAAAAAAAAAAAAA",
        format         = sample.format,
        trim_n         = "{{TRUE}}",
        minimum_length = "30",
        _execMode      = "remote",
        _cores         = "1",
        _membycore     = "1500M",
        _runtime       = "2:00:00",
        @name          = "polyA_cut_" + sample.sampleName
    )

    // ---> ALIGN READS <--- //
    aligned = STAR(
        INFILE_readFilesIn = polyA_cut.OUTFILE_output,
        INDIR_genomeDir    = index_STAR,
        runMode            = "alignReads",
        _execMode          = "remote",
        _cores             = "8",
        _membycore         = "5G",
        _runtime           = "4:00:00",
        @name              = "aligned_" + sample.sampleName
    )

    // ---> ESTIMATE EXPRESSION <--- //
    abundances = kallistoQuant(
        INFILE_readseqs = polyA_cut.OUTFILE_output,
        INFILE_index    = index_kallisto,
        plaintext       = "{{TRUE}}",
        single          = "{{TRUE}}",
        fragment_length = sample.fragLenMean,
        sd              = sample.fragLenSD,
        _execMode       = "remote",
        _cores          = "8",
        _membycore      = "2G",
        _runtime        = "0:30:00",
        @name           = "abundances_" + sample.sampleName
    )

    // ---> PREPARE EXPRESSION ESTIMATES FOR SUPPA PSI CALCULATION <--- //
    abundances_processed = kallistoExtractOutput(
        INDIR_inputDir = abundances.OUTDIR_output_dir,
        sampleName     = sample.sampleName,
        verbose        = "{{TRUE}}",
        _execMode      = "remote",
        _cores         = "1",
        _membycore     = "1500M",
        _runtime        = "0:15:00",
        @name          = "abundances_processed_" + sample.sampleName
    )

    // ---> CALCULATE PSI PER ISOFORM <--- //
    event_iso = SUPPAPsiPerIsoform(
        INFILE_gtf_file        = gene_anno,
        INFILE_expression_file = abundances_processed.OUTFILE_outFile,
        _execMode              = "remote",
        _cores                 = "1",
        _membycore             = "1500M",
        _runtime               = "0:30:00",
        @name                  = "event_iso_" + sample.sampleName
    )

    /// ---> ITERATE OVER AS EVENT CLASSES <--- ///
    for ioe: std.iterArray(ioe_file_array_SUPPA.array) {

        // ---> GET NAME OF EVENT CLASS <--- //
        event_class = std.strReplace(
            string  = ioe.file,
            match   = "(^.*\\\\/_)(\\\\w{2})(_strict\\\\.\\\\w{3}$)",
            replace = "\$2"
        )

        // ---> CALCULATE PSI PER EVENT <--- //
        event_psi = SUPPAPsiPerEvent(
            INFILE_ioe_file        = ioe_file_array_SUPPA.array[ioe.key],
            INFILE_expression_file = abundances_processed.OUTFILE_outFile,
            _execMode              = "remote",
            _cores                 = "1",
            _membycore             = "1500M",
            _runtime               = "0:30:00",
            @name                  = "event_psi_" + event_class + "_" + sample.sampleName
        )

    }

}
EOF

# Execute Anduril workflow
time anduril "run" "$workflow" --bundle "$bundleDir" --execution-dir "$execDir" --log "$logDir" --threads 32 &> /dev/null


#######################
###  COPY RESULTS   ###
#######################

# Copy abundances
for file in "${execDir}/abundances_D"*"/OUTDIR_output_dir/abundance.tsv"; do
    instanceName=$(basename $(dirname $(dirname "$file")))
    sampleName="${instanceName#abundances_}"
    outFile="${targetDirAbundances}/abundances_${sampleName}.tsv"
    cp "$file" "$outFile"
done

# Copy and compress/sort/index alignments
for file in "${execDir}/aligned_"*"/OUTDIRMAKE_outFileNamePrefix/Aligned.out.sam"; do
    instanceName=$(basename $(dirname $(dirname "$file")))
    sampleName="${instanceName#aligned_}"
    outFilePrefix="${targetDirAlignments}/alignments_${sampleName}"
    samtools view -bS "$file" | samtools sort - "$outFilePrefix"
    samtools index "${outFilePrefix}.bam"
done

# Copy isoform usages
for file in "${execDir}/event_iso_"*"/OUTFILE_output_file_isoform.psi"; do
    instanceName=$(basename $(dirname "$file"))
    sampleName="${instanceName#event_iso_}"
    outFile="${targetDirIsoUsage}/isoform_usage_${sampleName}.tsv"
    cp "$file" "$outFile"
done

# Copy event inclusion rates (PSI)
for file in "${execDir}/event_psi_"*"/OUTFILE_output_file.psi"; do
    instanceName=$(basename $(dirname "$file"))
    sampleName="${instanceName#event_psi_}"
    outFile="${targetDirEventInclusion}/event_inclusion_${sampleName}.tsv"
    cp "$file" "$outFile"
done


#########################
###  POST-PROCESSING  ###
#########################

# Round Kallisto read estimates and prepare matrix
Rscript "${scriptDir}/mergeKallistoQuant.R" --inputDir "$targetDirAbundances" --outFile "${targetDirAbundances}/abundances.counts" --filenameGlob "abundances_*.tsv" --round --sampleNamePrefix "abundances_" --sampleNameSuffix ".tsv"

# Prepare matrix of Kallisto abundance estimates
Rscript "${scriptDir}/mergeKallistoQuant.R" --inputDir "$targetDirAbundances" --outFile "${targetDirAbundances}/abundances.tpm" --filenameGlob "abundances_*.tsv" --colSelect "tpm" --sampleNamePrefix "abundances_" --sampleNameSuffix ".tsv"
