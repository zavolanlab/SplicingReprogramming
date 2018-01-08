#!/usr/bin/env Rscript

# (c) 2017 Alexander Kanitz, Biozentrum, University of Basel
# (@) alexander.kanitz@unibas.ch

# TODO: fix dendrogram width for tilted labels; currently hacky
# TODO: plot legend for sidebars

#################
###  IMPORTS  ###
#################

# Import required packages
if ( suppressWarnings(suppressPackageStartupMessages(require("optparse"))) == FALSE ) { stop("[ERROR] Package 'optparse' required! Aborted.") }
if ( suppressWarnings(suppressPackageStartupMessages(require("gplots"))) == FALSE ) { stop("[ERROR] Package 'gplots' required! Aborted.") }
if ( suppressWarnings(suppressPackageStartupMessages(require("RColorBrewer"))) == FALSE ) { stop("[ERROR] Package 'RColorBrewer' required! Aborted.") }


#######################
###  PARSE OPTIONS  ###
#######################

# Get script name
script <- sub("--file=", "", basename(commandArgs(trailingOnly=FALSE)[4]))

# Build description message
description <- "Plot heatmaps of a data matrix.\n"
author <- "Author: Alexander Kanitz, Biozentrum, University of Basel"
version <- "Version: 1.0.0 (24-JAN-2017)"
requirements <- "Requires: gplots, RColorBrewer, optparse"
msg <- paste(description, author, version, requirements, sep="\n")

