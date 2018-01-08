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
description <- "Merges a set of data tables based on a common ID column.\n"
author <- "Author: Alexander Kanitz, Biozentrum, University of Basel"
version <- "Version: 1.0.0 (19-JUN-2017)"
requirements <- "Requires: optparse"
msg <- paste(description, author, version, requirements, sep="\n")

#---> COMMAND-LINE ARGUMENTS <---#
## List of allowed/recognized arguments
option_list <- list(
                make_option(
                    "--query",
                    action="store",
                    type="character",
                    default=NULL,
                    help="Input data table for the query. Required.",
                    metavar="tsv"
                ),
                make_option(
                    "--reference",
                    action="store",
                    type="character",
                    default=NULL,
                    help="Input data for the reference. Required.",
                    metavar="tsv"
                ),
                make_option(
                    "--output-file",
                    action="store",
                    type="character",
                    default=file.path(getwd(), "out"),
                    help="Output file. Default: Generates file 'out' in current working directory.",
                    metavar="file"
                ),
                make_option(
                    "--in-log",
                    action="store",
                    type="integer",
                    default=NULL,
                    help="Specify exponent if input values are in log space.",
                    metavar="int"
                ),
                make_option(
                    "--out-log",
                    action="store",
                    type="integer",
                    default=NULL,
                    help="Specify exponent if output values shall be written in log space.",
                    metavar="int"
                ),
                make_option(
                    "--fill-in-missing",
                    action="store_true",
                    default=FALSE,
                    help="Specify if rows & columns present in only one of query or reference shall be filled in in the other."
                ),
                make_option(
                    "--transpose",
                    action="store_true",
                    default=FALSE,
                    help="Transpose fold change matrix before writing output."
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
opt_parser <- OptionParser(usage=paste("Usage:", script, "[OPTIONS] --query=<TSV> --reference=<TSV>\n", sep=" "), option_list = option_list, add_help_option=FALSE, description=msg)
opt <- parse_args(opt_parser)

#---> ARGUMENT VALIDATION <---#

## Die if any required arguments are missing...
if ( is.null(opt$`query`) || is.null(opt$`reference`) ) {
        print_help(opt_parser)
        stop("[ERROR] Required argument missing! Aborted.")
}


##############
###  MAIN  ###
##############

#---> START MESSAGE <---#
if ( opt$`verbose` ) cat("Starting ", script, "...\n", sep="'")

#---> IMPORT DATA TABLES <---#

    #---> Import query data <---#
    if ( opt$`verbose` ) cat("Import query data table...\n")
    dat.q <- read.delim(opt$`query`, stringsAsFactors=FALSE)

    #---> Read data tables <---#
    if ( opt$`verbose` ) cat("Import reference data table...\n")
    dat.r <- read.delim(opt$`reference`, stringsAsFactors=FALSE)

#---> HOMOGENIZE DATA TABLES <---#

    # Write log message
    if ( opt$`verbose` ) cat("Homogenizing data tables...\n")

    # Check if option is set
    if ( opt$`fill-in-missing` ) {

        # Write log message
        if ( opt$`verbose` ) cat("Filling in missing rows and columns...\n")

        # Get all row and column names
        rownms.all <- unique(c(rownames(dat.q), rownames(dat.r)))
        colnms.all <- unique(c(colnames(dat.q), colnames(dat.r)))

        # Add missing rows
        rownms.missing.q <- rownms.all[! rownms.all %in% rownames(dat.q)]
        rownms.missing.r <- rownms.all[! rownms.all %in% rownames(dat.r)]
        rows.missing.q <- matrix(data=NA, nrow=length(rownms.missing.q), ncol=ncol(dat.q), dimnames=list(rownms.missing.q, colnames(dat.q)))
        rows.missing.r <- matrix(data=NA, nrow=length(rownms.missing.r), ncol=ncol(dat.r), dimnames=list(rownms.missing.r, colnames(dat.r)))
        dat.q <- rbind(dat.q, rows.missing.q)
        dat.r <- rbind(dat.r, rows.missing.r)

        # Add missing columns
        colnms.missing.q <- colnms.all[! colnms.all %in% colnames(dat.q)]
        colnms.missing.r <- colnms.all[! colnms.all %in% colnames(dat.r)]
        cols.missing.q <- matrix(data=NA, nrow=nrow(dat.q), ncol=length(colnms.missing.q), dimnames=list(rownames(dat.q), colnms.missing.q))
        cols.missing.r <- matrix(data=NA, nrow=nrow(dat.r), ncol=length(colnms.missing.r), dimnames=list(rownames(dat.r), colnms.missing.r))
        dat.q <- cbind(dat.q, cols.missing.q)
        dat.r <- cbind(dat.r, cols.missing.r)

    } else {

        # Write log message
        if ( opt$`verbose` ) cat("Deleting incompatible rows and columns...\n")

        # Removing rows only available in either data table
        dat.q <- dat.q[rownames(dat.q) %in% rownames(dat.r), ]
        dat.r <- dat.r[rownames(dat.r) %in% rownames(dat.q), ]

        # Removing columns only available in either data table
        dat.q <- dat.q[, colnames(dat.q) %in% colnames(dat.r)]
        dat.r <- dat.r[, colnames(dat.r) %in% colnames(dat.q)]

    }

    # Sort data tables
    if ( opt$`verbose` ) cat("Sorting rows and columns...\n")
    dat.q <- dat.q[order(rownames(dat.q)), ]
    dat.r <- dat.r[order(rownames(dat.r)), ]
    dat.q <- dat.q[, order(colnames(dat.q))]
    dat.r <- dat.r[, order(colnames(dat.r))]


#---> CALCULATE FOLD CHANGES <---#

    # Write log message
    if ( opt$`verbose` ) cat("Calculating fold changes...\n")

    # Calculate fold changes
    dat <- if ( ! is.null(opt$`in-log`) ) opt$`in-log`^(dat.q - dat.r) else dat.q / dat.r

    # Transform to log space
    if ( ! is.null (opt$`out-log`) ) dat <- log(dat, opt$`out-log`)

    # Transpose
    if ( opt$`transpose` ) dat <- t(dat)


#---> WRITING OUTPUT <---#

    #---> Log message <---#
    if ( opt$`verbose` ) cat("Writing fold changes table to file ", opt$`output-file`, "...\n", sep="'")

    #---> Write tables <---#
    write.table(dat, opt$`output-file`, col.names=TRUE, row.names=TRUE, sep="\t", quote=FALSE)

#---> END MESSAGE <---#
if ( opt$`verbose` ) cat("Done.\n")
