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
description <- "Aggregates merged delta PSI or P value tables from SUPPA diffSplice analyses by gene identifier. In case of multiple events per gene, the one with the highest absolute (dPSI) or lowest (P) value is chosen. Required input file format: event_id <TAB> value_sample_1 <TAB> ... <TAB> value_sample_n.\n"
author <- "Author: Alexander Kanitz, Biozentrum, University of Basel"
version <- "Version: 1.0.0 (17-FEB-2016)"
requirements <- "Requires: optparse"
msg <- paste(description, author, version, requirements, sep="\n")

#---> COMMAND-LINE ARGUMENTS <---#
## List of allowed/recognized arguments
option_list <- list(
                make_option(
                    c("--p-values"),
                    action="store",
                    type="character",
                    default=NULL,
                    help="Path to table listing P values per event. At least one of '--p-values' and '--dpsi' is required.",
                    metavar="path"
                ),
                make_option(
                    c("--dpsi"),
                    action="store",
                    type="character",
                    default=NULL,
                    help="Path to table listing delta PSI values per event. At least one of '--p-values' and '--dpsi' is required.",
                    metavar="path"
                ),
                make_option(
                    c("--event-filter"),
                    action="store",
                    type="character",
                    default=NULL,
                    help="Path to file listing event identifiers to retain. If not provided, all events are retained.",
                    metavar="path"
                ),
                make_option(
                    c("--outfile-prefix"),
                    action="store",
                    type="character",
                    default="./aggregated",
                    help="Prefix for output filenames. Default: %default.",
                    metavar="path"
                ),
                make_option(
                    c("--aggregate-by"),
                    action="store",
                    type="character",
                    default="s",
                    help="Use either 'p', 'd', 's' (default) or 'n' to aggregate input files by P values, delta PSI values, separately, or not at all (file processing only). Options 'p' and 'd' are valid onlu if input files are specified for both '--dpsi' and '--p-values'.",
                    metavar="char"
                ),
                make_option(
                    c("--min-non-NA-fraction"),
                    action="store",
                    type="numeric",
                    default=0.5,
                    help="In mode 'd', fraction of comparisons for which values have to be available (i.e. 1 - allowed fraction of NA values). Default: %default.",
                    metavar="NUM"
                ),
                make_option(
                    c("--log-transform-p"),
                    action="store_true",
                    default=FALSE,
                    help="Transform P values to logarithmic scale (base 10)."
                ),
                make_option(
                    c("--pseudocount"),
                    action="store",
                    type="numeric",
                    default=NA,
                    help="Set this pseudocount for P values of 0 when log-transforming P values (ignored otherwise). By default, one tenth of the lowest non-zero value is used.",
                    metavar="NUM"
                ),
                make_option(
                    c("--keep-all-NA-rows"),
                    action="store_true",
                    default=FALSE,
                    help="Keep rows of the aggregated delta PSI and delta P value tables in which all values are NAs. By default, these rows are removed (in '--aggregate-by' modes 'd' and 'p' will ensure that rows removed for the delta PSI and P value tables, respectively, are removed in the other table as well, if present)."
                ),
                make_option(
                    c("--keep-NAs"),
                    action="store_true",
                    default=FALSE,
                    help="Keep NAs. By default, NAs in delta PSI and P value tables are replaced by zeros and ones, respectively. Note that replacement occurs after removing all NA rows (unless '--keep-all-NA-rows' is specified)."
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
opt_parser <- OptionParser(usage=paste("Usage:", script, "[--aggregate-by=<CHAR> --outfile-prefix=<PREFIX>] (--p-values=<PATH> --dpsi=<PATH>)", sep=" "), option_list = option_list, add_help_option=FALSE, description=msg)
opt <- parse_args(opt_parser)


#---> ARGUMENT VALIDATION <---#

## Die if any required arguments are missing...
if ( is.null(opt[["p-values"]]) && is.null(opt[["dpsi"]]) ) {
        print_help(opt_parser)
        stop("[ERROR] Required argument missing! Aborted.")
}
if ( ! opt[["aggregate-by"]] %in% c('p', 'd', 's', 'n') ) {
        print_help(opt_parser)
        stop("[ERROR] Wrong argument to option '--aggregate-by'! Aborted.")
}
if ( is.null(opt[["p-values"]]) && opt[["log-transform-p"]] ) {
        print_help(opt_parser)
        stop("[ERROR] Option '--log-transform-p' requires argument to '--p-values'! Aborted.")
}
if ( opt[["aggregate-by"]] %in% c("d", "p") && ( is.null(opt[["p-values"]]) || is.null(opt[["dpsi"]]) ) ) {
        print_help(opt_parser)
        stop("[WARNING] Arguments 'p' and 'd' to option --aggregate-by' are not allowed if only one input file is specified! Aborted.")
}


###################
###  FUNCTIONS  ###
###################

# Return original value of absolute maximum of a numeric vector
which.min.mod <- function(x) {
    index <- which.min(x)
    if ( length(index) == 0 ) return(NA) else return(index)
}
which.abs.max <- function(x) {
    index <- which.max(abs(x))
    if ( length(index) == 0 ) return(NA) else return(index)
}


##############
###  MAIN  ###
##############

#---> START MESSAGE <---#
if ( opt$`verbose` ) cat("Starting ", script, "...\n", sep="'")

#---> IMPORT DATA TABLES <---#

    #---> Read data tables <---#
    if ( opt$`verbose` ) cat("Loading data tables...\n")
    if ( ! is.null(opt[["p-values"]]) ) {
        dat.p <- read.delim(opt[["p-values"]], stringsAsFactors=FALSE)
    }
    if ( ! is.null(opt[["dpsi"]]) ) {
        dat.d <- read.delim(opt[["dpsi"]], stringsAsFactors=FALSE)
    }

#---> FILTER DATA TABLES <---#

    if ( ! is.null(opt[["event-filter"]]) ) {

        #---> Read filter file <---#
        if ( opt$`verbose` ) cat("Loading event filter...\n")
        events.filt <- readLines(opt[["event-filter"]])

        #---> Filter data tables <---#
        if ( opt$`verbose` ) cat("Filtering data tables...\n")
        if ( ! is.null(opt[["p-values"]]) ) {
            dat.p <- dat.p[rownames(dat.p) %in% events.filt, , drop=FALSE]
        }
        if ( ! is.null(opt[["dpsi"]]) ) {
            dat.d <- dat.d[rownames(dat.d) %in% events.filt, , drop=FALSE]
        }

    }

#---> AGGREGATE DATA TABLES <---#

    #---> Log message <---#
    if ( opt$`verbose` ) cat("Aggregating data tables...\n", sep="'")

    #---> Aggregate data tables <---#
    if ( ! opt[["aggregate-by"]] == 'n' ) {

        #---> Assert that DPSI and P value tables are compatible <---#
        if (
            ! is.null(opt[["p-values"]]) &&
            ! is.null(opt[["dpsi"]]) &&
            ! all(rownames(dat.p) == rownames(dat.d)) &&
            opt[["aggregate-by"]] %in% c('p', 'd')
        ) {
            stop("[ERROR] When --aggregate-by' is 'p' or 'd', row names (event IDs) in data tables '--p-values' and '--dpsi' are required to be identical. Aborted.")
        }

        #---> Aggregate data tables by P values and gene identifiers <---#
        # Assumes that input data are numeric and in [0, 1]
        if ( ! is.null(opt[["p-values"]]) && ! opt[["aggregate-by"]] == 'd' ) {
            genes.p <- sapply(strsplit(rownames(dat.p), ";"), "[[", 1)
            events.ls <- split(rownames(dat.p), f=genes.p)
            indices <- aggregate(rowMeans(dat.p, na.rm=TRUE), by=list(genes.p), which.min.mod)[, -1, drop=TRUE]
            events.tmp <- events.ls[! is.na(indices)]
            indices.tmp <- indices[! is.na(indices)]
            events.aggr <- mapply("[[", events.tmp, indices.tmp)
            dat.p.aggr <- dat.p[rownames(dat.p) %in% events.aggr, , drop=FALSE]
            if ( opt[["aggregate-by"]] == 'p' ) dat.d.aggr <- dat.d[rownames(dat.d) %in% events.aggr, , drop=FALSE]
        }

        #---> Aggregate data tables by delta PSI values and gene identifiers <---#
        # Assumes that input data are numeric, including NA and NaN, but *not* (-)Inf
        if ( ! is.null(opt[["dpsi"]]) && ! opt[["aggregate-by"]] == 'p' ) {
            dat.d <- dat.d[rowSums(! is.na(dat.d)) / ncol(dat.d) >= opt[["min-non-NA-fraction"]], ]
            genes.d <- sapply(strsplit(rownames(dat.d), ";"), "[[", 1)
            events.ls <- split(rownames(dat.d), f=genes.d)
            indices <- aggregate(rowMeans(dat.d, na.rm=TRUE), by=list(genes.d), which.abs.max)[, -1, drop=TRUE]             ## OFFENDING
            events.tmp <- events.ls[! is.na(indices)]
            indices.tmp <- indices[! is.na(indices)]
            events.aggr <- mapply("[[", events.tmp, indices.tmp)
            dat.d.aggr <- dat.d[rownames(dat.d) %in% events.aggr, , drop=FALSE]
            if ( opt[["aggregate-by"]] == 'd' ) dat.p.aggr <- dat.p[rownames(dat.p) %in% events.aggr, , drop=FALSE]
        }

    } else {

        #---> Re-assign original data <---#
        if ( ! is.null(opt[["p-values"]]) ) dat.p.aggr <- dat.p
        if ( ! is.null(opt[["dpsi"]]) ) dat.d.aggr <- dat.d

    }

    #---> Log-transform P values <---#
    if ( opt[["log-transform-p"]] ) {
        if ( is.na(opt[["pseudocount"]]) ) {
            opt[["pseudocount"]] <- min(unlist(dat.p.aggr)[! unlist(dat.p.aggr) == 0]) / 10
        }
        dat.p.aggr[dat.p.aggr == 0] <- opt[["pseudocount"]]
        dat.p.aggr <- log10(dat.p.aggr)
    }

    #---> Remove lines with only NA values <---#
    if ( ! opt[["keep-all-NA-rows"]] ) {
        if ( opt[["aggregate-by"]] == "d" ) {
            dat.d.aggr <- dat.d.aggr[! is.nan(rowMeans(dat.d.aggr, na.rm=TRUE)), , drop=FALSE]
            if ( ! is.null(opt[["p-values"]]) ) dat.p.aggr <- dat.p.aggr[rownames(dat.p.aggr) %in% rownames(dat.d.aggr), , drop=FALSE]
        } else if ( opt[["aggregate-by"]] == "p" ) {
            dat.p.aggr <- dat.p.aggr[! is.nan(rowMeans(dat.p.aggr, na.rm=TRUE)), , drop=FALSE]
            if ( ! is.null(opt[["dpsi"]]) ) dat.d.aggr <- dat.d.aggr[rownames(dat.d.aggr) %in% rownames(dat.p.aggr), , drop=FALSE]
        } else {
            if ( ! is.null(opt[["dpsi"]]) ) dat.d.aggr <- dat.d.aggr[! is.nan(rowMeans(dat.d.aggr, na.rm=TRUE)), , drop=FALSE]
            if ( ! is.null(opt[["p-values"]]) ) dat.p.aggr <- dat.p.aggr[! is.nan(rowMeans(dat.p.aggr, na.rm=TRUE)), , drop=FALSE]
        }
    }

    #---> Replace delta PSI NAs with zeros <---#
    if ( ! opt[["keep-NAs"]] ) {
        if ( ! is.null(opt[["dpsi"]]) ) dat.d.aggr[is.na(dat.d.aggr)] <- 0
        if ( ! is.null(opt[["p-values"]]) ) dat.p.aggr[is.na(dat.p.aggr)] <- 1
    }

#---> WRITING OUTPUT <---#

    #---> Write aggregated data tables <---#
    if ( ! is.null(opt[["p-values"]]) ) {
        out.file.p <- paste(opt[["outfile-prefix"]], "pval", sep=".")
        if ( opt$`verbose` ) cat("Writing aggregated P value data table to file ", out.file.p, "...\n", sep="'")
        write.table(dat.p.aggr, out.file.p, quote=FALSE, sep="\t")
    }
    if ( ! is.null(opt[["dpsi"]]) ) {
        out.file.d <- paste(opt[["outfile-prefix"]], "dpsi", sep=".")
        if ( opt$`verbose` ) cat("Writing aggregated delta PSI data table to file ", out.file.d, "...\n", sep="'")
        write.table(dat.d.aggr, out.file.d, quote=FALSE, sep="\t")
    }

    #---> Save image <---#
    out.file.img <- paste(opt[["outfile-prefix"]], "Rimage", sep=".")
    save.image(out.file.img)

#---> END MESSAGE <---#
if ( opt$`verbose` ) cat("Done.\n")