# Define list of arguments
option_list <- list(
    make_option(
        "--data-matrix",
        action="store",
        type="character",
        default=NULL,
        help="Data matrix containing feature/gene IDs in the first column and values (e.g. log fold changes) to be plotted, per column, in the remaining columns. Column headers are expected. Required.",
        metavar="tsv"
    ),
    make_option(
        "--data-has-header",
        action="store_true",
        default=FALSE,
        help="Indicates whether the data matrix includes a header line. Default: '%default'."
    ),
    make_option(
        "--column-id-prefix",
        action="store",
        type="character",
        default=NULL,
        help="Prefix to be removed from column names of data matrix. Trimming is performed before any data filtering. Default: '%default'.",
        metavar="string"
    ),
    make_option(
        "--column-id-suffix",
        action="store",
        type="character",
        default=NULL,
        help="Suffix to be removed from column names of data matrix. Trimming is performed before any data filtering. Default: '%default'.",
        metavar="string"
    ),
    make_option(
        "--output-directory",
        action="store",
        type="character",
        default=getwd(),
        help="Directory where output files shall be written. Default: ''%default''.",
        metavar="directory"
    ),
    make_option(
        "--run-id",
        action="store",
        type="character",
        default="experiment",
        help="String used as analysis identifier prefix for output files. Default: ''%default''.",
        metavar="file"
    ),
    make_option(
        "--exclude",
        action="store",
        type="character",
        default=NULL,
        help="Text file containing names of columns to be excluded from the analysis. Expected format: One identifier per line. Column names have to match column headers of '--data-matrix' *after* removing '--column-id-prefix' and/or '--column-id-suffix', if specified. Default: '%default'.",
        metavar="file"
    ),
    make_option(
        "--column-annotation",
        action="store",
        type="character",
        default=NULL,
        help="Annotation table with one row for each column of the data marix. If provided, columns without annotation are not considered. Specify '--column-annotation-has-header' if table includes a header line. Default: '%default'.",
        metavar="tsv"
    ),
    make_option(
        "--column-annotation-has-header",
        action="store_true",
        default=FALSE,
        help="Indicates whether the column annotation table includes a header line. Default: '%default'."
    ),
    make_option(
        "--column-annotation-id-column",
        action="store",
        type="integer",
        default=1,
        help="Column annotation table column index (1-based) containing column identifiers that match column names of '--data-matrix' *after* removing '--column-id-prefix' and/or '--column-id-suffix', if specified. Columns in data matrix for which no annotation is present will not be considered. Required if '--column-annotation' is specified. Default: '%default'.",
        metavar="int"
    ),
    make_option(
        "--column-annotation-name-column",
        action="store",
        type="integer",
        default=NULL,
        help="Column annotation table column index (1-based) containing names for features to be used in heatmap plots instead of identifiers. Default: '%default'.",
        metavar="int"
    ),
    make_option(
        "--column-annotation-category-columns",
        action="store",
        type="integer",
        default=NULL,
        help="One or more annotation table column indices (1-based) containing categorical information. Individual heatmaps are plotted for each distinct category value. Specify multiple columns with comma and dash, similar to the '--fields' parameter of Bash 'cut' (e.g. '3,5-7' uses columns 3, 5, 6, and 7). Default: '%default'.",
        metavar="int"
    ),
    make_option(
        "--column-annotation-sidebar-color-category-column",
        action="store",
        type="integer",
        default=NULL,
        help="Column annotation table column index (1-based) containing categorical information. Different values are highlighted in heatmaps as a color sidebar. Default: '%default'.",
        metavar="int"
    ),
    make_option(
        "--row-annotation",
        action="store",
        type="character",
        default=NULL,
        help="Annotation table with one row for each row of the data marix. If provided, rows without annotation are not considered. Specify '--row-annotation-has-header' if table includes a header line. Default: '%default'.",
        metavar="tsv"
    ),
    make_option(
        "--row-annotation-has-header",
        action="store_true",
        default=FALSE,
        help="Indicates whether the row annotation table includes a header line. Default: '%default'."
    ),
    make_option(
        "--row-annotation-id-column",
        action="store",
        type="integer",
        default=1,
        help="Row annotation table column index (1-based) containing identifiers that match row names of '--data-matrix'. Rows in data matrix for which no annotation is present will not be considered. Required if '--row-annotation' is specified. Default: '%default'.",
        metavar="int"
    ),
    make_option(
        "--row-annotation-name-column",
        action="store",
        type="integer",
        default=2,
        help="Row annotation table column index (1-based) containing names for features to be used in heatmap plots instead of identifiers. Required if '--row-annotation' is specified. Default: '%default'.",
        metavar="int"
    ),
    make_option(
        "--row-annotation-sidebar-color-category-column",
        action="store",
        type="integer",
        default=NULL,
        help="Row annotation table column index (1-based) containing categorical information. Different values are highlighted in heatmaps as a color sidebar. Default: '%default'.",
        metavar="int"
    ),
    make_option(
        "--subset-directory",
        action="store",
        type="character",
        default=NULL,
        help="Directory containing one or more files containing subsets of feature identifiers (i.e. row names). Individual heatmaps are plotted for each subset. Identifiers have to match the row names of '--data-matrix' and have to be specified one per line. Requires that a valid argument to '--subset-glob' is also provided. If not specified, separate analyses per subset are not performed. Default: '%default'.",
        metavar="directory"
    ),
    make_option(
        "--subset-glob",
        action="store",
        type="character",
        default=NULL,
        help="File glob to identify subset feature identifier files in '--subset-directory'. Valid values include either a single asterisk '*' or a single stretch of question marks (e.g. '???'). Values matched by the wildcard will be used as identifiers for the respective subsets. Therefore, include prefixes/suffixes that are identical to all files literally in the glob string (e.g. 'prefix.*.suffix'). Required if '--subset-directory' is specified. Default: '%default'.",
        metavar="glob"
    ),
    make_option(
        "--subset-annotation",
        action="store",
        type="character",
        default=NULL,
        help="Optional annotation table for the subsets of feature identifiers defined by the '--subset-directory' and '--subset-glob' options. Specify '--subset-annotation-has-header' if the table includes a header line. The table must contain at least two columns containing (1) the values matched by the wildcard in '--subset-glob' and (2) a short descriptive name or official identifier (e.g. GO term name and/or identifier) for the subset. If provided, the descriptive name to be used in plots and filenames instead of the value matched by the wildcard. Default: '%default'.",
        metavar="tsv"
    ),
    make_option(
        "--subset-annotation-has-header",
        action="store_true",
        default=FALSE,
        help="Indicates whether the subset annotation table includes a header line. Default: '%default'."
    ),
    make_option(
        "--subset-annotation-name-column",
        action="store",
        type="integer",
        default=1,
        help="Subset annotation table column index (1-based) containing values matched by the wildcard in '--subset-glob'. Required if '--subset-annotation' is specified. Default: '%default'.",
        metavar="int"
    ),
    make_option(
        "--subset-annotation-descriptor-column",
        action="store",
        type="integer",
        default=2,
        help="Subset annotation table column index (1-based) containing a short descriptive name or official identifier (e.g. GO term name and/or identifier) for each feature subset. Required if '--subset-annotation' is specified. Default: '%default'.",
        metavar="int"
    ),
    make_option(
        "--include-all-columns-category",
        action="store_true",
        default=FALSE,
        help="Specify if a category including all columns of '--data-matrix' shall be included. Will be included always if '--annotation' is not specified. Default: '%default'."
    ),
    make_option(
        "--include-all-rows-subset",
        action="store_true",
        default=FALSE,
        help="Specify if a subset including all rows of '--data-matrix' shall be included. Will be included always if '--subset-directory' is not specified. Default: '%default'."
    ),
    make_option(
        "--threshold-rowmedians-above",
        action="store",
        type="numeric",
        default=NULL,
        help="For any given heatmap, plot only features whose median value is equal to or above the specified threshold. If specified together with '--threshold-rowmedians-below', features passing either filter are considered. Default: '%default'.",
        metavar="float"
    ),
    make_option(
        "--threshold-rowmedians-below",
        action="store",
        type="numeric",
        default=NULL,
        help="For any given heatmap, plot only features whose median value is equal to or below the specified threshold. If specified together with '--threshold-rowmedians-above', features passing either filter are considered. Default: '%default'.",
        metavar="float"
    ),
    make_option(
        "--threshold-absolute-rowmedians",
        action="store_true",
        default=FALSE,
        help="Use absolute values for filtering via '--threshold-rowmedians-above'. If TRUE, option '--threshold-rowmedians-below' is ignored. Default: '%default'."
    ),
    make_option(
        "--threshold-rowmedians-per-column-sidebar-category",
        action="store",
        type="character",
        default=NULL,
        help="Apply row median threshold separately for each sidebar category listed in the column annotation table as specified by the '--column-annotation-sidebar-color-category-column' option. Allowed values are 'and' (rows included only if row means for each category meet the thresholds), 'or' (rows included if row means for any category meet the thresholds) and NULL (rows included if row means calculated across all columns in current data subset meet the thresholds; default). Default: '%default'.",
        metavar="float"
    ),
    make_option(
        "--plot-x-label",
        action="store",
        type="character",
        default=NULL,
        help="X axis label for heatmap plots. Default: '%default'.",
        metavar="string"
    ),
    make_option(
        "--plot-y-label",
        action="store",
        type="character",
        default=NULL,
        help="Y axis label for heatmap plots. Default: '%default'.",
        metavar="string"
    ),
    make_option(
        "--plot-key-title",
        action="store",
        type="character",
        default=NA,
        help="Title for color keys of heatmap plots. Default: '%default'.",
        metavar="string"
    ),
    make_option(
        "--plot-key-x-label",
        action="store",
        type="character",
        default=NULL,
        help="X axis label for color keys of heatmap plots. Default: '%default'.",
        metavar="string"
    ),
    make_option(
        "--plot-key-y-label",
        action="store",
        type="character",
        default=NULL,
        help="Y axis label for color keys of heatmap plots. Default: '%default'.",
        metavar="string"
    ),
    make_option(
        "--plot-key-height",
        action="store",
        type="numeric",
        default=1.15,
        help="Height of color key. Default: '%default'.",
        metavar="float"
    ),
    make_option(
        "--plot-file-format",
        action="store",
        type="character",
        default="png",
        help="File format for heatmap plots. One of 'svg', 'pdf' or 'png'. Default: '%default'.",
        metavar="file extension"
    ),
    make_option(
        "--plot-trace",
        action="store",
        type="character",
        default="none",
        help="Character string indicating whether a solid trace line should be drawn across rows and/or down columns. The distance of the line from the center of each color-cell is proportional to the size of the measurement. One of 'none', 'column', 'row' or 'both'. Default: '%default'.",
        metavar="string"
    ),
    make_option(
        "--plot-color-lowest",
        action="store",
        type="character",
        default="blue",
        help="Color for lowest value. Default: '%default'.",
        metavar="string"
    ),
    make_option(
        "--plot-color-highest",
        action="store",
        type="character",
        default="orange",
        help="Color for highest value. Default: '%default'.",
        metavar="string"
    ),
    make_option(
        "--plot-color-median",
        action="store",
        type="character",
        default=NULL,
        help="Color for values in between lowest and highest values. If not specified (default), a 2-color gradient is used. Default: '%default'.",
        metavar="string"
    ),
    make_option(
        "--plot-dendrogram-height",
        action="store",
        type="numeric",
        default=NULL,
        help="Height of column dendrogram in inches. By default, the size of the column dendrogram is determined by the logarithm of the number of columns to plot.",
        metavar="float"
    ),
    make_option(
        "--plot-dendrogram-width",
        action="store",
        type="numeric",
        default=NULL,
        help="Width of row dendrogram in inches. By default, the size of the row dendrogram is determined by the logarithm of the number of rows to plot.",
        metavar="float"
    ),
    make_option(
        "--plot-rows-per-inch",
        action="store",
        type="numeric",
        default=8,
        help="Number of heatmap rows per inch. Default: '%default'.",
        metavar="float"
    ),
    make_option(
        "--plot-columns-per-inch",
        action="store",
        type="numeric",
        default=8,
        help="Number of heatmap columns per inch. Default: '%default'.",
        metavar="float"
    ),
    make_option(
        "--plot-offset-row-labels",
        action="store",
        type="numeric",
        default=0.1,
        help="Number of character-width spaces to place between row labels and the edge of the plotting region. Default: '%default'.",
        metavar="float"
    ),
    make_option(
        "--plot-offset-column-labels",
        action="store",
        type="numeric",
        default=0.1,
        help="Number of character-width spaces to place between column labels and the edge of the plotting region. Default: '%default'.",
        metavar="float"
    ),
    make_option(
        "--plot-row-label-expansion-factor",
        action="store",
        type="numeric",
        default=0.6,
        help="Expansion factor for row labels. Default: '%default'.",
        metavar="float"
    ),
    make_option(
        "--plot-column-label-expansion-factor",
        action="store",
        type="numeric",
        default=0.6,
        help="Expansion factor for column labels. Default: '%default'.",
        metavar="float"
    ),
    make_option(
        "--plot-column-label-angle",
        action="store",
        type="numeric",
        default=90,
        help="Angle of column labels in degrees from horizontal. Default: '%default'.",
        metavar="float"
    ),
    make_option(
        "--plot-resolution",
        action="store",
        type="integer",
        default=300,
        help="Resolution for plots of file format 'png'. Default: '%default'.",
        metavar="int"
    ),
    make_option(
        "--plot-values-symmetrical",
        action="store_true",
        default=FALSE,
        help="Specify if plot values are symmetrical around zero. Default: '%default'."
    ),
    make_option(
        "--write-plot-row-labels",
        action="store_true",
        default=FALSE,
        help="Specify if row labels shall be written to a file for each plot. Default: '%default'."
    ),
    make_option(
        "--write-plot-col-labels",
        action="store_true",
        default=FALSE,
        help="Specify if column labels shall be written to a file for each plot. Default: '%default'."
    ),
    make_option(
        c("-h", "--help"),
        action="store_true",
        default=FALSE,
        help="Show this information and die. Default: '%default'."
    ),
    make_option(
        c("-u", "--usage"),
        action="store_true",
        default=FALSE,
        dest="help",
        help="Show this information and die. Default: '%default.'"
    ),
    make_option(
        c("-v", "--verbose"),
        action="store_true",
        default=FALSE,
        help="Print log messages to STDOUT. Default: '%default'."
    )
)

