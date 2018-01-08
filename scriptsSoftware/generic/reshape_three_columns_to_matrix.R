#!/usr/bin/env Rscript
# (c) 2017, Alexander Kanitz, Biozentrum, Universiry of Basel
# email: alexander.kanitz@alumni.ethz.ch

#######################
###  PARSE OPTIONS  ###
#######################

#---> LOAD OPTION PARSER <---#
if ( suppressWarnings(suppressPackageStartupMessages(require("optparse"))) == FALSE ) { stop("[ERROR] Package 'optparse' required! Aborted.") }

#---> GET SCRIPT NAME <---#
script <- sub("--file=", "", basename(commandArgs(trailingOnly=FALSE)[4]))

#---> DESCRIPTION <---#
description <- "Constructs a matrix from a data table containing two categorical columns and one value column.\n"
author <- "Author: Alexander Kanitz, Biozentrum, University of Basel"
version <- "Version: 1.0.0 (20-JUN-2017)"
requirements <- "Requires: optparse"
msg <- paste(description, author, version, requirements, sep="\n")

#---> COMMAND-LINE ARGUMENTS <---#
## List of allowed/recognized arguments
option_list <- list(
    make_option(
        c("-i", "--input-file"),
        action="store",
        type="character",
        default=NULL,
        help="Input data table. Required.",
        metavar="tsv"
    ),
    make_option(
        c("-o", "--output-file"),
        action="store",
        type="character",
        default="",
        help="Output file. Default: Write to STDOUT.",
        metavar="tsv"
    ),
    make_option(
        "--vertical",
        action="store",
        type="character",
        default="1",
        help="Column index (1-based) for the categorical data column to be used for the column names. Default: 1.",
        metavar="int"
    ),
    make_option(
        "--horizontal",
        action="store",
        type="character",
        default="2",
        help="Column index (1-based) for the categorical data column to be used for the row names. Default: 2.",
        metavar="int"
    ),
    make_option(
        "--values",
        action="store",
        type="character",
        default="3",
        help="Column index (1-based) for the value column. Default: 3.",
        metavar="int"
    ),
    make_option(
        "--input-gzipped",
        action="store_true",
        default=FALSE,
        help="Specify if input data table is GZIP compressed."
    ),
    make_option(
        "--no-header",
        action="store_true",
        default=FALSE,
        help="Specify if input data table is headerless. Not allowed if '--use-column-names' is specified."
    ),
    make_option(
        "--use-column-names",
        action="store_true",
        default=FALSE,
        help="Specify if optionis '--vertical', '--horizontal' and '--values' contain actual column names rather than column indices. Data table requires header if specified."
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
opt_parser <- OptionParser(usage=paste("Usage:", script, "[OPTIONS] --input-file=<TSV>\n", sep=" "), option_list = option_list, add_help_option=FALSE, description=msg)
opt <- parse_args(opt_parser)

#---> ARGUMENT VALIDATION <---#

## Die if any required arguments are missing...
if ( is.null(opt$`input-file`) ) {
    print_help(opt_parser)
    stop("[ERROR] Required argument missing! Aborted.")
}

## Die if incompatible options set...
if ( opt$`use-column-names` && opt$`no-header` ) {
    print_help(opt_parser)
    stop("[ERROR] Incompatible options selected! Aborted.")
}


##############
###  MAIN  ###
##############

#---> START MESSAGE <---#
if ( opt$`verbose` ) cat("Starting ", script, "...\n", sep="'", file=stderr())

#---> IMPORT DATA TABLE <---#

    # Write log message
    if ( opt$`verbose` ) cat("Importing data table...\n", sep="", file=stderr())

    # Handle GZIP files
    if ( opt$`input-gzipped` ) opt$`input-file` <- gzfile(opt$`input-file`)

    # Import data
    dat <- read.delim(opt$`input-file`, header=!opt$`no-header`, check.names=FALSE, stringsAsFactors=FALSE)

#---> CONVERT TO MATRIX <---#

    # Write log message
    if ( opt$`verbose` ) cat("Reshaping data to matrix...\n", sep="", file=stderr())

    # Process column indices
    if ( ! opt$`use-column-names` ) {
        opt$`vertical` <- as.integer(opt$`vertical`)
        opt$`horizontal` <- as.integer(opt$`horizontal`)
        opt$`values` <- as.integer(opt$`values`)
    }

    # Reshape data to matrix
    dat <- tapply(dat[[opt$`values`]], dat[c(opt$`vertical`, opt$`horizontal`)], c)

#---> WRITE OUTPUT <---#

    # Write log message
    if ( opt$`verbose` ) cat("Writing out matrix...\n", sep="", file=stderr())

    # Write out matrix
    write.table(dat, opt$`output-file`, col.names=TRUE, row.names=TRUE, sep="\t", quote=FALSE)

#---> END MESSAGE <---#
if ( opt$`verbose` ) cat("Done.\n", sep="", file=stderr())
