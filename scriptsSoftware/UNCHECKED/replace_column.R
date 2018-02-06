#!/usr/bin/env Rscript
# (c) 2017 Alexander Kanitz, Bizentrum, University of Basel, alexander.kanitz@alumni.ethz.ch

#######################
###  PARSE OPTIONS  ###
#######################

# Load option parser
if ( suppressWarnings(suppressPackageStartupMessages(require("optparse"))) == FALSE ) { stop("[ERROR] Package 'optparse' required! Aborted.") }

# Get script name
script <- sub("--file=", "", basename(commandArgs(trailingOnly=FALSE)[4]))

# Set description
description <- "Replaces a column in a table with different values based on a lookup table.\n"
author <- "Author: Alexander Kanitz, Biozentrum, University of Basel"
version <- "Version: 1.0.0 (28-NOV-2017)"
requirements <- "Requires: optparse"
msg <- paste(description, author, version, requirements, sep="\n")

# List of allowed/recognized arguments
option_list <- list(
                make_option(
                    "--input-table",
                    action="store",
                    type="character",
                    default=NULL,
                    help="Input table. Required.",
                    metavar="file"
                ),
                make_option(
                    "--lookup-table",
                    action="store",
                    type="character",
                    default=NULL,
                    help="Table containing mappings between current and new values for the `--original-column` of the `--input-table`. Required.",
                    metavar="file"
                ),
                make_option(
                    "--output-table",
                    action="store",
                    type="character",
                    default=NULL,
                    help="Output filename. Defaults to `--input-table` with suffix `.column_replaced` appended.",
                    metavar="file"
                ),
                make_option(
                    "--original-column",
                    action="store",
                    type="integer",
                    default=0,
                    help="Column of the `--input-table` whose values are to be replaced. By default, the row names (column 0) will be replaced. Notice that in that case, duplicate replacement values are not allowed.",
                    metavar="int"
                ),
                make_option(
                    "--match-column",
                    action="store",
                    type="integer",
                    default=1,
                    help="Column in `--lookup-table` that contains values matching those in the `--original-column` of the `--input-table`. Values should be unique (behavior not tested for duplicate values). Note that all rows for which no match can be found in the lookup table (NA) will be discarded. Default: %default.",
                    metavar="int"
                ),
                make_option(
                    "--replace-column",
                    action="store",
                    type="integer",
                    default=2,
                    help="Column in `--lookup-table` that contains values that are supposed those in the `--original-column` of the `--input-table`. Default: %default.",
                    metavar="int"
                ),
                make_option(
                    "--input-has-header",
                    action="store_true",
                    default=FALSE,
                    help="Specify if `--input-table` has header."
                ),
                make_option(
                    "--keep-row-names",
                    action="store_true",
                    default=FALSE,
                    help="Specify if `--input-table` has row names that shall be preserved. Always set to TRUE if `--original-column` is 0."
                ),
                make_option(
                    "--lookup-has-header",
                    action="store_true",
                    default=FALSE,
                    help="Specify if `--lookup-table` has header."
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

# Parse command-line arguments
opt_parser <- OptionParser(usage=paste("Usage:", script, "[OPTIONS] --input-directory <DIRECTORY>\n", sep=" "), option_list = option_list, add_help_option=FALSE, description=msg)
opt <- parse_args(opt_parser)

# Rename arguments
in.fl <- opt[["input-table"]]
lookup.fl <- opt[["lookup-table"]]
out.fl <- opt[["output-table"]]
col.orig <- opt[["original-column"]]
col.match <- opt[["match-column"]]
col.repl <- opt[["replace-column"]]
in.header <- opt[["input-has-header"]]
keep.rows <- opt[["keep-row-names"]]
lookup.header <- opt[["lookup-has-header"]]
verb <- opt[["verbose"]]

# Die if any required arguments are missing...
if ( is.null(in.fl) || is.null(lookup.fl) ) {
        print_help(opt_parser)
        stop("[ERROR] Required argument missing! Aborted.")
}

# Set dependent arguments
if ( is.null(out.fl) ) out.fl <- paste(in.fl, "column_replaced", sep=".")


##############
###  MAIN  ###
##############

# Write log message
if ( verb ) cat("Starting ", script, "...\n", sep="'")

# Import input table
if ( verb ) cat("Importing input table...\n", sep="'")
dat <- read.delim(in.fl, header=in.header, stringsAsFactors=FALSE)

# Import lookup table
if ( verb ) cat("Importing lookup table...\n", sep="'")
lookup <- read.delim(lookup.fl, header=lookup.header, stringsAsFactors=FALSE)

# Replace column
if ( verb ) cat("Replacing column...\n", sep="'")
if ( col.orig ) {
    dat.filt <- dat[dat[[col.orig]] %in% lookup[[col.match]], , drop=FALSE]
    dat.filt[[col.orig]] <- lookup[match(dat.filt[[col.orig]], lookup[[col.match]]), col.repl]
} else {
    keep.rows <- TRUE
    dat.filt <- dat[rownames(dat) %in% lookup[[col.match]], , drop=FALSE]
    tmp <- lookup[match(rownames(dat.filt), lookup[[col.match]]), col.repl]
    if ( ! length(tmp) == length(unique(tmp)) ) {
        stop("[ERROR] Replacement values not unique. Execution aborted.")
    }
    rownames(dat.filt) <- tmp
}
dat <- dat.filt

# Write output
if ( verb ) cat("Writing output to file ", out.fl ,"...\n", sep="'")
write.table(dat, out.fl, quote=FALSE, sep="\t", col.names=in.header, row.names=keep.rows)

# Write log message
if ( verb ) cat("Done.\n", sep="'")