# Parse command-line arguments
opt_parser <- OptionParser(usage=paste("Usage:", script, "[OPTIONS] --count-table <TSV>\n", sep=" "), option_list = option_list, add_help_option=FALSE, description=msg)
opt <- parse_args(opt_parser)

# Re-assign variables
dat <- opt[["data-matrix"]]
dat.head <- opt[["data-has-header"]]
col.id.prefix <- opt[["column-id-prefix"]]
col.id.suffix <- opt[["column-id-suffix"]]
out.dir <- opt[["output-directory"]]
run.id <- opt[["run-id"]]
excl <- opt[["exclude"]]
col.anno <- opt[["column-annotation"]]
col.anno.head <- opt[["column-annotation-has-header"]]
col.anno.id.col <- opt[["column-annotation-id-column"]]
col.anno.name.col <- opt[["column-annotation-name-column"]]
col.anno.cat.cols <- opt[["column-annotation-category-columns"]]
col.anno.side.color.col <- opt[["column-annotation-sidebar-color-category-column"]]
row.anno <- opt[["row-annotation"]]
row.anno.head <- opt[["row-annotation-has-header"]]
row.anno.id.col <- opt[["row-annotation-id-column"]]
row.anno.name.col <- opt[["row-annotation-name-column"]]
row.anno.side.color.col <- opt[["row-annotation-sidebar-color-category-column"]]
subs.dir <- opt[["subset-directory"]]
subs.glob <- opt[["subset-glob"]]
subs.anno <- opt[["subset-annotation"]]
subs.head <- opt[["subset-annotation-has-header"]]
subs.name.col <- opt[["subset-annotation-name-column"]]
subs.desc.col <- opt[["subset-annotation-descriptor-column"]]
incl.all.cols <- opt[["include-all-columns-category"]]
incl.all.rows <- opt[["include-all-rows-subset"]]
cutoff.high <- opt[["threshold-rowmedians-above"]]
cutoff.low <- opt[["threshold-rowmedians-below"]]
cutoff.abs <- opt[["threshold-absolute-rowmedians"]]
cutoff.per.cat <- opt[["threshold-rowmedians-per-column-sidebar-category"]]
plot.xlab <- opt[["plot-x-label"]]
plot.ylab <- opt[["plot-y-label"]]
plot.key.title <- opt[["plot-key-title"]]
plot.key.xlab <- opt[["plot-key-x-label"]]
plot.key.ylab <- opt[["plot-key-y-label"]]
plot.key.hei <- opt[["plot-key-height"]]
plot.format <- opt[["plot-file-format"]]
plot.trace <- opt[["plot-trace"]]
plot.col.low <- opt[["plot-color-lowest"]]
plot.col.high <- opt[["plot-color-highest"]]
plot.col.mid <- opt[["plot-color-median"]]
plot.dend.hei <- opt[["plot-dendrogram-height"]]
plot.dend.wid <- opt[["plot-dendrogram-width"]]
plot.rows.per.inch <- opt[["plot-rows-per-inch"]]
plot.cols.per.inch <- opt[["plot-columns-per-inch"]]
plot.offsetRow <- opt[["plot-offset-row-labels"]]
plot.offsetCol <- opt[["plot-offset-column-labels"]]
plot.cexRow <- opt[["plot-row-label-expansion-factor"]]
plot.cexCol <- opt[["plot-column-label-expansion-factor"]]
plot.srtCol <- opt[["plot-column-label-angle"]]
plot.res <- opt[["plot-resolution"]]
plot.symbreaks <- opt[["plot-values-symmetrical"]]
write.row.labels <- opt[["write-plot-row-labels"]]
write.col.labels <- opt[["write-plot-col-labels"]]
verb <- opt[["verbose"]]

