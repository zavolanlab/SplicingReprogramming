#!/usr/bin/env Rscript
# (c) 2017, Alexander Kanitz, Biozentrum, Universiry of Basel
# email: alexander.kanitz@alumni.ethz.ch


##############
###  TODO  ###
##############
# filter.matrix() function: WARN ABOUT INCOMPATIBILITIES BETWEEN TPM/PSI & COMP/DPSI/PVAL & FILTER
#                           ACCORDINGLY => ONLY WARN IF PSI/DPSI/PVAL HAS *MORE* COLS/ROWS THAN TPM, 
#                           NOT OTHER WAY AROUND
# aggregate expression:     OPTIONALLY, DO SEPARATELY FOR EACH GROUP, IE EITHER OR BOTH GROUPS HAVE
#                           TO PASS FILTER; EXAMPLE: 100 replicates of absent transcripts vs 3 
#                           replicates of highly abundant transcript might throw out


#######################
###  PARSE OPTIONS  ###
#######################

#---> LOAD OPTION PARSER <---#
if ( suppressWarnings(suppressPackageStartupMessages(require("optparse"))) == FALSE ) {
    stop("[ERROR] Package 'optparse' required! Aborted.")
}

#---> GET SCRIPT NAME <---#
script <- sub("--file=", "", basename(commandArgs(trailingOnly=FALSE)[4]))

#---> DESCRIPTION <---#
description <- "Post-filters SUPPA psiPerEvent and diffSplice results by expression value.\n"
author <- "Author: Alexander Kanitz, Biozentrum, University of Basel"
version <- "Version: 1.0.0 (16-AUG-2017)"
requirements <- "Requires: optparse"
msg <- paste(description, author, version, requirements, sep="\n")

