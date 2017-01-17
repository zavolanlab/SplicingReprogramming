#!/usr/bin/env Rscript
# (c) 2016, Alexander Kanitz, Biozentrum, Universiry of Basel
# email: alexander.kanitz@alumni.ethz.ch

#######################
###  PARSE OPTIONS  ###
#######################

#---> LOAD OPTION PARSER <---#
if ( suppressWarnings(suppressPackageStartupMessages(require("optparse"))) == FALSE ) { stop("[ERROR] Package 'optparse' required! Aborted.") }

#---> GET SCRIPT NAME <---#
script <- sub("--file=", "", basename(commandArgs(trailingOnly=FALSE)[4]))

#---> DESCRIPTION <---#
description <- "Generates merged gene symbol identifiers for orthologous Ensembl gene IDs."
author <- "Author: Alexander Kanitz, Biozentrum, University of Basel"
version <- "Version: 1.0.0 (05-DEC-2016)"
requirements <- "Requires: optparse"
msg <- paste(description, author, version, requirements, sep="\n")

#---> COMMAND-LINE ARGUMENTS <---#
## List of allowed/recognized arguments
option_list <- list(
                make_option(
                    c("-i", "--input-table"),
                    action="store",
                    type="character",
                    default=NULL,
                    help="Input data table containing orthologous Ensembl gene IDs (one organism per column). Required.",
                    metavar="file"
                ),
                make_option(
                    c("-o", "--output-table"),
                    action="store",
                    type="character",
                    default=NULL,
                    help="Output table containing orthologous Ensembl gene IDs, corresponding gene symbols and merged gene symbol. Required.",
                    metavar="file"
                ),
                make_option(
                    c("-g", "--grouping-tables"),
                    action="store",
                    type="character",
                    default=NULL,
                    help="Ensembl gene ID to gene symbol tables. One for each organism, in the order specified by '--id-columns'. Separated by comma and no whitespace. Required.",
                    metavar="files"
                ),
                make_option(
                    "--id-columns",
                    action="store",
                    type="character",
                    default=NULL,
                    help="Columns of '--input-table' containing orthologous Ensembl gene IDs. Order (of organisms) dictates that of '--grouping-tables'. Specify column index (1-based) of all columns to include separted by comma and no whitespace. Default: 1,...,N.",
                    metavar="ints"
                ),
                make_option(
                    "--group-id-columns",
                    action="store",
                    type="character",
                    default=1,
                    help="The fields/columns (1-based) in the grouping tables containing Ensembl gene IDs. Separated by comma and no whitespace. If less field indices are specified than '--id-columns', they will be recycled according to standard R rules. Default: 1.",
                    metavar="ints"
                ),
                make_option(
                    "--group-symbol-columns",
                    action="store",
                    type="character",
                    default=2,
                    help="The fields/columns (1-based) in the groupings table containing gene symbols. Separated by comman and no whitespace. If less field indices are specified than '--id-columns', they will be recycled according to standard R rules. Default: 2.",
                    metavar="ints"
                ),
                make_option(
                    "--has-header-input-table",
                    action="store_true",
                    default=FALSE,
                    help="Indicates whether the input data table has a header line. Default: FALSE."
                ),
                make_option(
                    "--has-header-grouping-tables",
                    action="store",
                    type="character",
                    default="FALSE",
                    help="Indicates whether the grouping tables have a header line. Specifiy either 'FALSE' or 'TRUE' for each grouping table, separated by comma and no whitespace. If less values are specified than '--grouping-tables', they will be recycled according to standard R rules. Default: 'FALSE'.",
                    metavar="bools"
                ),
                make_option(
                    "--merge-character",
                    action="store",
                    type="character",
                    default="|",
                    help="The character used to merging gene symbols of orthologous Ensembl gene IDs. Default: '|'",
                    metavar="char"
                ),
                make_option(
                    c("-h", "--help"),
                    action="store_true",
                    default=FALSE,
                    help="Show this information and die."
                ),
                make_option(
                    c("-u", "--usage"),
                    action="store_true",
                    default=FALSE,
                    dest="help",
                    help="Show this information and die."
                ),
                make_option(
                    c("-v", "--verbose"),
                    action="store_true",
                    default=FALSE,
                    help="Print log messages to STDOUT."
                )
)