# Validate required arguments
if ( is.null(dat) ) {
        print_help(opt_parser)
        stop("[ERROR] Required argument missing! Aborted.")
}


###################
###  FUNCTIONS  ###
###################

# Returns a vector of integers from a Bash 'cut'-like field selection string containing commas and dashes
get.field.selection.vector <- function(x) {

    # Remove whitespace
    x <- gsub("\\s", "", x)

    # Return NULL if string is not of required format
    if ( ! grepl("^\\d+([,-]\\d+)*$", x) ) return(NULL)

    # Split string by special characters
    x <- strsplit(unlist(strsplit(x, ",")), "-")

    # Return NULL if multiple dashes are used in one expression
    if ( any(sapply(x, length) > 2) ) return(NULL)

    # Iterate over terms
    x <- lapply(x, function(term) {

        # Convert to integer
        term <- as.integer(term)

        # Return integer or sequence of integers
        if ( length(term) == 1 ) return(term) else return(seq(term[1], term[2]))

    })

    # Obtain vector of sorted unique integers
    x <- unique(unlist(x))

    # Return vector
    return(x)

}

# Get wildcard matched strings
get.wildcard.matches <- function(glob, paths) {

    # Split glob by asterisks and stretches of question marks
    frags <- unlist(strsplit(glob, "\\*|\\?+"))

    # Remove empty strings from fragments
    frags <- frags[frags != ""]
print(frags)
    # Return NULL if more than 2 fragments result
    if ( length(frags) > 2 ) return(NULL)

    # Iterate over paths...
    matched <- sapply(paths, function(path) {
print(path)
        # Iterate over fragments...
        for (frag in frags) {

            # Remove fragment from path
            path <- sub(frag, "", path, fixed=TRUE)

        }

        # Return trimmed path
        return(path)

    })

    # Return wildcard matched strings
    return(matched)

}

# Create safe filenames from character vectors
get.safe.filenames <- function(x) {

    # Convert object to character vector
    x <- as.character(x)

    # Replace parentheses, angular and curly brackets with dots
    x <- gsub("[()\\[\\]{}]", ".", x, perl=TRUE)

    # Replace all other special characters except '+' and '-' to underscores
    x <- gsub("[ ~`!@#$%^&*=|\\\"';:,<>?/]", "_", x, perl=TRUE)

    # Trim consecutive underscores and dots etc
    x <- gsub("_+", "_", x, perl=TRUE)
    x <- gsub("\\.+", ".", x, perl=TRUE)
    x <- gsub("(_\\.|\\._)", ".", x, perl=TRUE)
    x <- gsub("(_-|-_)", "-", x, perl=TRUE)

    # Remove terminal underscores and dots
    x <- gsub("^[\\._]", "", x, perl=TRUE)
    x <- gsub("[\\._]$", "", x, perl=TRUE)

    # Return processed character vector
    return(x)

}

# Get medians per row of a matrix
rowMedians <- function(mt) {

    apply(mt, 1, median)

}

# Return logical vector for rows to keep
filter.by.row.medians <- function(x, high=NULL, low=NULL, abs=FALSE) {

    # Filter by absolute value
    if ( ! is.null(high) && abs ) {
        return(rowMedians(abs(x)) >= cutoff.high)

    # Filter by high and low thresholds
    } else if ( ! is.null(cutoff.high) && ! is.null(cutoff.low) ) {
        return(rowMedians(x) >= cutoff.high | rowMedians(x) <= cutoff.low)

    # Filter by high threshold only
    } else if ( ! is.null(cutoff.high) ) {
        return(rowMedians(x) >= cutoff.high)

    # Filter by low threshold only
    } else if ( ! is.null(cutoff.low) ) {
        return(rowMedians(x) <= cutoff.low)

    # Do not filter anything
    } else {
        return(rep(TRUE, nrow(x)))
    }

}

# Return logical vector for rows to keep
filter.by.row.means <- function(x, high=NULL, low=NULL, abs=FALSE) {

    # Filter by absolute value
    if ( ! is.null(high) && abs ) {
        return(rowMeans(abs(x)) >= cutoff.high)

    # Filter by high and low thresholds
    } else if ( ! is.null(cutoff.high) && ! is.null(cutoff.low) ) {
        return(rowMeans(x) >= cutoff.high | rowMeans(x) <= cutoff.low)

    # Filter by high threshold only
    } else if ( ! is.null(cutoff.high) ) {
        return(rowMeans(x) >= cutoff.high)

    # Filter by low threshold only
    } else if ( ! is.null(cutoff.low) ) {
        return(rowMeans(x) <= cutoff.low)

    # Do not filter anything
    } else {
        return(rep(TRUE, nrow(x)))
    }

}

