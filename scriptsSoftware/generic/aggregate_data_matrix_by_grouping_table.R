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
description <- "Given an ID to group ID table, groups rows of a data matrix and applies an aggregation function.\n"
author <- "Author: Alexander Kanitz, Biozentrum, University of Basel"
version <- "Version: 1.0.0 (18-NOV-2016)"
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
                    help="Input data table. Required.",
                    metavar="file"
                ),
                make_option(
                    c("-o", "--output-table"),
                    action="store",
                    type="character",
                    default=NULL,
                    help="Aggregated output data table. Required.",
                    metavar="file"
                ),
                make_option(
                    c("-l", "--grouping-table"),
                    action="store",
                    type="character",
                    default=NULL,
                    help="Lookup table matching IDs in input table to group IDs. Required.",
                    metavar="file"
                ),
                make_option(
                    "--function",
                    action="store",
                    type="character",
                    default="sum",
                    help="R function to apply for each group. Default: sum",
                    metavar="FUNC"
                ),
                make_option(
                    "--id-column",
                    action="store",
                    type="integer",
                    default=1,
                    help="The field/column in the grouping table containing the IDs matching those in the input data table.",
                    metavar="int"
                ),
                make_option(
                    "--group-id-column",
                    action="store",
                    type="integer",
                    default=2,
                    help="The field/column in the grouping table containing the group IDs.",
                    metavar="int"
                ),
                make_option(
                    "--has-header-input-table",
                    action="store_true",
                    default=FALSE,
                    help="Indicates whether the input data table has a header line. Default: FALSE."
                ),
                make_option(
                    "--has-header-grouping-table",
                    action="store_true",
                    default=FALSE,
                    help="Indicates whether the grouping table has a header line. Default: FALSE."
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
opt_parser <- OptionParser(usage=paste("Usage:", script, "[OPTIONS] --input-table <FILE> --output-table <FILE> --grouping-table <FILE>\n", sep=" "), option_list = option_list, add_help_option=FALSE, description=msg)
opt <- parse_args(opt_parser)

#---> ARGUMENT VALIDATION <---#

## Die if any required arguments are missing...
if ( is.null(opt$`input-table`) | is.null(opt$`output-table`) | is.null(opt$`grouping-table`) ) {
        print_help(opt_parser)
        stop("[ERROR] Required argument missing! Aborted.")
}

##############
###  MAIN  ###
##############

#---> START MESSAGE <---#
if ( opt$verbose ) cat("Starting ", script, "...\n", sep="'")

#---> IMPORT TABLES <---#

    #---> Read input table <---#
    if ( opt$verbose ) cat("Reading data table...\n")
    input.table <- read.table(opt$`input-table`, header=opt$`has-header-input-table`, sep="\t", row.names=1, stringsAsFactors=FALSE)

    #---> Read grouping table <---#
    if ( opt$verbose ) cat("Reading grouping table...\n")
    grouping.table <- read.table(opt$`grouping-table`, header=opt$`has-header-grouping-table`, sep="\t", stringsAsFactors=FALSE)

#---> PROCESS GROUPING TABLE <---#

    #---> Select only ID and group ID columns <---#
    if ( opt$verbose ) cat("Processing grouping table...\n")
    grouping.table <- grouping.table[, c(opt$`id-column`, opt$`group-id-column`)]

#---> AGGREGATE DATA <---#

    #---> Merge grouping and data tables <---#
    if ( opt$verbose ) cat("Matching grouping and data tables IDs...\n")
    tmp <- cbind(grouping.table[match(rownames(input.table), grouping.table[, 1]), ], input.table)

    #---> Aggregate by group IDs <---#
    if ( opt$verbose ) cat("Aggregating data groups with function ", opt$`function`, "...\n", sep="'")
    fun <- get(opt$`function`)
    aggregated <- aggregate(tmp[, 3:ncol(tmp)], by=list(tmp[, 2]), fun)
    rownames(aggregated) <- aggregated[, 1]
    aggregated <- aggregated[, -1]

#---> WRITING OUTPUT <---#

    #---> Write table to file <---#
    if ( opt$verbose ) cat("Writing aggregated data table to file ", opt$`output-table`, "...\n", sep="'")
    write.table(aggregated, opt$`output-table`, col.names=opt$`has-header-input-table`, row.names=TRUE, sep="\t", quote=FALSE)

#---> END MESSAGE <---#
if ( opt$verbose ) cat("Done.\n")