#---> COMMAND-LINE ARGUMENTS <---#
# List of recognized arguments
option_list <- list(
    make_option(
        "--ioe",
        action="store",
        type="character",
        default=NULL,
        help="SUPPA IOE file. Required.",
        metavar="PATH"
    ),
    make_option(
        "--tpm",
        action="store",
        type="character",
        default=NULL,
        help="Expression table with features for rows and sample identifiers for columns. Required.",
        metavar="PATH"
    ),
    make_option(
        "--sample-annotation",
        action="store",
        type="character",
        default=NULL,
        help="A table listing group identifiers and corresponding sample identifiers (matching those in expression table provided to `--tpm`). Required if `--comparisons` is provided. In that case, the script is executed in `diffSplice` mode.",
        metavar="PATH"
    ),
    make_option(
        "--comparisons",
        action="store",
        type="character",
        default=NULL,
        help="A table listing comparison identifiers and corresponding group identifiers (matching those in `--sample-annotation`). Required if `--sample-annotation` is provided. In that case, the script is executed in `diffSplice` mode.",
        metavar="PATH"
    ),
    make_option(
        "--psi",
        action="store",
        type="character",
        default=NULL,
        help="A table listing PSI values for each event (row) and one or more samples (columns). If supplied, a filtered PSI table will be produced (only in `psiPerEvent` mode). Sample identifiers have to match those in expression table provided to `--tpm`.",
        metavar="PATH"
    ),
    make_option(
        "--dpsi",
        action="store",
        type="character",
        default=NULL,
        help="A table listing delta PSI values for each event (row) and one or more comparisons (columns). If supplied, a filtered DPSI table will be produced (`diffSplice` mode).",
        metavar="PATH"
    ),
    make_option(
        "--p-values",
        action="store",
        type="character",
        default=NULL,
        help="A table listing P values for each event (row) and one or more comparisons (columns). If supplied, a filtered P value table will be produced (`diffSplice` mode).",
        metavar="PATH"
    ),
    make_option(
        "--output-file-prefix",
        action="store",
        type="character",
        default=file.path(getwd(), "filtered"),
        help="Prefix for output files. Default: %default.",
        metavar="PREFIX"
    ),
    make_option(
        "--min-expression",
        action="store",
        type="numeric",
        default=0,
        help="Expression level threshold. Events for which the aggregated expression of the corresponding transcripts is below this threshold do not pass the filter (discarded or set to NA). Default: %default.",
        metavar="NUM"
    ),
    make_option(
        "--summary-mode",
        action="store",
        type="character",
        default="median",
        help="Specified how different samples are summarized in `diffSplice` mode. One of 'median' or 'mean'. Ignored in `psiPerEvent` mode. Default: %default.",
        metavar="STRING"
    ),
    make_option(
        "--keep-na-rows",
        action="store_true",
        default=FALSE,
        help="If specified, rows with only NA values are retained in output PSI or DPSI/P value tables. Mutually exclusive with option '--remove-rows-with-NAs'.",
    ),
    make_option(
        "--keep-na-columns",
        action="store_true",
        default=FALSE,
        help="If specified, columns with only NA values are retained in output PSI or DPSI/P value tables.",
    ),
    make_option(
        "--remove-rows-with-NAs",
        action="store_true",
        default=FALSE,
        help="If specified, rows with one or more NA values are discarded from output PSI or DPSI/P value tables. Mutually exclusive with option '--keep-na-rows'.",
    ),
    make_option(
        "--write-events-passing-filters-per-condition",
        action="store_true",
        default=FALSE,
        help="If specified, a list of events passing the expression filter is written for each sample (`psiPerEvent` mode) or comparison (`diffSplice`) mode.",
    ),
    make_option(
        "--write-aggregated-event-expression",
        action="store_true",
        default=FALSE,
        help="If specified, a table with the aggregated expression values for each event and sample/comparison is produced.",
    ),
    make_option(
        "--ioe-event-id-column",
        action="store",
        type="integer",
        default=3,
        help="1-based index of the IEO file column that contains event identifiers. Default: %default.",
        metavar="INT"
    ),
    make_option(
        "--comparisons-id-column",
        action="store",
        type="integer",
        default=1,
        help="1-based index of the comparison file column that contains comparison names/identifiers. Default: %default.",
        metavar="INT"
    ),
    make_option(
        "--comparisons-group1-id-column",
        action="store",
        type="integer",
        default=2,
        help="1-based index of the comparison file column that contains group names/identifiers for the first sample group. Default: %default.",
        metavar="INT"
    ),
    make_option(
        "--comparisons-group2-id-column",
        action="store",
        type="integer",
        default=3,
        help="1-based index of the comparison file column that contains group names/identifiers for the second sample group. Default: %default.",
        metavar="INT"
    ),
    make_option(
        "--sample-annotation-sample-id-column",
        action="store",
        type="integer",
        default=1,
        help="1-based index of the annotation file column that contains sample identifiers. Default: %default.",
        metavar="INT"
    ),
    make_option(
        "--sample-annotation-group-id-column",
        action="store",
        type="integer",
        default=2,
        help="1-based index of the annotation file column that contains group names/identifiers. Default: %default.",
        metavar="INT"
    ),
    make_option(
        "--verbose",
        action="store_true",
        default=FALSE,
        help="Log status information to STDERR.",
    ),
    make_option(
        "--help",
        action="store_true",
        default=FALSE,
        help="Show this help/usage information.",
    )
)

# Parse command-line arguments
opt_parser <- OptionParser(usage=paste("Usage:", script, "[OPTIONS] --ioe=<IOE> --tpm=<TPM>\n", sep=" "), option_list = option_list, add_help_option=FALSE, description=msg)
opt <- parse_args(opt_parser)