# Plot heatmap
plot.heat <- function(
    x,
    prefix        = "plot",  # output filename prefix
    format        = "svg",   # output file format
    col           = "heat.colors",  # heatmap color palette
    main          = NULL,    # plot title
    xlab          = NULL,    # x axis label
    ylab          = NULL,    # y axis label
    spacer        = 1.1,     # size of generic spacer to offset labels and titles in lines
    title.hei     = 3.1,     # size of title field in lines (ignored if 'main' is NULL)
    x.cat.lab.hei = 3.1,     # size of x axis category label in lines ('spacer' is used instead if 'xlab' is NULL)
    y.cat.lab.wid = 3.1,     # size of y axis category label in lines ('spacer' is used instead if 'ylab' is NULL)
    labCol        = NULL,    # column labels to use instead of column names of x
    labRow        = NULL,    # row labels to use instead of row names of x
    key.title     = NULL,    # title of color key
    key.xlab      = NULL,    # x axis label of color key
    key.ylab      = NULL,    # y axis label of color key
    key.hei       = 1.15,    # height of color key in inches
    trace         = "none",  # trace line; one of 'none', 'column', 'row', or 'both'. see '?heatmap.2'
    ColSideColors = NULL,    # vector of color names for (optional) color side bar (length equal to col(x))
    RowSideColors = NULL,    # vector of color names for (optional) row side bar (length equal to nrow(x))
    dend.hei      = NULL,    # height of column dendrogram in inches
    dend.wid      = NULL,    # width of row dendrogram in inches
    col.side.hei  = 0.3,     # height of column sidebar in inches (if applicable)
    row.side.wid  = 0.3,     # width of row sidebar in inches (if applicable)
    dend.log.fact = 0.3,     # factor for determining dendrogram sizes from matrix size if not specified via 'dend.hei' and 'dend.wid'
    rows.per.inch = 12,      # number of rows per inch of heatmap (may be inaccurate for small row numbers)
    cols.per.inch = 12,      # number of columns per inch of heatmap (may be inaccurate for small column numbers)
    offsetRow     = 0.2,     # offset of row labels from heatmap in lines
    offsetCol     = 0.2,     # offset of column labels from heatmap in rows
    cexRow        = 0.6,     # character expansion factor for row labels
    cexCol        = 0.6,     # character expansion factor for column labels
    srtCol        = 90,      # angle of column labels in degrees (0 = horizontal, 90 = vertical)
    res           = 300,     # resolution for plotting in 'png' format
    symbreaks     = FALSE,   # values symmetrical
    cex.main      = 0.8,     # character expansion for plot title
    ...
) {

    # Coerce data to matrix
    x <- as.matrix(x)

    # Build output filename
    if ( format == "svg") file <- paste(prefix, "svg", sep=".")
    if ( format == "png") file <- paste(prefix, "png", sep=".")
    if ( format == "pdf") file <- paste(prefix, "pdf", sep=".")

    # Open dummy graphics device
    pdf(NULL)

    # Get line height in inches
    line.inch <- par("cin")[2]

    # Get title height and width in inches
    title.wid <- strwidth(main, units="inches", cex=cex.main)
    title.hei <- title.hei * line.inch

    # Set dendrogram sizes if not specified
    if ( is.null(dend.hei) ) dend.hei <- log2(ncol(x)) * dend.log.fact
    if ( is.null(dend.wid) ) dend.wid <- log2(nrow(x)) * dend.log.fact

    # Get maximum label heights and widths in inches
    if ( is.null(labCol) ) labCol <- colnames(x)
    if ( is.null(labRow) ) labRow <- rownames(x)
    x.lab.hei <- max(strheight(labCol, units="inches", cex=cexCol))
    x.lab.wid <- max(strwidth(labCol, units="inches", cex=cexCol))
    y.lab.hei <- max(strheight(labRow, units="inches", cex=cexRow))
    y.lab.wid <- max(strwidth(labRow, units="inches", cex=cexRow))

    # Adjust column label sizes if placed at an angle
    if ( srtCol %% 180 ) {
        rad <- srtCol * pi / 180
        x.lab.hei.new <- abs(x.lab.wid * sin(rad)) + abs(x.lab.hei * cos(rad))
        x.lab.wid <- abs(x.lab.wid * cos(rad)) + abs(x.lab.hei * sin(rad))
        x.lab.hei <- x.lab.hei.new
    }

    # Adjust dendrogram width if width of rotated label may be wider than dendrogram
    dend.wid <- max(dend.wid, x.lab.wid / 2)

    # Set generic spacer for category labels, if absent
    if ( is.null(xlab) ) x.cat.lab.hei <- spacer
    if ( is.null(ylab) ) y.cat.lab.wid <- spacer

    # Add category labels and offset to relevant label sizes
    x.lab.hei <- x.lab.hei + ( offsetCol + x.cat.lab.hei ) * line.inch
    y.lab.wid <- y.lab.wid + ( offsetRow + y.cat.lab.wid ) * line.inch

    # Set heatmap label margins
    margins <- c(x.lab.hei / line.inch, y.lab.wid / line.inch)

    # Remove figure margins
    mar <- c(0, 0, 0, 0)
    par("mar" = mar)

    # Close graphics device
    invisible(dev.off())

    # Get heatmap size in inches
    heat.hei <- nrow(x) / rows.per.inch
    heat.wid <- ncol(x) / cols.per.inch

    # Set layout size
    if ( ! is.null( ColSideColors ) && ! is.null( RowSideColors ) ) {
        lmat <- matrix(c(0, 0, 0, 4, 4, 4, 0, 3, 0, 2, 1, 5, 0, 6, 0), ncol=3, byrow=TRUE)
        lmat <- rbind(c(0, 0, 0), c(6, 6, 6), c(0, 0, 5), c(0, 0, 2), c(4, 1, 3))
        lhei <- c(title.hei, key.hei, dend.hei, col.side.hei, heat.hei + x.lab.hei)
        lwid <- c(dend.wid, row.side.wid, heat.wid + y.lab.wid)
    }
    else if ( ! is.null( ColSideColors ) ) {
        lmat <- rbind(c(0, 0), c(5, 5), c(0, 4), c(0, 1), c(3, 2))
        lhei <- c(title.hei, key.hei, dend.hei, col.side.hei, heat.hei + x.lab.hei)
        lwid <- c(dend.wid, heat.wid + y.lab.wid)
    }
    else if ( ! is.null( RowSideColors ) ) {
        lmat <- rbind(c(0, 0, 0), c(5, 5, 5), c(0, 0, 4), c(3, 1, 2))
        lhei <- c(title.hei, key.hei, dend.hei, heat.hei + x.lab.hei)
        lwid <- c(dend.wid, row.side.wid, heat.wid + y.lab.wid)
    }
    else {
        lmat <- rbind(c(0, 0), c(4, 4), c(0, 3), c(2, 1))
        lhei <- c(title.hei, key.hei, dend.hei, heat.hei + x.lab.hei)
        lwid <- c(dend.wid, heat.wid + y.lab.wid)
    }

    # Set plot size in inches
    hei <- sum(lhei)
    wid <- sum(lwid)
    wid <- max(wid, title.wid + spacer * line.inch, x.lab.wid)

    # Open graphics device
    if ( format == "svg") svg(file, width=wid, height=hei)
    if ( format == "pdf") pdf(file, width=wid, height=hei)
    if ( format == "png") png(file, width=wid, height=hei, units="in", res=res)

    # Set margins
    par("mar" = mar, cex.main=cex.main)

    # Plot
    if ( ! is.null (ColSideColors) && ! is.null (RowSideColors) ) {
        plot <- capture.output(heatmap.2(
            x,
# TODO
#Rowv = FALSE,
#Colv = FALSE,
#dendrogram = 'none',
###
            distfun       = function(x) dist(x, method = 'euclidean'),
            hclustfun     = function(x) hclust(x, method = 'complete'),
            col           = col,
            trace         = trace,
            ColSideColors = ColSideColors,
            RowSideColors = RowSideColors,
            margins       = margins,
            density.info  = 'none',
            xlab          = xlab,
            ylab          = ylab,
            key.title     = key.title,
            key.xlab      = key.xlab,
            key.ylab      = key.ylab,
            labCol        = labCol,
            labRow        = labRow,
            lmat          = lmat,
            lwid          = lwid,
            lhei          = lhei,
            offsetRow     = offsetRow,
            offsetCol     = offsetCol,
            cexRow        = cexRow,
            cexCol        = cexCol,
            srtCol        = srtCol,
            symbreaks     = symbreaks,
            ...
        ), file='/dev/null')
    } else if ( ! is.null(ColSideColors) ) {
        plot <- capture.output(heatmap.2(
            x,
# TODO
#Rowv = FALSE,
#Colv = FALSE,
#dendrogram = 'none',
            distfun       = function(x) dist(x, method = 'euclidean'),
            hclustfun     = function(x) hclust(x, method = 'complete'),
            col           = col,
            trace         = trace,
            ColSideColors = ColSideColors,
            margins       = margins,
            density.info  = 'none',
            xlab          = xlab,
            ylab          = ylab,
            key.title     = key.title,
            key.xlab      = key.xlab,
            key.ylab      = key.ylab,
            labCol        = labCol,
            labRow        = labRow,
            lmat          = lmat,
            lwid          = lwid,
            lhei          = lhei,
            offsetRow     = offsetRow,
            offsetCol     = offsetCol,
            cexRow        = cexRow,
            cexCol        = cexCol,
            srtCol        = srtCol,
            symbreaks     = symbreaks,
            ...
        ), file='/dev/null')
    } else if ( ! is.null(RowSideColors) ) {
        plot <- capture.output(heatmap.2(
            x,
# TODO
#Rowv = FALSE,
#Colv = FALSE,
#dendrogram = 'none',
            distfun       = function(x) dist(x, method = 'euclidean'),
            hclustfun     = function(x) hclust(x, method = 'complete'),
            col           = col,
            trace         = trace,
            RowSideColors = RowSideColors,
            margins       = margins,
            density.info  = 'none',
            xlab          = xlab,
            ylab          = ylab,
            key.title     = key.title,
            key.xlab      = key.xlab,
            key.ylab      = key.ylab,
            labCol        = labCol,
            labRow        = labRow,
            lmat          = lmat,
            lwid          = lwid,
            lhei          = lhei,
            offsetRow     = offsetRow,
            offsetCol     = offsetCol,
            cexRow        = cexRow,
            cexCol        = cexCol,
            srtCol        = srtCol,
            symbreaks     = symbreaks,
            ...
        ), file='/dev/null')
    } else {
        plot <- capture.output(heatmap.2(
            x,
# TODO
#Rowv = FALSE,
#Colv = FALSE,
#dendrogram = 'none',
            distfun       = function(x) dist(x, method = 'euclidean'),
            hclustfun     = function(x) hclust(x, method = 'complete'),
            col           = col,
            trace         = trace,
            margins       = margins,
            density.info  = 'none',
            xlab          = xlab,
            ylab          = ylab,
            key.title     = key.title,
            key.xlab      = key.xlab,
            key.ylab      = key.ylab,
            labCol        = labCol,
            labRow        = labRow,
            lmat          = lmat,
            lwid          = lwid,
            lhei          = lhei,
            offsetRow     = offsetRow,
            offsetCol     = offsetCol,
            cexRow        = cexRow,
            cexCol        = cexCol,
            srtCol        = srtCol,
            symbreaks     = symbreaks,
            ...
        ), file='/dev/null')
    }

    # Plot title
    title(main, line=-2)

    # Debug
    #print(par())
    #print(paste("height", hei, sep=": "))
    #print(paste("width", wid, sep=": "))
    #print(paste("margins", margins * line.inch, sep=": "))
    #print(paste("label heigth", lab.hei, sep=": "))
    #print(paste("label width", lab.wid, sep=": "))
    #print(paste("heat heigth", heat.hei, sep=": "))
    #print(paste("heat width", heat.wid, sep=": "))
    #print(paste("dendrogram height", dend.hei, sep=": "))
    #print(paste("dendrogram width", dend.wid, sep=": "))
    #print(paste("key height", key.hei, sep=": "))
    #print(paste("offsetCol", offsetCol * line.inch, sep=": "))
    #print(paste("offsetRow", offsetRow * line.inch, sep=": "))

    # Close graphics device
    invisible(dev.off())

    # Return plot parameters
    return(plot)

}


