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
docDir="${root}/documentation/time_course_2"
sampleTable="${docDir}/sample_overview.csv"
workflowDir="${root}/documentation/anduril/workflows"
workflow="${workflowDir}/align_and_quantify_2.and"
resDir="${root}/publicResources/mmuGenomeResources"
indexKallisto="${resDir}/indices/kallisto/mmu.GRCm38_84.transcriptome.filtered.idx"
indexSTAR="${resDir}/indices/STAR/mmu.GRCm38_84.genome.gene_annotations_filtered.read_length_136"
eventDirSUPPA="${resDir}/indices/SUPPA/mmu.GRCm38_84.gene_annotations.filtered"
geneAnno="${resDir}/mmu.GRCm38_84.gene_annotations.filtered.gtf.gz"
tmpDir="${root}/.tmp/analyzedData/time_course_2"
bundleDir="${root}/frameworksAuxiliary/Anduril/bundle"
execDir="${tmpDir}/alignmentsAndQuantification"
logDir="${root}/logFiles/time_course_2/alignmentsAndQuantification"
targetDir="${root}/analyzedData/time_course_2"
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
sampleName	 path	 format	 adapter	 fragLenMean	 fragLenSD
D0_E1	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D0_E1.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D0_E2	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D0_E2.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D0_Luc	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D0_Luc.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D0_M	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D0_M.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D0_NI	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D0_NI.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D15_E1	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D15_E1.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D15_E2	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D15_E2.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D15_Luc	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D15_Luc.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D15_M	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D15_M.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D15_NI	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D15_NI.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D1_E1	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D1_E1.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D1_E2	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D1_E2.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D1_Luc	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D1_Luc.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D1_M	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D1_M.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D1_NI	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D1_NI.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D2_E1	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D2_E1.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D2_E2	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D2_E2.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D2_Luc	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D2_Luc.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D2_M	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D2_M.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D2_NI	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D2_NI.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D3_E1	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D3_E1.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D3_E2	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D3_E2.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D3_Luc	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D3_Luc.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D3_M	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D3_M.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D3_NI	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D3_NI.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D4_E1	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D4_E1.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D4_E2	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D4_E2.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D4_Luc	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D4_Luc.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D4_M	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D4_M.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D4_NI	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D4_NI.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D5_E1	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D5_E1.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D5_E2	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D5_E2.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D5_Luc	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D5_Luc.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D5_M	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D5_M.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
D5_NI	 /scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/rawData/time_course_2/D5_NI.fastq.gz	 fastq	 TGGAATTCTCGGGTGCCAAGG	 430	 147
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
