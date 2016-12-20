#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 24-OCT-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Generates Anduril network files for RNA-Seq alignments and quantification.


####################
###  PARAMETERS  ###
####################

root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"
inDir="${root}/.tmp/frameworksAuxiliary/anduril/align_and_quantify/sra_data/sample_tables"
outDir="${root}/.tmp/frameworksAuxiliary/anduril/align_and_quantify/sra_data/workflows"
logDir="${root}/logFiles/analyzedData/align_and_quantify/sra_data"
inPrefix="table."
inGlobPattern=???
inSuffix=".tsv"
outPrefix="${outDir}/workflow."
outSuffix=".and"
resDir="${root}/publicResources/genome_resources"
resTmpDir="${root}/.tmp/publicResources/genome_resources"
prefix_hsa="hsa.GRCh38_84"
prefix_mmu="mmu.GRCm38_84"
prefix_ptr="ptr.CHIMP2.1.4_84"
cutadapt_format="FASTQ"
cutadapt_minLen=20
star_sjdbOverhang=135
kallisto_fragLenMean=300
kallisto_fragLenSD=75


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir -p "$outDir"
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile; "touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

## WRITE NETWORK FILES

# Iterate over sample tables
for table in "${inDir}/${inPrefix}"${inGlobPattern}"${inSuffix}"; do

    # Write log
    echo "Processing sample table '$table'..." >> "$logFile"

    # Get table ID
    tableId=${table#"${inDir}/$inPrefix"}
    tableId=${tableId%$inSuffix}

    # Set workflow filename
    workflow="${outPrefix}${tableId}${outSuffix}"

    # Write workflow
    cat > "$workflow" <<- EOF
/*
* Author:      Alexander Kanitz
* Affiliation: Biozentrum, University of Basel
* Email:       alexander.kanitz@alumni.ethz.ch
* Date:        Nov 05, 2016
* Description: Given a table of RNA-Seq samples in SRA format, aligns reads and
*              estimates transcript abundances and alternative splicing:
*              - Alignments: 'star' (https://github.com/alexdobin/star)
*              - Quantification: 'kallisto' (http://pachterlab.github.io/kallisto/)
*              - AS events: 'suppa' (https://bitbucket.org/regulatorygenomicsupf/suppa)
* Requires:    A tab-separated sample table with the following fields:
*              - SRA study ID
*              - SRA run ID
*              - organism (one of 'Homo sapiens', 'Mus musculus' or 'Pan troglodytes')
*              - library preparation strategy (one of 'SINGLE' or 'PAIRED')
*              - path to data file in SRA format
*              and the following values in the header (also tab-separated):
*              - "study", "run", "organism", "strategy", "path"
*              IMPORTANT: Note that the header as well as the values for organism and
*              strategy have to be written precisely as indicated!
*/


/////////////////////////////////////////
//// ---> SET GLOBAL PARAMETERS <--- ////
/////////////////////////////////////////

// ---> GENERAL <--- //
sample_table_path      = "$table"
sample_table_id        = "$tableId"
resources_dir          = "$resDir"
resources_tmp_dir      = "$resTmpDir"

// ---> ORGANISM-SPECIFIC <--- //
prefix_hsa             = "$prefix_hsa"
prefix_mmu             = "$prefix_mmu"
prefix_ptr             = "$prefix_ptr"

// ---> COMPONENT-SPECIFIC <--- //
cutadapt_format        = "$cutadapt_format"
cutadapt_min_len       = "$cutadapt_minLen"
star_sjdb_overhang     = "$star_sjdbOverhang"
kallisto_frag_len_mean = "$kallisto_fragLenMean"
kallisto_frag_len_sd   = "$kallisto_fragLenSD"


///////////////////////////////////////
//// ---> IMPORT SAMPLE TABLE <--- ////
///////////////////////////////////////

sample_table = INPUT(
    path = sample_table_path,
    @name = "sample_table_" + sample_table_id
)


////////////////////////////////////////////////////
//// ---> PROCESSING OF INDIVIDUAL SAMPLES <--- ////
////////////////////////////////////////////////////

// ---> ITERATE OVER ROWS IN SAMPLE TABLE <--- //
for sample: std.itercsv(sample_table.in) {


    //////////////////////////////////////////////////
    //// ---> SET SAMPLE-SPECIFIC PARAMETERS <--- ////
    //////////////////////////////////////////////////

    // ---> SET SAMPLE NAME <--- //
    sample_name = sample.study + "_" + sample.run

    // ---> SET PREFIX ACCORDING TO ORGANISM  <--- //
    if ( sample.organism == "Homo sapiens" ) {
        prefix = prefix_hsa
    }
    if ( sample.organism == "Mus musculus" ) {
        prefix = prefix_mmu
    }
    if ( sample.organism == "Pan troglodytes" ) {
        prefix = prefix_ptr
    }

    // ---> SET ABSOLUTE PATH PREFIX FOR GENOME RESOURCES & INDICES <--- //
    gen_abs = resources_tmp_dir + "/" + prefix + "/"         + prefix
    ind_abs = resources_dir     + "/" + prefix + "/indices/"

    // ---> SET GENOME, ANNOTATION FILE & INDEX PATHS <--- //
    genome_path         = gen_abs + ".genome.filtered.fa"
    gene_anno_path      = gen_abs + ".gene_annotations.filtered.gtf"
    index_kallisto_path = ind_abs + "kallisto/" + prefix + ".transcriptome.filtered.idx"
    index_star_path     = ind_abs + "STAR/"     + prefix + ".genome.filtered.gene_annotations.filtered.136"
    events_suppa_path   = ind_abs + "SUPPA/"    + prefix + ".gene_annotations.filtered"


    ////////////////////////////////
    //// ---> IMPORT FILES <--- ////
    ////////////////////////////////

    // ---> IMPORT READ FILE <--- //
    read_file = INPUT(
        path  = sample.path,
        @name = "read_file_" + sample_name
    )

    // ---> IMPORT ORGANISM-SPECIFIC FILES <--- //
    genome = INPUT(
        path  = genome_path,
        @name = "genome_" + sample_name
    )
    gene_annotations = INPUT(
        path  = gene_anno_path,
        @name = "gene_annotations_" + sample_name
    )
    index_kallisto = INPUT(
        path  = index_kallisto_path,
        @name = "index_kallisto_" + sample_name
    )
    index_dir_star = INPUT(
        path  = index_star_path,
        @name = "index_dir_star_" + sample_name
    )
    events_dir_suppa = INPUT(
        path  = events_suppa_path,
        @name = "events_dir_suppa_" + sample_name
    )

    // ---> CONSTRUCT SUPPA IOE FILE ARRAY <--- //
    ioe_files_suppa = Folder2Array(
        events_dir_suppa,
        filePattern = "^_.*\\\\.ioe$",
        @name = "ioe_files_suppa_" + sample_name
    )


    /////////////////////////////////////////////////////////////////////////////////
    //// ---> MAPPING & ABUNDANCE ESTIMATION FUNCTION: SINGLE-END LIBRARIES <--- ////
    /////////////////////////////////////////////////////////////////////////////////

    function single(
        BinaryFile   read_file,
        BinaryFolder index_dir_star,
        BinaryFile   index_kallisto,
        string       sample_name,
        string       cutadapt_format,
        string       cutadapt_min_len,
        string       star_sjdb_overhang,
        string       kallisto_frag_len_mean,
        string       kallisto_frag_len_sd
    ) -> (
        BinaryFile   polyA_cut_stats,
        BinaryFolder alignments_out_dir,
        BinaryFolder abundances_out_dir
    ) {

        // ---> CONVERT READS TO FASTQ <--- //
        // fastq-dump.2.8.0
        fastq_dir = SRATools_FastqDump(
            INFILE_infile = read_file,
            gzip          = "{{TRUE}}",
            offset        = "33",
            _execMode     = "remote",
            _cores        = "1",
            _membycore    = "1500M",
            _runtime      = "06:00:00",
            @name         = "fastq_dir_" + sample_name
        )
        // ITERATE OVER FASTQ-DUMP OUTPUT DIRECTORY
        for file: std.iterdir(fastq_dir.OUTDIR_outdir, includeDir=false) {
            // CHECK FILE NAME
            check_file = std.strReplace(
                string  = file.name,
                match   = "^.*\\\\.fastq.*$",
                replace = "fastq"
            )
            // IMPORT FASTQ FILE
            if ( check_file == "fastq" ) {
                fastq = INPUT(
                    path = file.path,
                    @name = "fastq_" + sample_name
                )
            }
        }

        // ---> REMOVE POLY(A) TAIL <--- //
        // cutadapt 1.8.3
        polyA_cut = Cutadapt(
            INFILE_input   = fastq,
            format         = cutadapt_format,
            minimum_length = cutadapt_min_len,
            adapter        = "AAAAAAAAAAAAAAAAAAAAAAAAA",
            trim_n         = "{{TRUE}}",
            _execMode      = "remote",
            _cores         = "1",
            _membycore     = "1500M",
            _runtime       = "06:00:00",
            @name          = "polyA_cut_" + sample_name
        )

        // ---> ALIGN READS <--- //
        // STAR 2.4.1c
        alignments = STAR(
            INFILE_readFilesIn = polyA_cut.OUTFILE_output,
            INDIR_genomeDir    = index_dir_star,
            sjdbOverhang       = star_sjdb_overhang,
            runMode            = "alignReads",
            twopassMode        = "Basic",
            twopass1readsN     = "-1",
            _execMode          = "remote",
            _cores             = "8",
            _membycore         = "5G",
            _runtime           = "06:00:00",
            @name              = "alignments_" + sample_name
        )

        // ---> ESTIMATE EXPRESSION <--- //
        // kallisto 0.42.3
        abundances = kallistoQuant(
            INFILE_readseqs = polyA_cut.OUTFILE_output,
            INFILE_index    = index_kallisto,
            fragment_length = kallisto_frag_len_mean,
            sd              = kallisto_frag_len_sd,
            plaintext       = "{{TRUE}}",
            single          = "{{TRUE}}",
            _execMode       = "remote",
            _cores          = "8",
            _membycore      = "2G",
            _runtime        = "06:00:00",
            @name           = "abundances_" + sample_name
        )

        // ---> RETURN OUTPORTS <--- //
        return record(
            polyA_cut_stats     = polyA_cut.OUTFILE_report,
            alignments_out_dir  = alignments.OUTDIRMAKE_outFileNamePrefix,
            abundances_out_dir  = abundances.OUTDIR_output_dir
        )

    }


    /////////////////////////////////////////////////////////////////////////////////
    //// ---> MAPPING & ABUNDANCE ESTIMATION FUNCTION: PAIRED-END LIBRARIES <--- ////
    /////////////////////////////////////////////////////////////////////////////////

    function paired(
        BinaryFile   read_file,
        BinaryFolder index_dir_star,
        BinaryFile   index_kallisto,
        string       sample_name,
        string       cutadapt_format,
        string       cutadapt_min_len,
        string       star_sjdb_overhang
    ) -> (
        BinaryFile   polyA_cut_stats,
        BinaryFolder alignments_out_dir,
        BinaryFolder abundances_out_dir
    ) {

        // ---> CONVERT READS TO FASTQ <--- //
        // fastq-dump.2.8.0
        fastq_dir = SRATools_FastqDump(
            INFILE_infile = read_file,
            gzip          = "{{TRUE}}",
            offset        = "33",
            split_files   = "{{TRUE}}",
            _execMode     = "remote",
            _cores        = "1",
            _membycore    = "1500M",
            _runtime      = "06:00:00",
            @name         = "fastq_dir_" + sample_name
        )
        // ITERATE OVER FASTQ-DUMP OUTPUT DIRECTORY
        for file: std.iterdir(fastq_dir.OUTDIR_outdir, includeDir=false) {
            // CHECK MATE IDENTITY
            check_mate = std.strReplace(
                string  = file.name,
                match   = "^.*(_\\\\d)\\\\.fastq.*$",
                replace = "fastq\$1"
            )
            // IMPORT 1ST MATE FASTQ FILE
            if ( check_mate == "fastq_1" ) {
                fastq_1 = INPUT(
                    path = file.path,
                    @name = "fastq_1_" + sample_name
                )
            }
            // IMPORT 2ND MATE FASTQ FILE
            if ( check_mate == "fastq_2" ) {
                fastq_2 = INPUT(
                    path = file.path,
                    @name = "fastq_2_" + sample_name
                )
            }
        }

        // ---> REMOVE POLY(A) TAIL <--- //
        // cutadapt 1.8.3
        polyA_cut = Cutadapt(
            INFILE_input           = fastq_1,
            INFILE_input_mate      = fastq_2,
            format                 = cutadapt_format,
            minimum_length         = cutadapt_min_len,
            adapter                = "AAAAAAAAAAAAAAAAAAAA",
            front                  = "TTTTTTTTTTTTTTTTTTTT",
            A                      = "AAAAAAAAAAAAAAAAAAAA",
            G                      = "TTTTTTTTTTTTTTTTTTTT",
            trim_n                 = "{{TRUE}}",
            _OUTFILE_paired_output = "true",
            _execMode              = "remote",
            _cores                 = "1",
            _membycore             = "1500M",
            _runtime               = "06:00:00",
            @name                  = "polyA_cut_" + sample_name
        )

        // ---> ALIGN READS <--- //
        // STAR 2.4.1c
        alignments = STAR(
            INFILE_readFilesIn       = polyA_cut.OUTFILE_output,
            INFILE_readFilesIn_ADD_1 = polyA_cut.OUTFILE_paired_output,
            INDIR_genomeDir          = index_dir_star,
            sjdbOverhang             = star_sjdb_overhang,
            runMode                  = "alignReads",
            twopassMode              = "Basic",
            twopass1readsN           = "-1",
            _execMode                = "remote",
            _cores                   = "8",
            _membycore               = "5G",
            _runtime                 = "06:00:00",
            @name                    = "alignments_" + sample_name
        )

        // ---> ESTIMATE EXPRESSION <--- //
        // kallisto 0.42.3
        abundances = kallistoQuant(
            INFILE_readseqs        = polyA_cut.OUTFILE_output,
            INFILE_readseqs_paired = polyA_cut.OUTFILE_paired_output,
            INFILE_index           = index_kallisto,
            plaintext              = "{{TRUE}}",
            single                 = "{{FALSE}}",
            _execMode              = "remote",
            _cores                 = "8",
            _membycore             = "2G",
            _runtime               = "06:00:00",
            @name                  = "abundances_" + sample_name
        )

        // ---> RETURN OUTPORTS <--- //
        return record(
            polyA_cut_stats     = polyA_cut.OUTFILE_report,
            alignments_out_dir  = alignments.OUTDIRMAKE_outFileNamePrefix,
            abundances_out_dir  = abundances.OUTDIR_output_dir
        )

    }


    /////////////////////////////////////////////////////////////////////////////////
    //// ---> CALL LIBRARY-SPECIFIC MAPPING & ABUNDANCE ESTIMATION FUNCTION <--- ////
    /////////////////////////////////////////////////////////////////////////////////

    if ( sample.strategy == "SINGLE" ) {
        map_quant = single(
            read_file              = read_file,
            index_dir_star         = index_dir_star,
            index_kallisto         = index_kallisto,
            sample_name            = sample_name,
            cutadapt_format        = cutadapt_format,
            cutadapt_min_len       = cutadapt_min_len,
            star_sjdb_overhang     = star_sjdb_overhang,
            kallisto_frag_len_mean = kallisto_frag_len_mean,
            kallisto_frag_len_sd   = kallisto_frag_len_sd,
            @name                  = "map_quant_" + sample_name
        )
    }

    if ( sample.strategy == "PAIRED" ) {
        map_quant = paired(
            read_file              = read_file,
            index_dir_star         = index_dir_star,
            index_kallisto         = index_kallisto,
            sample_name            = sample_name,
            cutadapt_format        = cutadapt_format,
            cutadapt_min_len       = cutadapt_min_len,
            star_sjdb_overhang     = star_sjdb_overhang,
            @name                  = "map_quant_" + sample_name
        )
    }


    //////////////////////////////////////////////////////////////////////////
    //// ---> PROCESS MAPPING & ABUNDANCE ESTIMATION FUNCTION OUTPUT <--- ////
    //////////////////////////////////////////////////////////////////////////

    // ---> EXPORT POLY(A) REMOVAL STATS <--- //
    @out.out.filename = sample_name + ".processing.polyA_removal.stats"
    export_polyA_cut_stats = OUTPUT(
        map_quant.polyA_cut_stats,
        @name = "export_polyA_cut_stats_" + sample_name
    )

    // ---> IMPORT ALIGNMENTS AND EXPORT SPLICE JUNCTIONS, STATS & LOG <--- //
    for file: std.iterdir(map_quant.alignments_out_dir, includeDir=false) {
        // IMPORT ALIGNMENTS IN SAM FORMAT
        if ( file.name == "Aligned.out.sam" ) {
            alignments_sam = INPUT(
                path  = file.path,
                @name = "alignments_sam_" + sample_name
            )
        }
        // EXPORT SPLICE JUNCTIONS
        if ( file.name == "SJ.out.tab" ) {
            alignments_splice_junctions = INPUT(
                path  = file.path,
                @name = "alignments_splice_junctions_" + sample_name
            )
            @out.out.filename = sample_name + ".alignments.splice_junctions.tsv"
            export_alignments_splice_junctions = OUTPUT(
                alignments_splice_junctions,
                @name = "export_alignments_splice_junctions_" + sample_name
            )
        }
        // EXPORT STATS
        if ( file.name == "Log.final.out" ) {
            alignments_stats = INPUT(
                path  = file.path,
                @name = "alignments_stats_" + sample_name
            )
            @out.out.filename = sample_name + ".alignments.stats"
            export_alignments_stats = OUTPUT(
                alignments_stats,
                @name = "export_alignments_stats_" + sample_name
            )
        }
        // EXPORT LOG
        if ( file.name == "Log.out" ) {
            alignments_log = INPUT(
                path  = file.path,
                @name = "alignments_log_" + sample_name
            )
            @out.out.filename = sample_name + ".alignments.log"
            export_alignments_log = OUTPUT(
                alignments_log,
                @name = "export_alignments_log_" + sample_name
            )
        }
    }

    // ---> IMPORT AND EXPORT ABUNDANCES <--- //
    for file: std.iterdir(map_quant.abundances_out_dir, includeDir=false) {
        // IMPORT RAW ABUNDANCES IN KALLISTO FORMAT
        if ( file.name == "abundance.tsv" ) {
            abundances_raw = INPUT(
                path  = file.path,
                @name = "abundances_raw_" + sample_name
            )
            // EXPORT RAW ABUNDANCES
            @out.out.filename = sample_name + ".abundances.raw.tsv"
            export_abundances_raw = OUTPUT(
                abundances_raw,
                @name = "export_abudances_raw_" + sample_name
            )
        }
    }


    /////////////////////////////////////////////////////
    //// ---> COMPRESS, SORT & INDEX ALIGNMENTS <--- ////
    /////////////////////////////////////////////////////

    // ---> CONVERT ALIGNMENTS TO BAM <--- //
    // samtools 1.3.1
    alignments_bam = SAMtoolsView(
        INFILE_infile = alignments_sam,
        INFILE_T      = genome,
        b             = "{{TRUE}}",
        _execMode     = "remote",
        _cores        = "4",
        _membycore    = "1500M",
        _runtime      = "06:00:00",
        @name         = "alignments_bam_" + sample_name
    )

    // ---> SORT ALIGNMENTS & EXPORT <--- //
    // samtools 1.3.1
    alignments_sorted = SAMtoolsSort(
        INFILE_infile     = alignments_bam.OUTFILE_o,
        INFILE_reference  = genome,
        n                 = "{{FALSE}}",
        O                 = "bam",
        m                 = "3500M",
        _execMode         = "remote",
        _cores            = "6",
        _membycore        = "4G",
        _runtime          = "06:00:00",
        @name             = "alignments_sorted_" + sample_name
    )
    // EXPORT SORTED ALIGNMENTS
    @out.out.filename = sample_name + ".alignments.bam"
    export_alignments_sorted = OUTPUT(
        alignments_sorted.OUTFILE_o,
        @name = "export_alignments_sorted_" + sample_name
    )

    // ---> INDEX ALIGNMENTS & EXPORT <--- //
    // samtools 1.3.1
    alignments_index = SAMtoolsIndex(
        INFILE_infile = alignments_sorted.OUTFILE_o,
        _execMode     = "remote",
        _cores        = "1",
        _membycore    = "1500M",
        _runtime      = "00:30:00",
        @name         = "alignments_index_" + sample_name
    )
    // EXPORT INDEX
    @out.out.filename = sample_name + ".alignments.bam.bai"
    export_alignments_index = OUTPUT(
        alignments_index.OUTFILE_outfile,
        @name = "export_alignments_index_" + sample_name
    )


    ////////////////////////////////////////////////
    //// ---> EXTRACT TPM AND COUNT TABLES <--- ////
    ////////////////////////////////////////////////

    // ---> EXTRACT TPM TABLE <--- //
    // kallisto_extract_output.R v1.0 (alexander.kanitz@alumni.ethz.ch)
    abundances_tpm = kallistoExtractOutput(
        INDIR_inputDir = map_quant.abundances_out_dir,
        sampleName     = sample_name,
        verbose        = "{{TRUE}}",
        _execMode      = "remote",
        _cores         = "1",
        _membycore     = "1500M",
        _runtime       = "0:30:00",
        @name          = "abundances_tpm_" + sample_name
    )
    // EXPORT TPM TABLE
    @out.out.filename = sample_name + ".abundances.tpm"
    export_abundances_tpm = OUTPUT(
        abundances_tpm.OUTFILE_outFile,
        @name = "export_abundances_tpm_" + sample_name
    )

    // ---> EXTRACT COUNT TABLE <--- //
    // kallisto_extract_output.R v1.0 (alexander.kanitz@alumni.ethz.ch)
    abundances_counts = kallistoExtractOutput(
        INDIR_inputDir = map_quant.abundances_out_dir,
        sampleName     = sample_name,
        counts         = "{{TRUE}}",
        round          = "{{TRUE}}",
        verbose        = "{{TRUE}}",
        _execMode      = "remote",
        _cores         = "1",
        _membycore     = "1500M",
        _runtime       = "0:30:00",
        @name          = "abundances_counts_" + sample_name
    )
    // EXPORT COUNT TABLE
    @out.out.filename = sample_name + ".abundances.counts"
    export_abundances_counts = OUTPUT(
        abundances_counts.OUTFILE_outFile,
        @name = "export_abundances_counts_" + sample_name
    )


    //////////////////////////////////////////
    //// ---> ISOFORM USAGE ANALYSIS <--- ////
    //////////////////////////////////////////

    // ---> CALCULATE & EXPORT ISOFORM USAGES IN PSI FORMAT <--- //
    // SUPPA v1.2b
    alternative_splicing_isoforms = SUPPAPsiPerIsoform(
        INFILE_gtf_file        = gene_annotations,
        INFILE_expression_file = abundances_tpm.OUTFILE_outFile,
        _execMode              = "remote",
        _cores                 = "1",
        _membycore             = "1500M",
        _runtime               = "0:30:00",
        @name                  = "alternative_splicing_isoforms_" + sample_name
    )
    // EXPORT ISOFORM USAGES
    for file: std.iterdir(alternative_splicing_isoforms, includeDir=false) {
        alternative_splicing_isoforms_psi = INPUT(
            path = file.path + "/OUTFILE_output_file_isoform.psi",
            @name = "alternative_splicing_isoforms_psi_" + sample_name
        )
    }
    @out.out.filename = sample_name + ".alternative_splicing.isoforms.psi"
    export_alternative_splicing_isoforms_psi = OUTPUT(
        alternative_splicing_isoforms_psi,
        @name = "export_alternative_splicing_isoforms_psi_" + sample_name
    )


    ///////////////////////////////////////////////////////
    //// ---> ALTERNATIVE SPLICING EVENT ANALYSIS <--- ////
    ///////////////////////////////////////////////////////

    // ---> ITERATE OVER AS EVENT CLASSES <--- //
    for ioe: std.iterArray(ioe_files_suppa.array) {

        // ---> GET NAME OF EVENT CLASS <--- //
        event_class = std.strReplace(
            string  = ioe.file,
            match   = "(^.*\\\\/_)(\\\\w{2})(_strict\\\\.\\\\w{3}$)",
            replace = "\$2"
        )

        // ---> CALCULATE PSI PER ALTERNATIVE SPLICING EVENT <--- //
        // SUPPA v1.2b
        alternative_splicing_events = SUPPAPsiPerEvent(
            INFILE_ioe_file        = ioe_files_suppa.array[ioe.key],
            INFILE_expression_file = abundances_tpm.OUTFILE_outFile,
            _execMode              = "remote",
            _cores                 = "1",
            _membycore             = "1500M",
            _runtime               = "0:30:00",
            @name                  = "alternative_splicing_events_" + event_class + "_" + sample_name
        )
        // EXPORT EVENT PSI
        for file: std.iterdir(alternative_splicing_events, includeDir=false) {
            alternative_splicing_events_psi = INPUT(
                path = file.path + "/OUTFILE_output_file.psi",
                @name = "alternative_splicing_events_psi_" + event_class + "_" + sample_name
            )
        }
        @out.out.filename = sample_name + ".alternative_splicing.events." + event_class + ".psi"
        export_alternative_splicing_events_psi = OUTPUT(
            alternative_splicing_events_psi,
            @name = "export_alternative_splicing_events_psi_" + event_class + "_" + sample_name
        )

    }

}
EOF

    # Write log
    echo "Anduril network file written to '$workflow'..." >> "$logFile"

done


#############
###  END  ###
#############

echo "Processed sample tables in: $inDir" >> "$logFile"
echo "Anduril network files written to: $outDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