##############
###  MAIN  ###
##############

# Write log
if ( verb ) cat("Creating output directory...\n", sep="'")

# Create output directory
dir.create(out.dir, recursive=TRUE, showWarnings=FALSE)

# Write log
if ( verb ) cat("Importing data...\n", sep="'")

# Import data matrix
dat <- read.delim(dat, header=dat.head, row.names=1, check.names=FALSE, stringsAsFactors=FALSE)

# Import sample exclude list
if ( ! is.null(excl) ) excl <- readLines(excl)

# Import column annotation table
if ( ! is.null(col.anno) ) col.anno <- read.delim(col.anno, header=col.anno.head, row.names=NULL, stringsAsFactors=FALSE)

# Import row annotation table
if ( ! is.null(row.anno) ) row.anno <- read.delim(row.anno, header=row.anno.head, row.names=NULL, stringsAsFactors=FALSE)

# Import subset annotation table
if ( ! is.null(subs.anno) ) subs.anno <- read.delim(subs.anno, header=subs.head, row.names=NULL, stringsAsFactors=FALSE, colClasses="character")

# Write log
if ( verb ) cat("Processing data...\n", sep="")

# Remove undesired prefix/suffix from column names
if ( ! is.null(col.id.prefix) ) colnames(dat) <- gsub(col.id.prefix, "", colnames(dat), fixed=TRUE)
if ( ! is.null(col.id.suffix) ) colnames(dat) <- gsub(col.id.suffix, "", colnames(dat), fixed=TRUE)