## Parse command-line arguments
opt_parser <- OptionParser(usage=paste("Usage:", script, "[OPTIONS] --input-table <FILE> --output-table <FILE> --grouping-tables <FILE_1,...,FILE_N>\n", sep=" "), option_list = option_list, add_help_option=FALSE, description=msg)
opt <- parse_args(opt_parser)

#---> ARGUMENT VALIDATION <---#

## Die if any required arguments are missing...
if ( is.null(opt$`input-table`) | is.null(opt$`output-table`) | is.null(opt$`grouping-tables`) ) {
        print_help(opt_parser)
        stop("[ERROR] Required argument missing! Aborted.")
}

## Convert strings to vectors
files.lookup <- as.character(unlist(strsplit(opt$`grouping-tables`, ",")))
cols.lookup.id <- as.integer(unlist(strsplit(opt$`group-id-columns`, ",")))
cols.lookup.symbol <- as.integer(unlist(strsplit(opt$`group-symbol-columns`, ",")))
header.lookup <- as.logical(unlist(strsplit(opt$`has-header-grouping-tables`, ",")))


##############
###  MAIN  ###
##############

#---> START MESSAGE <---#
if ( opt$verbose ) cat("Starting ", script, "...\n", sep="'")

#---> IMPORT TABLES <---#

    #---> Read input table <---#
    if ( opt$verbose ) cat("Reading orthologous gene IDs...\n")
    input.table <- read.delim(opt$`input-table`, header=opt$`has-header-input-table`, stringsAsFactors=FALSE)

    #---> Subset input table <---#
    if ( opt$verbose ) cat("Subsetting orthologous gene IDs...\n")
    if ( is.null(opt$`id-columns`) ) {
        cols.id <- 1:ncol(input.table)
    } else {
        cols.id <- as.integer(unlist(strsplit(opt$`id-columns`, ",")))
    }
    input.table <- input.table[, cols.id]

    #---> Read grouping tables <---#
    if ( opt$verbose ) cat("Reading gene ID > gene symbol grouping tables...\n")
    grouping.tables <- mapply(function(file, header, id, symbol) {
        df <- unique(read.delim(file, header=header, stringsAsFactors=FALSE)[, c(id, symbol)])
        vec <- setNames(df[, 2], df[, 1])
    }, files.lookup, header.lookup, cols.lookup.id, cols.lookup.symbol, SIMPLIFY=TRUE)

#---> LOOKUP GENE SYMBOLS <---#

    #---> Look up gene symbols for each organism <---#
    if ( opt$verbose ) cat("Looking up gene symbols...\n")
    symbol.table <- mapply(function(id, lookup) {
        ifelse(id %in% names(lookup), lookup[match(id, names(lookup))], NA)
    }, input.table, grouping.tables)

#---> BUILD OUTPUT TABE <---#

    #---> Merge gene symbols across all organisms <---#
    if ( opt$verbose ) cat("Merging gene symbols...\n")
    merged <- apply(symbol.table, 1, function(row) {
        ifelse(all(is.na(row)), NA, paste(row, collapse=opt$`merge-character`))
    })

    #---> Assemble output table <---#
    if ( opt$verbose ) cat("Assembling output table...\n")
    output.table <- cbind(input.table, symbol.table, merged)
    colnames(output.table) <- c(colnames(input.table), paste("gene_symbols", colnames(input.table), sep="."), "gene_symbols.merged")

#---> WRITING OUTPUT <---#

    #---> Write table to file <---#
    if ( opt$verbose ) cat("Writing output table to file ", opt$`output-table`, "...\n", sep="'")
    write.table(output.table, opt$`output-table`, col.names=opt$`has-header-input-table`, row.names=FALSE, sep="\t", quote=FALSE)

#---> END MESSAGE <---#
if ( opt$verbose ) cat("Done.\n")
