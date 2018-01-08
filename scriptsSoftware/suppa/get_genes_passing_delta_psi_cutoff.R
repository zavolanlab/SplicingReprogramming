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
description <- "Returns the IDs of genes passing delta PSI (percent spliced in) and comparison fraction filters given a delta PSI matrix.\n"
author <- "Author: Alexander Kanitz, Biozentrum, University of Basel"
version <- "Version: 1.0.0 (11-DEC-2017)"
requirements <- "Requires: optparse"
msg <- paste(description, author, version, requirements, sep="\n")

# List of allowed/recognized arguments
option_list <- list(
                make_option(
                    "--delta-psi-table",
                    action="store",
                    type="character",
                    default=NULL,
                    help="Table of delta PSI values with column and row names containing comparison and gene/feature/event identifiers, respectively. Required.",
                    metavar="file"
                ),
                make_option(
                    "--output-file",
                    action="store",
                    type="character",
                    default=NULL,
                    help="Output filename. Defaults to `--fold-change-table` with suffix `.filtered_by_dpsi` appended.",
                    metavar="file"
                ),
                make_option(
                    "--features-to-consider",
                    action="store",
                    type="character",
                    default=NULL,
                    help="List of gene/feature identifiers to consider. By default, all genes/features/events are considered.",
                    metavar="file"
                ),
                make_option(
                    "--cutoff-delta-psi",
                    action="store",
                    type="numeric",
                    default=0.3,
                    help="Absolute delta PSI that a condition has to exceed in order to pass the cutoff. Default: %default.",
                    metavar="float"
                ),
                make_option(
                    "--cutoff-fraction",
                    action="store",
                    type="numeric",
                    default=0.5,
                    help="Fraction of conditions for which a gene/feature has to exceed `--cutoff-delta-psi` in order to pass the overall cutoff (and consequently have its identifer written to the output file). Default: %default.",
                    metavar="float"
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
opt_parser <- OptionParser(usage=paste("Usage:", script, "[OPTIONS] --delta-psi-table=FILE\n", sep=" "), option_list = option_list, add_help_option=FALSE, description=msg)
opt <- parse_args(opt_parser)

# Rename arguments
dpsi.fl <- opt[["delta-psi-table"]]
out.fl <- opt[["output-file"]]
filt.fl <- opt[["features-to-consider"]]
cutoff.dpsi <- opt[["cutoff-delta-psi"]]
cutoff.fract <- opt[["cutoff-fraction"]]
verb <- opt[["verbose"]]

# Die if any required arguments are missing...
if ( is.null(dpsi.fl) ) {
        print_help(opt_parser)
        stop("[ERROR] Required argument missing! Aborted.")
}

# Set dependent arguments
if ( is.null(out.fl) ) out.fl <- paste(dpsi.fl, "filtered_by_dpsi", sep=".")


##############
###  MAIN  ###
##############

# Write log message
if ( verb ) cat("Starting ", script, "...\n", sep="'")

# Import delta PSI data
if ( verb ) cat("Importing delta PSI data...\n", sep="'")
dpsi <- read.delim(dpsi.fl, stringsAsFactors=FALSE)

# Import feature filter
if ( ! is.null(filt.fl) ) {
    if ( verb ) cat("Filtering features...\n", sep="'")
    filt <- readLines(filt.fl)
    dpsi <- dpsi[rownames(dpsi) %in% filt, , drop=FALSE]
}

# Iterate over comparisons
if ( verb ) cat("Applying absolute delta PSI cutoff...\n", sep="'")
pass.mt <- abs(dpsi) > cutoff.dpsi
pass.mt[is.na(pass.mt)] <- FALSE

# Get names of genes passing the expression filters
if ( verb ) cat("Applying fraction cutoff...\n", sep="'")
pass.names <- rownames(pass.mt)[rowSums(pass.mt) / ncol(pass.mt) >= cutoff.fract]

# Write output
if ( verb ) cat("Writing output to file ", out.fl ,"...\n", sep="'")
writeLines(pass.names, out.fl)

# Write log message
if ( verb ) cat("Done.\n", sep="'")