# Filter out columns to be excluded
if ( ! is.null(excl) ) dat <- dat[, ! colnames(dat) %in% excl]

# Filter data by row annotations and vice versa; reorder row annotations
if ( ! is.null(row.anno) ) {

    # Die if identifier or name columns are not provided or are not present in annotation
    if ( is.null(row.anno.id.col) || ncol(row.anno) < max(row.anno.id.col, row.anno.name.col, row.anno.side.color.col) ) {
        print_help(opt_parser)
        stop("[ERROR] Row annotation table misses required columns! Aborted.")
    }

    # Filter only annotated data rows
    dat <- dat[rownames(dat) %in% row.anno[, row.anno.id.col], , drop=FALSE]

    # Filter only annotations for corresponding available rows
    row.anno <- row.anno[row.anno[, row.anno.id.col] %in% rownames(dat), , drop=FALSE]

    # Re-order annotations to match order of columns in data matrix
    row.anno <- row.anno[match(rownames(dat), row.anno[, row.anno.id.col]), ]

}

# Filter data by column annotations and vice versa; reorder column annotations
if ( ! is.null(col.anno) ) {

    # Get category columns as integer vector
    col.anno.cat.cols <- get.field.selection.vector(col.anno.cat.cols)

    # Die if identifier column is not provided or specified columns are not present in annotation
    if ( is.null(col.anno.id.col) || ncol(col.anno) < max(col.anno.id.col, col.anno.name.col, col.anno.cat.cols, col.anno.side.color.col) ) {
        print_help(opt_parser)
        stop("[ERROR] Column annotation table misses required columns! Aborted.")
    }

    # Filter only annotated data columns
    dat <- dat[, colnames(dat) %in% col.anno[, col.anno.id.col], drop=FALSE]

    # Filter only annotations for corresponding available columns
    col.anno <- col.anno[col.anno[, col.anno.id.col] %in% colnames(dat), , drop=FALSE]

    # Re-order annotations to match order of columns in data matrix
    col.anno <- col.anno[match(colnames(dat), col.anno[, col.anno.id.col]), ]

}

# Write log
if ( verb ) cat("Compile data categories and subsets...\n", sep="")

# Get category table
if ( ! is.null(col.anno) ) {

    # Subset category columns
    cats.df <- col.anno[, col.anno.cat.cols, drop=FALSE]
    rownames(cats.df) <- col.anno[, col.anno.id.col]

    # Get list of categories and corresponding column names
    cats.ls <- lapply(lapply(cats.df, split, x=cats.df), lapply, rownames)

    # Set list of categories to NULL if of length zero
    if ( ! length(cats.ls) ) cats.ls <- NULL

} else {

    # If data is not to be grouped by categories, set list of categories to NULL
    cats.ls <- NULL

}

# Add category for all columns
if ( is.null(cats.ls) || incl.all.cols ) cats.ls$uncategorized$all_fields <- colnames(dat)

# Get feature subsets
if ( ! is.null(subs.dir) ) {

    # Find files containing feature identifiers
    subs.paths <- sort(dir(subs.dir, pattern=glob2rx(subs.glob), recursive=FALSE, full.names=TRUE))

    # Get subset short names from file paths
    names(subs.paths) <- get.wildcard.matches(subs.glob, basename(subs.paths))

    # Die if no files were found or specified glob is illegal
    if ( ! length(subs.paths) || is.null(names(subs.paths)) ) {
        print_help(opt_parser)
        stop("[ERROR] No subset files found or illegal value provided for '--subset-glob'! Aborted.")
    }

    # Process subset annotations
    if ( ! is.null(subs.anno) ) {

        # Die if name or descriptor columns are not provided or are not present in annotation
        if ( is.null(subs.name.col) || is.null(subs.desc.col) || ncol(subs.anno) < max(subs.name.col, subs.desc.col) ) {
            print_help(opt_parser)
            stop("[ERROR] Subset annotation table misses required columns! Aborted.")
        }

        # Filter only annotated subsets
        subs.paths <- subs.paths[names(subs.paths) %in% subs.anno[, subs.name.col]]

        # Filter only annotations for corresponding available subset files
        subs.anno <- subs.anno[subs.anno[, subs.name.col] %in% names(subs.paths), , drop=FALSE]

        # Re-order subset annotation to match order of subset file paths
        subs.anno <- subs.anno[match(names(subs.paths), subs.anno[, subs.name.col]), , drop=FALSE]

        # Assign subset descriptions to vector
        subs.desc <- subs.anno[, subs.desc.col]

    } else {

        # If no subset annotations are provided, use subset name as descriptor
        subs.desc <- names(subs.paths)

    }

    # Replace subset names with combination of short names and descriptors
    names(subs.paths) <- paste(names(subs.paths), subs.desc, sep=".")

    # Get list of subsets
    subs.ls <- mapply(function(file, desc) {
        return(list(
            ids = readLines(file),
            desc = desc
        ))
    }, subs.paths, subs.desc, SIMPLIFY=FALSE)

} else {

    # If data is not to be grouped by feature subsets, set subset list to NULL
    subs.ls <- NULL

}

# Add category for all features
if ( is.null(subs.ls) || incl.all.rows ) subs.ls[["all_features"]] <- list(ids=rownames(dat), desc="all features")

# Get list of column and row indices for categories and subsets, respectively
cats.subs.ls <- unlist(sapply(cats.ls, function(cat) {
    unlist(sapply(cat, function(subcat) {
        sapply(subs.ls, function(subset) {
            return(list(
                rows = subset[["ids"]][subset[["ids"]] %in% rownames(dat)],
                cols = subcat
            ))
        }, simplify=FALSE)
    }, simplify=FALSE), recursive=FALSE)
}, simplify=FALSE), recursive=FALSE)

# Set plot colors
plot.col <- if ( is.null(plot.col.mid) ) colorRampPalette(c(plot.col.low, plot.col.high))(n = 299) else colorRampPalette(c(plot.col.low, plot.col.mid, plot.col.high))(n = 299)

# Write log
if ( verb ) cat("Generate heatmaps...\n", sep="")

