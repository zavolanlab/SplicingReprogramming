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
description <- "Returns the IDs of genes passing expression and comparison fraction filters given an expression matrix, a sample comparison and sample annotation table.\n"
author <- "Author: Alexander Kanitz, Biozentrum, University of Basel"
version <- "Version: 1.0.0 (28-NOV-2017)"
requirements <- "Requires: optparse"
msg <- paste(description, author, version, requirements, sep="\n")

# List of allowed/recognized arguments
option_list <- list(
                make_option(
                    "--expression-table",
                    action="store",
                    type="character",
                    default=NULL,
                    help="Expression table with column and row names containing sample and gene identifiers, respectively. Required.",
                    metavar="file"
                ),
                make_option(
                    "--sample-annotation-table",
                    action="store",
                    type="character",
                    default=NULL,
                    help="Table containing information about individual samples. Must contain the following column names: `id`, `study_id`, `organism`, `descriptor`. Table is used to identify samples associated with individual sample groups in `--sample-comparison-table`. Required.",
                    metavar="file"
                ),
                make_option(
                    "--sample-comparison-table",
                    action="store",
                    type="character",
                    default=NULL,
                    help="Table containing groupings/comparisons for differential analyses of samples. Must contain the following column names: `endpoint_1`, `endpoint_2`, `organism` (only if `--organism` is specified), `comparison_figure_name_with_organism_and_study` (only if `--verbose` is specified). The first two must contain group identifiers that are formed from columns the following columns of the `--sample-annotation-table`: `study_id`, `organism`, and `descriptor` (separated by dots). Required.",
                    metavar="file"
                ),
                make_option(
                    "--output-file",
                    action="store",
                    type="character",
                    default=NULL,
                    help="Output filename. Defaults to `--expression-table` with suffix `.filtered_by_expression` appended.",
                    metavar="file"
                ),
                make_option(
                    "--organism",
                    action="store",
                    type="character",
                    default=NULL,
                    help="Organism name used for subsetting the comparisons to consider in `--sample-comparison-table`. By default, all comparisons are considered.",
                    metavar="string"
                ),
                make_option(
                    "--cutoff-expression",
                    action="store",
                    type="numeric",
                    default=5,
                    help="Median expression value that at least one of the groups of a given comparison in `--sample-comparison-table` has to exceed in order to be considered expressed in that comparison. Default: %default.",
                    metavar="float"
                ),
                make_option(
                    "--cutoff-fraction",
                    action="store",
                    type="numeric",
                    default=0.5,
                    help="Fraction of comparisons in `--sample-comparison-table` for which a gene has to be considered expressed in order for it to be deemed expressed overall (and consequently have its identifer written to the output file). Default: %default.",
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
opt_parser <- OptionParser(usage=paste("Usage:", script, "[OPTIONS] --input-directory <DIRECTORY>\n", sep=" "), option_list = option_list, add_help_option=FALSE, description=msg)
opt <- parse_args(opt_parser)

# Rename arguments
expr.fl <- opt[["expression-table"]]
sample.anno.fl <- opt[["sample-annotation-table"]]
sample.comp.fl <- opt[["sample-comparison-table"]]
out.fl <- opt[["output-file"]]
org <- opt[["organism"]]
cutoff.expr <- opt[["cutoff-expression"]]
cutoff.fract <- opt[["cutoff-fraction"]]
verb <- opt[["verbose"]]

# Die if any required arguments are missing...
if ( is.null(expr.fl) || is.null(sample.anno.fl) || is.null(sample.comp.fl) ) {
        print_help(opt_parser)
        stop("[ERROR] Required argument missing! Aborted.")
}

# Set dependent arguments
if ( is.null(out.fl) ) out.fl <- paste(expr.fl, "filtered_by_expression", sep=".")


##############
###  MAIN  ###
##############

# Write log message
if ( verb ) cat("Starting ", script, "...\n", sep="'")

# Import sample information
if ( verb ) cat("Importing sample information...\n", sep="'")
sample.anno <- read.delim(sample.anno.fl, stringsAsFactors=FALSE)
sample.comp <- read.delim(sample.comp.fl, stringsAsFactors=FALSE)

# Import expression data
if ( verb ) cat("Importing expression data...\n", sep="'")
expr <- read.delim(expr.fl, stringsAsFactors=FALSE)

# Add group identifier to sample annotation table
sample.anno[["group_id"]] <- paste(sample.anno[["study_id"]], sample.anno[["organism"]], sample.anno[["descriptor"]], sep=".")

# Filter sample comparison table for organism of interest
if ( ! is.null(org) ) sample.comp <- sample.comp[sample.comp[["organism"]] %in% org, ]

# Iterate over comparisons
if ( verb ) cat("Applying expression cutoff...\n", sep="'")
pass.mt <- apply(sample.comp, 1, function(row) {
    group.1 <- row[["endpoint_1"]]
    group.2 <- row[["endpoint_2"]]
    comp.name <- row[["comparison_figure_name_with_organism_and_study"]]
    if ( verb ) cat("Processing ", comp.name, "...\n", sep="'")
    samples.group.1 <- sample.anno[sample.anno[["group_id"]] %in% group.1, "id"]
    samples.group.2 <- sample.anno[sample.anno[["group_id"]] %in% group.2, "id"]
    expr.group.1 <- expr[, colnames(expr) %in% samples.group.1, drop=FALSE]
    expr.group.2 <- expr[, colnames(expr) %in% samples.group.2, drop=FALSE]
    medians.group.1 <- apply(expr.group.1, 1, median)
    medians.group.2 <- apply(expr.group.2, 1, median)
    pass <- medians.group.1 >= cutoff.expr | medians.group.2 >= cutoff.expr
    return(pass)
})

# Get names of genes passing the expression filters
if ( verb ) cat("Applying fraction cutoff...\n", sep="'")
pass.names <- rownames(pass.mt)[rowSums(pass.mt) / ncol(pass.mt) >= cutoff.fract]

# Write output
if ( verb ) cat("Writing output to file ", out.fl ,"...\n", sep="'")
writeLines(pass.names, out.fl)

# Write log message
if ( verb ) cat("Done.\n", sep="'")