#---> RE-ASSIGN CLI ARGUMENTS <---#
ioe.file           <- opt[["ioe"]]
tpm.file           <- opt[["tpm"]]
comp.file          <- opt[["comparisons"]]
anno.file          <- opt[["sample-annotation"]]
psi.file           <- opt[["psi"]]
dpsi.file          <- opt[["dpsi"]]
pval.file          <- opt[["p-values"]]
ioe.event_id.col   <- opt[["ioe-event-id-column"]]
comp.id.col        <- opt[["comparisons-id-column"]]
comp.group1_id.col <- opt[["comparisons-group1-id-column"]]
comp.group2_id.col <- opt[["comparisons-group2-id-column"]]
anno.sample_id.col <- opt[["sample-annotation-sample-id-column"]]
anno.group_id.col  <- opt[["sample-annotation-group-id-column"]]
threshold.tpm      <- opt[["min-expression"]]
summary.mode       <- opt[["summary-mode"]]
keep.empty.rows    <- opt[["keep-na-rows"]]
keep.empty.cols    <- opt[["keep-na-columns"]]
remove.na.rows     <- opt[["remove-rows-with-NAs"]]
out.file.prefix    <- opt[["output-file-prefix"]]
write.ev.ids       <- opt[["write-events-passing-filters-per-condition"]]
write.ev.expr      <- opt[["write-aggregated-event-expression"]]
verb               <- opt[["verbose"]]
allowed.modes      <- c("mean", "median")

#---> ARGUMENT VALIDATION <---#

# Die if required arguments are missing
if ( is.null(ioe.file) ) {
    print_help(opt_parser)
    stop("[ERROR] Argument to '--ioe' is required. Aborted.")
}
if ( is.null(tpm.file) ) {
    print_help(opt_parser)
    stop("[ERROR] Argument to '--tpm' is required. Aborted.")
}

# Die if mutually dependent options are missing
if ( xor(is.null(comp.file), is.null(anno.file)) ) {
    print_help(opt_parser)
    stop("[ERROR] Neither or both of '--comparisons' and '--sample-annotation' are required. Aborted.")
} else {
    ds.mode <- if ( is.null(comp.file) ) FALSE else TRUE
}

# Die if mutually exclusive options are provided
if ( keep.empty.rows && remova.na.rows ) {
    print_help(opt_parser)
    stop("[ERROR] Options '--keep-na-rows' and '--remove-rows-with-NAs' are mutually exclusive. Aborted.")
}

# Die if forbidden argument provided
if ( ! is.null(summary.mode) && ! summary.mode %in% allowed.modes ) {
    print_help(opt_parser)
    stop("[ERROR] Illegal argument provided for option '--summary-mode'. Aborted.")
}

# Set flags and dependent options/defaults
ds.mode <- if ( is.null(comp.file) && is.null(anno.file) ) FALSE else TRUE
if ( ds.mode && is.null(summary.mode) ) summary.mode <- allowed.modes[[1]]
if ( ! write.ev.expr && all(c(is.null(psi.file), is.null(dpsi.file), is.null(pval.file))) ) write.ev.expr <- TRUE

# Warn about potential option conflicts
if ( keep.empty.cols && remova.na.rows ) {
    cat("[WARNING] Specifying options '--keep-na-cols' and '--remove-rows-with-NAs' will result in empty PSI/dPSI/P value output tables when no value of only a single column passes the filter.", sep="", file=stderr())
}

# Warn about unused files
if ( ! ds.mode && ! is.null(dpsi.file) ) {
    cat("[WARNING] Argument to '--dpsi' is ignored if '--comparisons' and '--sample-annotation' are not specified.", sep="", file=stderr())
}
if ( ! ds.mode && ! is.null(pval.file) ) {
    cat("[WARNING] Argument to '--p-values' is ignored if '--comparisons' and '--sample-annotation' are not specified.", sep="", file=stderr())
}
if (   ds.mode && ! is.null(psi.file) ) {
    cat("[WARNING] Argument to '--psi' is ignored if '--comparisons' and '--sample-annotation' are specified.", sep="", file=stderr())
}
if ( ! ds.mode && ! is.null(summary.mode) ) {
    cat("[WARNING] Argument to '--summary-mode' is ignored if '--comparisons' and '--sample-annotation' are not specified.", sep="", file=stderr())
}


