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
description <- "Apply or reverse log transformation on a data matrix.\n"
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
        help="Output data table. Default: Write to STDOUT.",
        metavar="tsv"
    ),
    make_option(
        "--base",
        action="store",
        type="numeric",
        default="2",
        help="Positive number to be used as base for log transformation. Default: %default.",
        metavar="num"
    ),
    make_option(
        "--pseudo",
        action="store",
        type="numeric",
        default=NULL,
        help="Add this number to every value to prevent log(0) issues. Default: do not add `pseudocount`.",
        metavar="num"
    ),
    make_option(
        "--input-gzipped",
        action="store_true",
        default=FALSE,
        help="Specify if input data table is GZIP compressed."
    ),
    make_option(
        "--reverse",
        action="store_true",
        default=FALSE,
        help="Reverse log operation with the given '--base'."
    ),
    make_option(
        "--no-header",
        action="store_true",
        default=FALSE,
        help="Specify if input data table is headerless."
    ),
    make_option(
        "--no-row-names",
        action="store_true",
        default=FALSE,
        help="Specify if input data table does not contain rownames."
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
    row.nms <- if ( opt$`no-row-names` ) NULL else 1
    dat <- read.delim(opt$`input-file`, header=!opt$`no-header`, row.names=row.nms, check.names=FALSE, stringsAsFactors=FALSE)

#---> TRANSFORM DATA <---#

    # Check direction
    if ( ! opt$`reverse` ) {

        # Write log message
        if ( opt$`verbose` ) cat("Applying log transformation with base ", opt$`base` ,"...\n", sep="", file=stderr())

        # Add pseudocount
        if ( ! is.null(opt$`pseudo`) ) dat <- dat + opt$`pseudo`

        # Transform data
        dat <- log(dat, opt$`base`)

    } else {

        # Write log message
        if ( opt$`verbose` ) cat("Reversing log transformation with base ", opt$`base` ,"...\n", sep="", file=stderr())

        # Transform data
        dat <- opt$`base`^dat

    }

##---> WRITE OUTPUT <---#

    # Write log message
    if ( opt$`verbose` ) cat("Writing out matrix...\n", sep="", file=stderr())

    # Write out matrix
    write.table(dat, opt$`output-file`, col.names=!opt$`no-header`, row.names=!opt$`no-row-names`, sep="\t", quote=FALSE)

#---> END MESSAGE <---#
if ( opt$`verbose` ) cat("Done.\n", sep="", file=stderr())
