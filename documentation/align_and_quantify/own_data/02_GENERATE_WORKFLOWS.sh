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

# Set dataset name
prefix="own_data"

# Set STAR parameter '--sjdbOverhang'
# Has to match the value used during index generation
# Ideally: read length - 1 (longer reduces efficiency, shorter reduces accuracy)
# For paired-end libraries: read length per mate, *not* per pair
star_sjdbOverhang=135

# Set cutadapt parameter '--minimum-length'
# Shorter reads (after trimming) will be discarded
cutadapt_minLen=20

# Set other parameters (DO NOT CHANGE!)
root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"
inDir="${root}/.tmp/frameworksAuxiliary/anduril/align_and_quantify/${prefix}/sample_tables"
outDir="${root}/.tmp/frameworksAuxiliary/anduril/align_and_quantify/${prefix}/workflows"
logDir="${root}/logFiles/analyzedData/align_and_quantify/${prefix}"
inPrefix="table."
inGlobPattern=???
inSuffix=".tsv"
outPrefix="${outDir}/workflow."
outSuffix=".and"
resDir="${root}/publicResources/genome_resources"
resTmpDir="${root}/.tmp/publicResources/genome_resources"


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
* Date:        Mar 31, 2017
* Description: Given a table of RNA-Seq samples, aligns reads and estimates transcript
*              abundances and alternative splicing:
*              - Alignments: 'star' (https://github.com/alexdobin/star)
*              - Quantification: 'kallisto' (http://pachterlab.github.io/kallisto/)
*              - AS events: 'suppa' (https://bitbucket.org/regulatorygenomicsupf/suppa)
* Requires:    A tab-separated sample table with the following fields:
*              - sample name
*              - organism (one of 'Homo sapiens', 'Mus musculus' or 'Pan troglodytes')
*              - sequencing strategy (one of 'SINGLE' or 'PAIRED')
*              - format (one of 'FASTQ', 'FASTA' or 'SRA')
*              - mean of fragment length distribution
*              - standard deviation of fragment length distribution
*              - 3' adapter for first mate reads / 'SINGLE' (leave empty if no removal is desired)
*              - 3' adapter for second mate reads (required if 3' adapter is provided and strategy 
*              is 'PAIRED'; else can be left empty)
*              - path to first mate reads / 'SINGLE' data file
*              - path to second mate reads data file (required if 'PAIRED')
*              and the following values in the header (also tab-separated):
*              - "name"
*              - "organism"
*              - "strategy"
*              - "format"
*              - "fragLenMean"
*              - "fragLenSD"
*              - "adapt3"
*              - "adapt3_mate"
*              - "path"
*              - "path_mate"
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

// ---> COMPONENT-SPECIFIC <--- //
cutadapt_min_len       = "$cutadapt_minLen"
star_sjdb_overhang     = "$star_sjdbOverhang"


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

    // ---> SET ABSOLUTE PATH PREFIX FOR GENOME RESOURCES & INDICES <--- //
    gen_abs = resources_tmp_dir + "/" + sample.organism + "/"         + sample.organism
    ind_abs = resources_dir     + "/" + sample.organism + "/indices/"

    // ---> SET GENOME, ANNOTATION FILE & INDEX PATHS <--- //
    genome_path         = gen_abs + ".genome.filtered.fa"
    gene_anno_path      = gen_abs + ".gene_annotations.filtered.gtf"
    index_kallisto_path = ind_abs + "kallisto/" + sample.organism + ".transcriptome.filtered.idx"
    index_star_path     = ind_abs + "STAR/"     + sample.organism + ".genome.filtered.gene_annotations.filtered.$((star_sjdbOverhang + 1))"
    events_suppa_path   = ind_abs + "SUPPA/"    + sample.organism + ".gene_annotations.filtered"


    ////////////////////////////////
    //// ---> IMPORT FILES <--- ////
    ////////////////////////////////

    // ---> IMPORT READ FILES <--- //
    read_file = INPUT(
        path  = sample.path,
        @name = "read_file_" + sample.name
    )
    if ( sample.path_mate != "" ) {
        read_file_mate = INPUT(
            path  = sample.path_mate,
            @name = "read_file_mate_" + sample.name
        )
    }

    // ---> IMPORT ORGANISM-SPECIFIC FILES <--- //
    genome = INPUT(
        path  = genome_path,
        @name = "genome_" + sample.name
    )
    gene_annotations = INPUT(
        path  = gene_anno_path,
        @name = "gene_annotations_" + sample.name
    )
    index_kallisto = INPUT(
        path  = index_kallisto_path,
        @name = "index_kallisto_" + sample.name
    )
    index_dir_star = INPUT(
        path  = index_star_path,
        @name = "index_dir_star_" + sample.name
    )
    events_dir_suppa = INPUT(
        path  = events_suppa_path,
        @name = "events_dir_suppa_" + sample.name
    )

    // ---> CONSTRUCT SUPPA IOE FILE ARRAY <--- //
    ioe_files_suppa = Folder2Array(
        events_dir_suppa,
        filePattern = "^_.*\\\\.ioe$",
        @name = "ioe_files_suppa_" + sample.name
    )


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //// ---> MAPPING & ABUNDANCE ESTIMATION FUNCTION: SINGLE-END SRA LIBRARIES WITHOUT ADAPTER REMOVAL <--- ////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function sra_single_noAdapt(
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


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //// ---> MAPPING & ABUNDANCE ESTIMATION FUNCTION: PAIRED-END SRA LIBRARIES WITHOUT ADAPTER REMOVAL <--- ////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function sra_paired_noAdapt(
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


    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //// ---> MAPPING & ABUNDANCE ESTIMATION FUNCTION: SINGLE-END SRA LIBRARIES WITH ADAPTER REMOVAL <--- ////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    function sra_single_adapt(
        BinaryFile   read_file,
        BinaryFolder index_dir_star,
        BinaryFile   index_kallisto,
        string       sample_name,
        string       cutadapt_adapt3,
        string       cutadapt_format,
        string       cutadapt_min_len,
        string       star_sjdb_overhang,
        string       kallisto_frag_len_mean,
        string       kallisto_frag_len_sd
    ) -> (
        BinaryFile   adapt3_cut_stats,
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

        // ---> REMOVE 3' ADAPTER <--- //
        // cutadapt 1.8.3
        adapt3_cut = Cutadapt(
            INFILE_input   = fastq,
            adapter        = cutadapt_adapt3,
            format         = cutadapt_format,
            minimum_length = cutadapt_min_len,
            trim_n         = "{{TRUE}}",
            _execMode      = "remote",
            _cores         = "1",
            _membycore     = "1500M",
            _runtime       = "06:00:00",
            @name          = "adapt3_cut_" + sample.name
        )

        // ---> REMOVE POLY(A) TAIL <--- //
        // cutadapt 1.8.3
        polyA_cut = Cutadapt(
            INFILE_input   = adapt3_cut.OUTFILE_output,
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
            adapt3_cut_stats    = adapt3_cut.OUTFILE_report,
            polyA_cut_stats     = polyA_cut.OUTFILE_report,
            alignments_out_dir  = alignments.OUTDIRMAKE_outFileNamePrefix,
            abundances_out_dir  = abundances.OUTDIR_output_dir
        )

    }


    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //// ---> MAPPING & ABUNDANCE ESTIMATION FUNCTION: PAIRED-END SRA LIBRARIES WITH ADAPTER REMOVAL <--- ////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    function sra_paired_adapt(
        BinaryFile   read_file,
        BinaryFolder index_dir_star,
        BinaryFile   index_kallisto,
        string       sample_name,
        string       cutadapt_adapt3,
        string       cutadapt_adapt3_mate,
        string       cutadapt_format,
        string       cutadapt_min_len,
        string       star_sjdb_overhang
    ) -> (
        BinaryFile   adapt3_cut_stats,
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

        // ---> REMOVE 3' ADAPTER <--- //
        // cutadapt 1.8.3
        adapt3_cut = Cutadapt(
            INFILE_input           = fastq_1,
            INFILE_input_mate      = fastq_2,
            adapter                = cutadapt_adapt3,
            A                      = cutadapt_adapt3_mate,
            format                 = cutadapt_format,
            minimum_length         = cutadapt_min_len,
            trim_n                 = "{{TRUE}}",
            _OUTFILE_paired_output = "true",
            _execMode              = "remote",
            _cores                 = "1",
            _membycore             = "1500M",
            _runtime               = "06:00:00",
            @name                  = "adapt3_cut_" + sample.name
        )

        // ---> REMOVE POLY(A) TAIL <--- //
        // cutadapt 1.8.3
        polyA_cut = Cutadapt(
            INFILE_input           = adapt3_cut.OUTFILE_output,
            INFILE_input_mate      = adapt3_cut.OUTFILE_paired_output,
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
            adapt3_cut_stats    = adapt3_cut.OUTFILE_report,
            polyA_cut_stats     = polyA_cut.OUTFILE_report,
            alignments_out_dir  = alignments.OUTDIRMAKE_outFileNamePrefix,
            abundances_out_dir  = abundances.OUTDIR_output_dir
        )

    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //// ---> MAPPING & ABUNDANCE ESTIMATION FUNCTION: SINGLE-END FASTX LIBRARIES WITHOUT ADAPTER REMOVAL <--- ////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function fastx_single_noAdapt(
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

        // ---> REMOVE POLY(A) TAIL <--- //
        // cutadapt 1.8.3
        polyA_cut = Cutadapt(
            INFILE_input   = read_file,
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


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //// ---> MAPPING & ABUNDANCE ESTIMATION FUNCTION: PAIRED-END FASTX LIBRARIES WITHOUT ADAPTER REMOVAL <--- ////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function fastx_paired_noAdapt(
        BinaryFile   read_file,
        BinaryFile   read_file_mate,
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

        // ---> REMOVE POLY(A) TAIL <--- //
        // cutadapt 1.8.3
        polyA_cut = Cutadapt(
            INFILE_input           = read_file,
            INFILE_input_mate      = read_file_mate,
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


    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //// ---> MAPPING & ABUNDANCE ESTIMATION FUNCTION: SINGLE-END FASTX LIBRARIES WITH ADAPTER REMOVAL <--- ////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function fastx_single_adapt(
        BinaryFile   read_file,
        BinaryFolder index_dir_star,
        BinaryFile   index_kallisto,
        string       sample_name,
        string       cutadapt_adapt3,
        string       cutadapt_format,
        string       cutadapt_min_len,
        string       star_sjdb_overhang,
        string       kallisto_frag_len_mean,
        string       kallisto_frag_len_sd
    ) -> (
        BinaryFile   adapt3_cut_stats,
        BinaryFile   polyA_cut_stats,
        BinaryFolder alignments_out_dir,
        BinaryFolder abundances_out_dir
    ) {

        // ---> REMOVE 3' ADAPTER <--- //
        // cutadapt 1.8.3
        adapt3_cut = Cutadapt(
            INFILE_input   = read_file,
            adapter        = cutadapt_adapt3,
            format         = cutadapt_format,
            minimum_length = cutadapt_min_len,
            trim_n         = "{{TRUE}}",
            _execMode      = "remote",
            _cores         = "1",
            _membycore     = "1500M",
            _runtime       = "06:00:00",
            @name          = "adapt3_cut_" + sample.name
        )

        // ---> REMOVE POLY(A) TAIL <--- //
        // cutadapt 1.8.3
        polyA_cut = Cutadapt(
            INFILE_input   = adapt3_cut.OUTFILE_output,
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
            adapt3_cut_stats    = adapt3_cut.OUTFILE_report,
            polyA_cut_stats     = polyA_cut.OUTFILE_report,
            alignments_out_dir  = alignments.OUTDIRMAKE_outFileNamePrefix,
            abundances_out_dir  = abundances.OUTDIR_output_dir
        )

    }


    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //// ---> MAPPING & ABUNDANCE ESTIMATION FUNCTION: PAIRED-END FASTX LIBRARIES WITH ADAPTER REMOVAL <--- ////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function fastx_paired_adapt(
        BinaryFile   read_file,
        BinaryFile   read_file_mate,
        BinaryFolder index_dir_star,
        BinaryFile   index_kallisto,
        string       sample_name,
        string       cutadapt_adapt3,
        string       cutadapt_adapt3_mate,
        string       cutadapt_format,
        string       cutadapt_min_len,
        string       star_sjdb_overhang
    ) -> (
        BinaryFile   adapt3_cut_stats,
        BinaryFile   polyA_cut_stats,
        BinaryFolder alignments_out_dir,
        BinaryFolder abundances_out_dir
    ) {

        // ---> REMOVE 3' ADAPTER <--- //
        // cutadapt 1.8.3
        adapt3_cut = Cutadapt(
            INFILE_input           = read_file,
            INFILE_input_mate      = read_file_mate,
            adapter                = cutadapt_adapt3,
            A                      = cutadapt_adapt3_mate,
            format                 = cutadapt_format,
            minimum_length         = cutadapt_min_len,
            trim_n                 = "{{TRUE}}",
            _OUTFILE_paired_output = "true",
            _execMode              = "remote",
            _cores                 = "1",
            _membycore             = "1500M",
            _runtime               = "06:00:00",
            @name                  = "adapt3_cut_" + sample.name
        )

        // ---> REMOVE POLY(A) TAIL <--- //
        // cutadapt 1.8.3
        polyA_cut = Cutadapt(
            INFILE_input           = adapt3_cut.OUTFILE_output,
            INFILE_input_mate      = adapt3_cut.OUTFILE_paired_output,
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
            adapt3_cut_stats    = adapt3_cut.OUTFILE_report,
            polyA_cut_stats     = polyA_cut.OUTFILE_report,
            alignments_out_dir  = alignments.OUTDIRMAKE_outFileNamePrefix,
            abundances_out_dir  = abundances.OUTDIR_output_dir
        )

    }


    /////////////////////////////////////////////////////////////////////////////////
    //// ---> CALL LIBRARY-SPECIFIC MAPPING & ABUNDANCE ESTIMATION FUNCTION <--- ////
    /////////////////////////////////////////////////////////////////////////////////

    if ( sample.format == "SRA" ) {

        if ( sample.adapt3 == "" ) {

            if ( sample.strategy == "SINGLE" ) {
                map_quant = sra_single_noAdapt(
                    read_file              = read_file,
                    index_dir_star         = index_dir_star,
                    index_kallisto         = index_kallisto,
                    sample_name            = sample.name,
                    cutadapt_format        = sample.format,
                    cutadapt_min_len       = cutadapt_min_len,
                    star_sjdb_overhang     = star_sjdb_overhang,
                    kallisto_frag_len_mean = sample.fragLenMean,
                    kallisto_frag_len_sd   = sample.fragLenSD,
                    @name                  = "map_quant_" + sample.name
                )
            }

            if ( sample.strategy == "PAIRED" ) {
                map_quant = sra_paired_noAdapt(
                    read_file              = read_file,
                    index_dir_star         = index_dir_star,
                    index_kallisto         = index_kallisto,
                    sample_name            = sample.name,
                    cutadapt_format        = sample.format,
                    cutadapt_min_len       = cutadapt_min_len,
                    star_sjdb_overhang     = star_sjdb_overhang,
                    @name                  = "map_quant_" + sample.name
                )
            }

        } else {

            if ( sample.strategy == "SINGLE" ) {
                map_quant = sra_single_adapt(
                    read_file              = read_file,
                    index_dir_star         = index_dir_star,
                    index_kallisto         = index_kallisto,
                    sample_name            = sample.name,
                    cutadapt_adapt3        = sample.adapt3,
                    cutadapt_format        = sample.format,
                    cutadapt_min_len       = cutadapt_min_len,
                    star_sjdb_overhang     = star_sjdb_overhang,
                    kallisto_frag_len_mean = sample.fragLenMean,
                    kallisto_frag_len_sd   = sample.fragLenSD,
                    @name                  = "map_quant_" + sample.name
                )
            }

            if ( sample.strategy == "PAIRED" ) {
                map_quant = sra_paired_adapt(
                    read_file              = read_file,
                    index_dir_star         = index_dir_star,
                    index_kallisto         = index_kallisto,
                    sample_name            = sample.name,
                    cutadapt_adapt3        = sample.adapt3,
                    cutadapt_adapt3_mate   = sample.adapt3_mate,
                    cutadapt_format        = sample.format,
                    cutadapt_min_len       = cutadapt_min_len,
                    star_sjdb_overhang     = star_sjdb_overhang,
                    @name                  = "map_quant_" + sample.name
                )
            }

        }

    } else {

        if ( sample.adapt3 == "" ) {

            if ( sample.strategy == "SINGLE" ) {
                map_quant = fastx_single_noAdapt(
                    read_file              = read_file,
                    index_dir_star         = index_dir_star,
                    index_kallisto         = index_kallisto,
                    sample_name            = sample.name,
                    cutadapt_format        = sample.format,
                    cutadapt_min_len       = cutadapt_min_len,
                    star_sjdb_overhang     = star_sjdb_overhang,
                    kallisto_frag_len_mean = sample.fragLenMean,
                    kallisto_frag_len_sd   = sample.fragLenSD,
                    @name                  = "map_quant_" + sample.name
                )
            }

            if ( sample.strategy == "PAIRED" ) {
                map_quant = fastx_paired_noAdapt(
                    read_file              = read_file,
                    read_file_mate         = read_file_mate,
                    index_dir_star         = index_dir_star,
                    index_kallisto         = index_kallisto,
                    sample_name            = sample.name,
                    cutadapt_format        = sample.format,
                    cutadapt_min_len       = cutadapt_min_len,
                    star_sjdb_overhang     = star_sjdb_overhang,
                    @name                  = "map_quant_" + sample.name
                )
            }

        } else {

            if ( sample.strategy == "SINGLE" ) {
                map_quant = fastx_single_adapt(
                    read_file              = read_file,
                    index_dir_star         = index_dir_star,
                    index_kallisto         = index_kallisto,
                    sample_name            = sample.name,
                    cutadapt_adapt3        = sample.adapt3,
                    cutadapt_format        = sample.format,
                    cutadapt_min_len       = cutadapt_min_len,
                    star_sjdb_overhang     = star_sjdb_overhang,
                    kallisto_frag_len_mean = sample.fragLenMean,
                    kallisto_frag_len_sd   = sample.fragLenSD,
                    @name                  = "map_quant_" + sample.name
                )
            }

            if ( sample.strategy == "PAIRED" ) {
                map_quant = fastx_paired_adapt(
                    read_file              = read_file,
                    read_file_mate         = read_file_mate,
                    index_dir_star         = index_dir_star,
                    index_kallisto         = index_kallisto,
                    sample_name            = sample.name,
                    cutadapt_adapt3        = sample.adapt3,
                    cutadapt_adapt3_mate   = sample.adapt3_mate,
                    cutadapt_format        = sample.format,
                    cutadapt_min_len       = cutadapt_min_len,
                    star_sjdb_overhang     = star_sjdb_overhang,
                    @name                  = "map_quant_" + sample.name
                )
            }

        }

    }



    //////////////////////////////////////////////////////////////////////////
    //// ---> PROCESS MAPPING & ABUNDANCE ESTIMATION FUNCTION OUTPUT <--- ////
    //////////////////////////////////////////////////////////////////////////

    // ---> EXPORT ADAPTER REMOVAL STATS <--- //
    if ( sample.adapt3 != "" ) {
        @out.out.filename = sample.name + ".processing.adapt3_removal.stats"
        export_adapt3_cut_stats = OUTPUT(
            map_quant.adapt3_cut_stats,
            @name = "export_adapt3_cut_stats_" + sample.name
        )
    }

    // ---> EXPORT POLY(A) REMOVAL STATS <--- //
    @out.out.filename = sample.name + ".processing.polyA_removal.stats"
    export_polyA_cut_stats = OUTPUT(
        map_quant.polyA_cut_stats,
        @name = "export_polyA_cut_stats_" + sample.name
    )

    // ---> IMPORT ALIGNMENTS AND EXPORT SPLICE JUNCTIONS, STATS & LOG <--- //
    for file: std.iterdir(map_quant.alignments_out_dir, includeDir=false) {
        // IMPORT ALIGNMENTS IN SAM FORMAT
        if ( file.name == "Aligned.out.sam" ) {
            alignments_sam = INPUT(
                path  = file.path,
                @name = "alignments_sam_" + sample.name
            )
        }
        // EXPORT SPLICE JUNCTIONS
        if ( file.name == "SJ.out.tab" ) {
            alignments_splice_junctions = INPUT(
                path  = file.path,
                @name = "alignments_splice_junctions_" + sample.name
            )
            @out.out.filename = sample.name + ".alignments.splice_junctions.tsv"
            export_alignments_splice_junctions = OUTPUT(
                alignments_splice_junctions,
                @name = "export_alignments_splice_junctions_" + sample.name
            )
        }
        // EXPORT STATS
        if ( file.name == "Log.final.out" ) {
            alignments_stats = INPUT(
                path  = file.path,
                @name = "alignments_stats_" + sample.name
            )
            @out.out.filename = sample.name + ".alignments.stats"
            export_alignments_stats = OUTPUT(
                alignments_stats,
                @name = "export_alignments_stats_" + sample.name
            )
        }
        // EXPORT LOG
        if ( file.name == "Log.out" ) {
            alignments_log = INPUT(
                path  = file.path,
                @name = "alignments_log_" + sample.name
            )
            @out.out.filename = sample.name + ".alignments.log"
            export_alignments_log = OUTPUT(
                alignments_log,
                @name = "export_alignments_log_" + sample.name
            )
        }
    }

    // ---> IMPORT AND EXPORT ABUNDANCES <--- //
    for file: std.iterdir(map_quant.abundances_out_dir, includeDir=false) {
        // IMPORT RAW ABUNDANCES IN KALLISTO FORMAT
        if ( file.name == "abundance.tsv" ) {
            abundances_raw = INPUT(
                path  = file.path,
                @name = "abundances_raw_" + sample.name
            )
            // EXPORT RAW ABUNDANCES
            @out.out.filename = sample.name + ".abundances.raw.tsv"
            export_abundances_raw = OUTPUT(
                abundances_raw,
                @name = "export_abudances_raw_" + sample.name
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
        @name         = "alignments_bam_" + sample.name
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
        _cores            = "8",
        _membycore        = "4G",
        _runtime          = "06:00:00",
        @name             = "alignments_sorted_" + sample.name
    )
    // EXPORT SORTED ALIGNMENTS
    @out.out.filename = sample.name + ".alignments.bam"
    export_alignments_sorted = OUTPUT(
        alignments_sorted.OUTFILE_o,
        @name = "export_alignments_sorted_" + sample.name
    )

    // ---> INDEX ALIGNMENTS & EXPORT <--- //
    // samtools 1.3.1
    alignments_index = SAMtoolsIndex(
        INFILE_infile = alignments_sorted.OUTFILE_o,
        _execMode     = "remote",
        _cores        = "1",
        _membycore    = "1500M",
        _runtime      = "00:30:00",
        @name         = "alignments_index_" + sample.name
    )
    // EXPORT INDEX
    @out.out.filename = sample.name + ".alignments.bam.bai"
    export_alignments_index = OUTPUT(
        alignments_index.OUTFILE_outfile,
        @name = "export_alignments_index_" + sample.name
    )


    ////////////////////////////////////////////////
    //// ---> EXTRACT TPM AND COUNT TABLES <--- ////
    ////////////////////////////////////////////////

    // ---> EXTRACT TPM TABLE <--- //
    // kallisto_extract_output.R v1.0 (alexander.kanitz@alumni.ethz.ch)
    abundances_tpm = kallistoExtractOutput(
        INDIR_inputDir = map_quant.abundances_out_dir,
        sampleName     = sample.name,
        verbose        = "{{TRUE}}",
        _execMode      = "remote",
        _cores         = "1",
        _membycore     = "1500M",
        _runtime       = "0:30:00",
        @name          = "abundances_tpm_" + sample.name
    )
    // EXPORT TPM TABLE
    @out.out.filename = sample.name + ".abundances.tpm"
    export_abundances_tpm = OUTPUT(
        abundances_tpm.OUTFILE_outFile,
        @name = "export_abundances_tpm_" + sample.name
    )

    // ---> EXTRACT COUNT TABLE <--- //
    // kallisto_extract_output.R v1.0 (alexander.kanitz@alumni.ethz.ch)
    abundances_counts = kallistoExtractOutput(
        INDIR_inputDir = map_quant.abundances_out_dir,
        sampleName     = sample.name,
        counts         = "{{TRUE}}",
        round          = "{{TRUE}}",
        verbose        = "{{TRUE}}",
        _execMode      = "remote",
        _cores         = "1",
        _membycore     = "1500M",
        _runtime       = "0:30:00",
        @name          = "abundances_counts_" + sample.name
    )
    // EXPORT COUNT TABLE
    @out.out.filename = sample.name + ".abundances.counts"
    export_abundances_counts = OUTPUT(
        abundances_counts.OUTFILE_outFile,
        @name = "export_abundances_counts_" + sample.name
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
        @name                  = "alternative_splicing_isoforms_" + sample.name
    )
    // EXPORT ISOFORM USAGES
    for file: std.iterdir(alternative_splicing_isoforms, includeDir=false) {
        alternative_splicing_isoforms_psi = INPUT(
            path = file.path + "/OUTFILE_output_file_isoform.psi",
            @name = "alternative_splicing_isoforms_psi_" + sample.name
        )
    }
    @out.out.filename = sample.name + ".alternative_splicing.isoforms.psi"
    export_alternative_splicing_isoforms_psi = OUTPUT(
        alternative_splicing_isoforms_psi,
        @name = "export_alternative_splicing_isoforms_psi_" + sample.name
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
            @name                  = "alternative_splicing_events_" + event_class + "_" + sample.name
        )
        // EXPORT EVENT PSI
        for file: std.iterdir(alternative_splicing_events, includeDir=false) {
            alternative_splicing_events_psi = INPUT(
                path = file.path + "/OUTFILE_output_file.psi",
                @name = "alternative_splicing_events_psi_" + event_class + "_" + sample.name
            )
        }
        @out.out.filename = sample.name + ".alternative_splicing.events." + event_class + ".psi"
        export_alternative_splicing_events_psi = OUTPUT(
            alternative_splicing_events_psi,
            @name = "export_alternative_splicing_events_psi_" + event_class + "_" + sample.name
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