##################
###  FUNCTION  ###
##################

# Return a vector of medians for each row of a matrix or dataframe
rowMedians <- function(mt) {
    apply(mt, 1, median)
}

# Matrix subset and NA-replaced according to a logical matrix with (some) overlapping row and column names
filter.matrix <- function(
    mt,                     # Matrix to be subset
    filter,                 # Logical matrix; TRUE will leave the original value in the corresponding field of `mt`; FALSE will replace original value with `NA`
    warn=TRUE,              # Warn if original matrix contains rows/columns that are *not* in filter
    keep.empty.cols=FALSE,  # Do not remove columns that entirely consist of `NA` values
    keep.empty.rows=FALSE,  # Do not remove rows that entirely consist of `NA` values
    remove.na.rows=FALSE    # Remove all rows with one or more `NA` values
) {
    mt <- as.matrix(mt)
    mt <- mt[, colnames(mt) %in% colnames(filter), drop=FALSE]
    mt <- mt[, match(colnames(filter), colnames(mt)), drop=FALSE]
    mt <- mt[rownames(mt) %in% rownames(filter), , drop=FALSE]
    mt <- mt[match(rownames(filter), rownames(mt)), , drop=FALSE]
    mt[! filter] <- NA
    if ( ! keep.empty.cols ) {
        mt <- mt[, ! is.nan(colMeans(mt, na.rm=TRUE)), drop=FALSE]
    }
    if ( ! keep.empty.rows ) {
        mt <- mt[! is.nan(rowMeans(mt, na.rm=TRUE)), , drop=FALSE]
    }
    if ( remove.na.rows ) {
        mt <- mt[! is.na(rowSums(mt)), , drop=FALSE]
    }
    return(mt)
}


##############
###  MAIN  ###
##############

#---> START MESSAGE <---#
if ( verb ) cat("Starting ", script, "...\n", sep="'", file=stderr())

#---> IMPORT DATA <---#
if ( verb ) cat("Importing data...\n", sep="", file=stderr())
ioe  <- read.delim(ioe.file, stringsAsFactors=FALSE)
tpm  <- read.delim(tpm.file, stringsAsFactors=FALSE)
comp <- if ( ds.mode ) read.delim(comp.file, stringsAsFactors=FALSE)
anno <- if ( ds.mode ) read.delim(anno.file, stringsAsFactors=FALSE)
psi  <- if ( ! is.null(psi.file) )  read.delim(psi.file,  stringsAsFactors=FALSE)
dpsi <- if ( ! is.null(dpsi.file) ) read.delim(dpsi.file, stringsAsFactors=FALSE)
pval <- if ( ! is.null(pval.file) ) read.delim(pval.file, stringsAsFactors=FALSE)

#---> PROCESS & VALIDATE DATA <---#

# Write log message
if ( verb ) cat("Pre-processing and validating data...\n", sep="", file=stderr())

# Get event IDs and associated transcripts
ids.events <- ioe[[ioe.event_id.col]]
trx.events <- setNames(strsplit(ioe$total_transcripts, ","), ids.events)
trx.events <- data.frame(transcript=unlist(trx.events), event_id=rep(names(trx.events), sapply(trx.events, length)), row.names=NULL, stringsAsFactors=FALSE)

# Add missing transcripts to and remove surplus ones from TPM table
trx.uniq <- unique(trx.events[["transcript"]])
trx.missing <- trx.uniq[! trx.uniq %in% rownames(tpm)]
if ( length(trx.missing) ) {
    cat(
        "[WARNING] The following transcripts involved in AS events are not listed in the '--tpm' expression level table and their expression will be assumed zero:\n",
        paste(trx.missing, collapse="\n"),
        "\n",
        sep="",
        file=stderr()
    )
    trx.add <- matrix(rep(rep(0, ncol(tpm)), length(trx.missing)), ncol=ncol(tpm), byrow=TRUE, dimnames=list(trx.missing, colnames(tpm)))
    tpm <- rbind(tpm, trx.add)
}
tpm <- tpm[rownames(tpm) %in% trx.uniq, ]