# Iterate over all category/subset combinations
results <- sapply(names(cats.subs.ls), function(cond.name) {

    # Split condition name
    name.parts <- unlist(strsplit(cond.name, ".", fixed=TRUE))
    cat.type <- name.parts[1]
    cat.name <- name.parts[2]
    sub.name <- name.parts[3]
    sub.desc <- paste(name.parts[4:length(name.parts)], collapse=".")

    # Build plot title
    plot.title <- gsub("_", " ", paste(cat.type, " / ", cat.name, "\n", sub.name, " / ", sub.desc, sep=""))

    # Get filename-safe condition name
    name.safe <- get.safe.filenames(cond.name)

    # Build output filename for heatmap
    if ( name.safe == "uncategorized.all_fields.all_features" ) {
        out.file.prefix <- file.path(out.dir, run.id)
    } else {
        out.file.prefix <- file.path(out.dir, paste(run.id, name.safe, sep="."))
    }

    # Subset data, row and column annotations
    dat.cond <- dat[cats.subs.ls[[cond.name]]$rows, cats.subs.ls[[cond.name]]$cols, drop=FALSE]

    if ( ! is.null(row.anno) ) row.anno.cond <- row.anno[match(rownames(dat.cond), row.anno[, row.anno.id.col]), , drop=FALSE]
    if ( ! is.null(col.anno) ) col.anno.cond <- col.anno[match(colnames(dat.cond), col.anno[, col.anno.id.col]), , drop=FALSE]

    # Filter data
    if ( is.null(cutoff.per.cat) ) {
        dat.cond <- dat.cond[filter.by.row.medians(dat.cond, high=cutoff.high, low=cutoff.low, abs=cutoff.abs), , drop=FALSE]
    } else {
        filt.mt <- as.matrix(sapply(unique(col.anno.cond[, col.anno.side.color.col]), function(cat) {
            filter.by.row.medians(dat.cond[, col.anno.cond[, col.anno.side.color.col] == cat, drop=FALSE], high=cutoff.high, low=cutoff.low, abs=cutoff.abs)
        }))
        if ( cutoff.per.cat == "and" ) { 
            dat.cond <- dat.cond[rowSums(filt.mt) == ncol(filt.mt), , drop=FALSE]
        } else if ( cutoff.per.cat == "or" ) {
            dat.cond <- dat.cond[rowSums(filt.mt) >= 1, , drop=FALSE]
        } else {
            print_help(opt_parser)
            stop("[ERROR] Illegal value for '--threshold-rowmedians-per-column-sidebar-category'! Aborted.")
        }
    }

    # Filter row and column annotations
    if ( ! is.null(row.anno) ) row.anno.cond <- row.anno[match(rownames(dat.cond), row.anno[, row.anno.id.col]), , drop=FALSE]
    if ( ! is.null(col.anno) ) col.anno.cond <- col.anno[match(colnames(dat.cond), col.anno[, col.anno.id.col]), , drop=FALSE]

    # Get row and column labels
    row.labels <- if ( ! is.null(row.anno) && ! is.null(row.anno.name.col) ) row.anno.cond[, row.anno.name.col] else rownames(dat.cond)
    col.labels <- if ( ! is.null(col.anno) && ! is.null(col.anno.name.col) ) col.anno.cond[, col.anno.name.col] else colnames(dat.cond)
    if ( write.row.labels ) writeLines(row.labels, paste(out.file.prefix, "row_labels", sep="." ))
    if ( write.col.labels ) writeLines(col.labels, paste(out.file.prefix, "col_labels", sep="." ))

    # Get row and column sidebar colors
    if ( ! is.null(row.anno) && ! is.null(row.anno.side.color.col) ) {
        row.side.cols <- as.integer(as.factor(row.anno.cond[, row.anno.side.color.col]))
        pal.row <- rep(brewer.pal(min(max(row.side.cols, 3), 12), "Set3"), ceiling(length(unique(row.side.cols)) / 12))
        row.side.cols <- pal.row[row.side.cols]
    } else {
        row.side.cols <- NULL
    }
    if ( ! is.null(col.anno) && ! is.null(col.anno.side.color.col) ) {
        col.side.cols <- as.integer(as.factor(col.anno.cond[, col.anno.side.color.col]))
        pal.col <- rep(brewer.pal(min(max(col.side.cols, 3), 12), "Set3"), ceiling(length(unique(col.side.cols)) / 12))
        col.side.cols <- pal.col[col.side.cols]
    } else {
        col.side.cols <- NULL
    }

    # Ensure enough data is available for plotting...
    if ( nrow(dat.cond) > 1 && ncol(dat.cond) > 1 ) {

        # Write log
        if ( verb ) cat("Generate heatmap ", paste(basename(out.file.prefix), plot.format, sep="."), "...\n", sep="'")

        # Plot heatmap
        plot.res <- plot.heat(
            x             = dat.cond,
            prefix        = out.file.prefix,
            format        = plot.format,
            main          = plot.title,
            col           = plot.col,
            xlab          = plot.xlab,
            ylab          = plot.ylab,
            labCol        = col.labels,
            labRow        = row.labels,
            key.title     = plot.key.title,
            key.xlab      = plot.key.xlab,
            key.ylab      = plot.key.ylab,
            key.hei       = plot.key.hei,
            trace         = plot.trace,
            ColSideColors = col.side.cols,
            RowSideColors = row.side.cols,
            dend.hei      = plot.dend.hei,
            dend.wid      = plot.dend.wid,
            rows.per.inch = plot.rows.per.inch,
            cols.per.inch = plot.cols.per.inch,
            offsetRow     = plot.offsetRow,
            offsetCol     = plot.offsetCol,
            cexRow        = plot.cexRow,
            cexCol        = plot.cexCol,
            srtCol        = plot.srtCol,
            res           = plot.res,
            symbreaks     = plot.symbreaks
        )

    } else {

        # Issue warning
        if ( verb ) cat("[WARNING] Not enough data to plot ", paste(basename(out.file.prefix), plot.format, sep="."), "! No plot generated.\n", sep="'")

    }

}, simplify=FALSE)

# Build output filename for R image
out.file.rimage <- file.path(out.dir, paste(run.id, "RData", sep="."))

# Write log
if ( verb ) cat("Writing R session image to file ", out.file.rimage ,"...\n", sep="'")

# Save image
save.image(out.file.rimage)

# Write log
if ( verb ) cat("Done.\n", sep="")
