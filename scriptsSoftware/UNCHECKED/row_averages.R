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
description <- "Returns row averages of data matrix.\n"
author <- "Author: Alexander Kanitz, Biozentrum, University of Basel"
version <- "Version: 1.0.0 (29-NOV-2017)"
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
        c("-m", "--mode"),
        action="store",
        type="character",
        default="median",
        help="One of `median` or `mean`. Default: `%default`.",
        metavar="string"
    ),
    make_option(
        c("-n", "--column-name"),
        action="store",
        type="character",
        default=NULL,
        help="Column name for median column. By default, no column name is written out.",
        metavar="string"
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
if ( is.null(opt[["input-file"]]) ) {
    print_help(opt_parser)
    stop("[ERROR] Required argument missing! Aborted.")
}

## Validate choice options...
mode.allowed <- c("median", "mean")
if ( ! opt[["mode"]] %in% mode.allowed ) {
    print_help(opt_parser)
    stop("[ERROR] Illegal argument for option '--mode'! Aborted.")
}

## Set dependent options...
write.col.nm <- if ( ! is.null(opt[["column-name"]]) ) TRUE else FALSE


##############
###  MAIN  ###
##############

#---> START MESSAGE <---#
if ( opt[["verbose"]] ) cat("Starting ", script, "...\n", sep="'", file=stderr())

#---> IMPORT DATA TABLE <---#

    # Write log message
    if ( opt[["verbose"]] ) cat("Importing data table...\n", sep="", file=stderr())

    # Import data
    row.nms <- if ( opt[["no-row-names"]] ) NULL else 1
    dat <- read.delim(opt[["input-file"]], header=!opt[["no-header"]], row.names=row.nms, check.names=FALSE, stringsAsFactors=FALSE)

#---> TRANSFORM DATA <---#

    # Write log message
    if ( opt[["verbose"]] ) cat("Calculating averages...\n", sep="", file=stderr())

    # Calculate averages
    if ( opt[["mode"]] == "mean" ) {
        tmp <- rowMeans(dat)
    } else if ( opt[["mode"]] == "median" ) {
        tmp <- apply(dat, 1, median)
    }

    # Compile new data frame
    dat <- data.frame(average=tmp, row.names=rownames(dat), stringsAsFactors=FALSE)
    colnames(dat) <- opt[["column-name"]]

##---> WRITE OUTPUT <---#

    # Write log message
    if ( opt[["verbose"]] ) cat("Writing out matrix...\n", sep="", file=stderr())

    # Write out matrix
    write.table(dat, opt[["output-file"]], col.names=write.col.nm, row.names=!opt[["no-row-names"]], sep="\t", quote=FALSE)

#---> END MESSAGE <---#
if ( opt[["verbose"]] ) cat("Done.\n", sep="", file=stderr())