# Remove unannotated comparison groups
if ( ds.mode ) {
    comp <- setNames(split(comp[c(comp.group1_id.col, comp.group2_id.col)], seq(nrow(comp[c(comp.group1_id.col, comp.group2_id.col)]))), comp[[comp.id.col]])
    comp.groups.missing <- unique(unlist(comp)[! unlist(comp) %in% anno[[anno.group_id.col]]])
    if ( length(comp.groups.missing) ) {  
        comp.remove <- names(comp)[sapply(lapply(comp, "%in%", comp.groups.missing), any)]
        comp <- comp[! names(comp) %in% comp.remove]
        cat(
            "[WARNING] No annotations available for comparison group/s `",
            paste(comp.groups.missing, collapse="`, `"),
            "`. Comparison/s `",
            warn.comps <- paste(comp.remove, collapse="`, `"),
            "` skipped.\n",
            sep="",
            file=stderr()
        )
    }
}

#---> CALCULATE EXPRESSION SUMS <---#

# Aggregate data depending on mode
if ( ds.mode ) {    # DIFFSPLICE MODE

    # Iterate over comparisons
    tpm.aggr <- lapply(names(comp), function(nm) {

        # Write log message
        if ( verb ) cat("Calculating AS event expression for comparison", nm, "...\n", sep="`", file=stderr())

        # Get sample IDs for comparison
        comp.sample_ids <- anno[anno[[anno.group_id.col]] %in% comp[[nm]], anno.sample_id.col]

        # Subset TPM table
        tpm.filt <- tpm[, colnames(tpm) %in% comp.sample_ids, drop=FALSE]

        # Skip comparison if all corresponding samples missing from expression table
        if ( ! ncol(tpm.filt) ) {
            cat(
                "[WARNING] No samples associated with comparison `",
                nm,
                "` available in expression level table supplied to '--tpm'. Skipped.\n",
                sep="",
                file=stderr()
            )
            return(NULL)
        }

        # Warn about samples missing from expression table
        if ( ncol(tpm.filt) < length(comp.sample_ids) ) {
            cat(
                "[WARNING] Samples `",
                paste(comp.sample_ids[! comp.sample_ids %in% colnames(tpm)], collapse="`, `"),
                "` associated with comparison `",
                nm,
                "` are not available in expression level table supplied to '--tpm'.\n",
                sep="",
                file=stderr()
            )
        }

        # Summarize expression levels per comparison (means or medians) and add to event table
        tpm.avg <- if ( summary.mode == "mean" ) rowMeans(tpm.filt) else rowMedians(tpm.filt)
        tpm.avg <- merge(trx.events, tpm.avg, by.x=1, by.y=0)[-1]

        # Aggregate expression levels per event
        return(aggregate(tpm.avg[[2]] ~ tpm.avg[[1]], tpm.avg, sum)[[2]])

    })

    # Reshape to matrix form and add column and row names
    names(tpm.aggr) <- names(comp)
    tpm.aggr <- tpm.aggr[! sapply(tpm.aggr, is.null)]
    tpm.aggr <- do.call(cbind, tpm.aggr)
    rownames(tpm.aggr) <- sort(ids.events)

} else {        # PSIPEREVENT MODE

    # Write log message
    if ( verb ) cat("Calculating AS event expression for each sample...\n", sep="`", file=stderr())

    # Add expression levels to event table
    tpm.events <- merge(trx.events, tpm, by.x=1, by.y=0)[-1]

    # Aggregate expression levels per event
    tpm.aggr <- aggregate(tpm.events[-1], tpm.events[1], sum)

    # Add rownames
    rownames(tpm.aggr) <- tpm.aggr[[1]]
    tpm.aggr <- tpm.aggr[-1]

}

#---> FILTER <---#

# Write log message
if ( verb ) cat("Filtering data by expression threshold...\n", sep="", file=stderr())

# Generate logical filter matrix
filter <- tpm.aggr >= threshold.tpm
filter[is.na(filter)] <- FALSE

# Subset SUPPA result files
if ( ! is.null(psi.file)  ) psi.filt  <- filter.matrix(psi,  filter, keep.empty.cols=keep.empty.cols, keep.empty.rows=keep.empty.rows, remove.na.rows=remove.na.rows)
if ( ! is.null(dpsi.file) ) dpsi.filt <- filter.matrix(dpsi, filter, keep.empty.cols=keep.empty.cols, keep.empty.rows=keep.empty.rows, remove.na.rows=remove.na.rows)
if ( ! is.null(pval.file) ) pval.filt <- filter.matrix(pval, filter, keep.empty.cols=keep.empty.cols, keep.empty.rows=keep.empty.rows, remove.na.rows=remove.na.rows)

# Filter DPSI and P value tables by common rows and columns if both are provided
if ( length(c(dpsi.file, pval.file)) == 2 ) {
    rows.common <- sort(intersect(rownames(dpsi.filt), rownames(pval.filt)))
    cols.common <- intersect(colnames(dpsi.filt), colnames(pval.filt))
    dpsi.filt <- dpsi.filt[rows.common, cols.common, drop=FALSE]
    pval.filt <- pval.filt[rows.common, cols.common, drop=FALSE]
}

# Subset event IDs per condition
if ( write.ev.ids ) {
    event_ids.filtered.ls <- lapply(as.data.frame(filter), function(log.vec) rownames(filter)[log.vec])
    event_ids.filtered.ls[["common"]] <- Reduce(intersect, event_ids.filtered.ls)
}

#---> WRITE OUTPUT <---#

# Write IDs of events passing expression threshold for each condition
if ( write.ev.ids ) {
    invisible(lapply(names(event_ids.filtered.ls), function(nm) {
        if ( verb ) cat("Writing out identifiers of events passing threshold for condition ", nm ,"...\n", sep="'", file=stderr())
        out.file.event_ids <- paste(out.file.prefix, "event_ids", nm, sep=".")
        writeLines(event_ids.filtered.ls[[nm]], con=out.file.event_ids)
    }))
}

# Write aggregated event expression
if ( write.ev.expr ) {
    if ( verb ) cat("Writing out table with aggregated expression values per event...\n", sep="", file=stderr())
    out.file.tpm.aggr <- paste(out.file.prefix, "tpm", sep=".")
    write.table(tpm.aggr, out.file.tpm.aggr, quote=FALSE, sep="\t")
}

# Write filtered PSI table
if ( ! is.null(psi.file)  ) {
    if ( verb ) cat("Writing out filtered PSI table...\n", sep="", file=stderr())
    out.file.psi <- paste(out.file.prefix, "psi", sep=".")
    write.table(psi.filt, out.file.psi, quote=FALSE, sep="\t")
}

# Write filtered DPSI table
if ( ! is.null(dpsi.file)  ) {
    if ( verb ) cat("Writing out filtered delta PSI table...\n", sep="", file=stderr())
    out.file.dpsi <- paste(out.file.prefix, "dpsi", sep=".")
    write.table(dpsi.filt, out.file.dpsi, quote=FALSE, sep="\t")
}

# Write filtered P value table
if ( ! is.null(pval.file)  ) {
    if ( verb ) cat("Writing out filtered P value table...\n", sep="", file=stderr())
    out.file.pval <- paste(out.file.prefix, "pval", sep=".")
    write.table(pval.filt, out.file.pval, quote=FALSE, sep="\t")
}

# Save image
out.file.image <- paste(out.file.prefix, "Rimage", sep=".")
save.image(out.file.image)

#---> END MESSAGE <---#
if ( verb ) cat("Done.\n", sep="", file=stderr())
