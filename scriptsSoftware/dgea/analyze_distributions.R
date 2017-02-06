#!/usr/bin/env Rscript

# (c) 2017 Alexander Kanitz, Biozentrum, University of Basel
# (@) alexander.kanitz@unibas.ch


#################
###  IMPORTS  ###
#################

# Import required packages
if ( suppressWarnings(suppressPackageStartupMessages(require("optparse"))) == FALSE ) { stop("[ERROR] Package 'optparse' required! Aborted.") }


#######################
###  PARSE OPTIONS  ###
#######################

# Get script name
script <- sub("--file=", "", basename(commandArgs(trailingOnly=FALSE)[4]))

# Build description message
description <- "Generate cumulative distribution function and density plots for each column of a data matrix.\n"
author <- "Author: Alexander Kanitz, Biozentrum, University of Basel"
version <- "Version: 1.0.0 (20-JAN-2017)"
requirements <- "Requires: optparse"
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
        "--output-directory",
        action="store",
        type="character",
        default=getwd(),
        help="Directory where output files shall be written. Default: '%default'.",
        metavar="directory"
    ),
    make_option(
        "--run-id",
        action="store",
        type="character",
        default="experiment",
        help="String used as analysis identifier prefix for output files. Default: '%default'.",
        metavar="file"
    ),
    make_option(
        "--exclude",
        action="store",
        type="character",
        default=NULL,
        help="Text file containing identifiers of samples to be excluded from the analysis. Expected format: One identifier per line. Identifiers have to match column headers of '--data-matrix'. Default: %default.",
        metavar="file"
    ),
    make_option(
        "--column-short-name-prefix",
        action="store",
        type="character",
        default="",
        help="Prefix that will be removed from column names to generate short names to be used in plots and for file name generation. Default: ''.",
        metavar="string"
    ),
    make_option(
        "--column-short-name-suffix",
        action="store",
        type="character",
        default="",
        help="Suffix that will be removed from column names to generate short names to be used in plots and for file name generation. Default: ''.",
        metavar="string"
    ),
    make_option(
        "--subset-directory",
        action="store",
        type="character",
        default=NULL,
        help="Directory containing one or more files containing subsets of feature/gene identifiers, each to be analyzed separately. Identifiers have to match row names of the '--data-matrix' and have to specified one per line. Requires that a valid argument to '--subset-glob' is also provided. If not specified, separate analyses per subset are not performed. Default: %default.",
        metavar="directory"
    ),
    make_option(
        "--subset-glob",
        action="store",
        type="character",
        default=NULL,
        help="File glob to identify subset feature/gene identifier files in '--subset-directory'. Valid values include either a single asterisk '*' or a single stretch of question marks (e.g. '???'). Values matched by the wildcard will be used as identifiers for the respective subsets. Therefore, include prefixes/suffixes that are identical to all files literally in the glob string (e.g. 'prefix.*.suffix'). Required if '--subset-directory' is specified. Default: %default.",
        metavar="glob"
    ),
    make_option(
        "--subset-annotation",
        action="store",
        type="character",
        default=NULL,
        help="Optional annotation table for the subsets of feature/gene identifiers defined by the '--subset-directory' and '--subset-glob' options. The table should be headerless and contain the following in the first two columns: (1) the values matched by the wildcard in '--subset-glob', (2) a short descriptive name or official identifier (e.g. GO term name and/or identifier) for the subset. If provided, the descriptive name is used in plots and filenames instead of the value matched by the wildcard. Default: %default.",
        metavar="tsv"
    ),
    make_option(
        "--minimum-number-of-values-per-set",
        action="store",
        type="integer",
        default=2,
        help="Plot data distributions only if there are at least INT values per column or subset. Default: %default.",
        metavar="int"
    ),
    make_option(
        "--do-not-calculate-exact-ks-p-values",
        action="store_true",
        default=FALSE,
        help="Calculate only approximate P values from Kolmogorov-Smirnov statistics. Not recommended and likely leads to warnings in case of data ties."
    ),
    make_option(
        "--add-only-positive-values-to-avoid-data-ties",
        action="store_true",
        default=FALSE,
        help="Unless '--do-not-calculate-exact-ks-p-values' is set, a small random value is added to each data point to avoid data ties. Specify this option if only positive values shall be added, e.g. if all the data in '--data-matrix' are positive."
    ),
    make_option(
        "--power-of-values-added-to-avoid-ties",
        action="store",
        type="integer",
        default=-6,
        help="The power of the random numbers added to data points to avoid ties (e.g. -3 would result in values in the range of +/- 1/1,000 - 1/10,000). Specify a negative integer in a range appropriate for your data, i.e. at least two orders of magnitude smaller than your lowest value. Ignored if '--do-not-calculate-exact-ks-p-values' is specified. Default: %default.",
        metavar="int"
    ),
    make_option(
        "--plot-x-label",
        action="store",
        type="character",
        default="Value",
        help="A string describing the type/unit of data in '--data-matrix', used for labeling the x axes in all plots. Default: %default.",
        metavar="string"
    ),
    make_option(
        "--plot-vertical-bar",
        action="store",
        type="numeric",
        default=NULL,
        help="A vertical bar at the specified value is added to all plots. Specify NULL to omit drawing vertical bars. Default: %default.",
        metavar="float"
    ),
    make_option(
        "--plot-cdf-median-line",
        action="store_true",
        default=FALSE,
        help="A horizontal line is drawn at the median (cumulative fraction = 0.5) in all CDF plots."
    ),
    make_option(
        "--plot-cdf-points",
        action="store_true",
        default=FALSE,
        help="Plot individual data points in cumulative fraction plots."
    ),
    make_option(
        "--plot-cdf-points-subsets",
        action="store_true",
        default=FALSE,
        help="Plot individual data points when plotting subsets in cumulative fraction plots. Always TRUE if '--plot-cdf-points' is specified."
    ),
    make_option(
        "--plot-width",
        action="store",
        type="numeric",
        default=21,
        help="Width of plot canvas in inches. Each row of the plotting canvas contains 3 individual juxtaposed plots. Default: %default.",
        metavar="float"
    ),
    make_option(
        "--plot-height-per-plot",
        action="store",
        type="numeric",
        default=7,
        help="Height of each row of the plotting canvas in inches. The number of rows is one plus the number of subsets. Default: %default.",
        metavar="float"
    ),
    make_option(
        "--plot-height-per-title",
        action="store",
        type="numeric",
        default=0.5,
        help="Height of each title row of the plotting canvas in inches. The number of rows is one plus the number of subsets. Default: %default.",
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
opt_parser <- OptionParser(usage=paste("Usage:", script, "[OPTIONS] --data-matrix <TSV>\n", sep=" "), option_list = option_list, add_help_option=FALSE, description=msg)
opt <- parse_args(opt_parser)

# Re-assign variables
dat <- opt[["data-matrix"]]
out.dir <- opt[["output-directory"]]
run.id <- opt[["run-id"]]
excl <- opt[["exclude"]]
name.prefix <- opt[["column-short-name-prefix"]]
name.suffix <- opt[["column-short-name-suffix"]]
subset.dir <- opt[["subset-directory"]]
subset.glob <- opt[["subset-glob"]]
subset.anno <- opt[["subset-annotation"]]
min.feat.per.set <- opt[["minimum-number-of-values-per-set"]]
avoid.ties.approx.p <- opt[["do-not-calculate-exact-ks-p-values"]]
avoid.ties.add.pos <- opt[["add-only-positive-values-to-avoid-data-ties"]]
avoid.ties.power <- opt[["power-of-values-added-to-avoid-ties"]]
xlab <- opt[["plot-x-label"]]
vbar <- opt[["plot-vertical-bar"]]
cdf.median <- opt[["plot-cdf-median-line"]]
do.points <- opt[["plot-cdf-points"]]
do.points.subsets <- opt[["plot-cdf-points-subsets"]]
plot.width <- opt[["plot-width"]]
height.per.plot <- opt[["plot-height-per-plot"]]
height.per.title <- opt[["plot-height-per-title"]]
verb <- opt[["verbose"]]

# Validate required arguments
if ( is.null(dat) ) {
        print_help(opt_parser)
        stop("[ERROR] Required argument missing! Aborted.")
}

# Set dependent options
incl.subset <- if ( is.null(subset.dir) ) FALSE else TRUE


###################
###  FUNCTIONS  ###
###################

# Get wildcard matched strings
get.wildcard.matches <- function(glob, paths) {

    # Split glob by asterisks and stretches of question marks
    frags <- unlist(strsplit(glob, "\\*|\\?+"))

    # Remove empty strings from fragments
    frags <- frags[frags != ""]

    # Return NULL if more than 2 fragments result
    if ( length(frags) > 2 ) return(NULL)

    # Iterate over paths...
    matched <- sapply(paths, function(path) {

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

# Import subset-related files
get.subset.data <- function(
    dir = getwd(),
    glob = "*",
    annotation = NULL
) {

    # Initialize data container
    results <- list()

    # Get file paths
    results$paths <- sort(dir(dir, pattern=glob2rx(glob), recursive=FALSE, full.names=TRUE))

    # Load data
    results$dat <- lapply(results$paths, readLines) 

    # Get wildcard matched strings & return NULL if no matches were found
    names(results$dat) <- get.wildcard.matches(glob, basename(results$paths))

    # Import subset annotation, if available
    if ( ! is.null(annotation) ) results$anno <- read.delim(annotation, header=FALSE, stringsAsFactors=FALSE, colClasses=rep("character", 2), col.names=c("id", "description"))

    # Return results or, in case of error, NULL
    if ( ! length(results$path) || is.null(names(results$dat)) ) return(NULL) else return(results)

}

# Plot distributions
plot.dist <- function(
    dat = NULL,
    subset.data = NULL,
    subset.anno = NULL,
    title = NULL,
    out.dir = getwd(),
    prefix = "dist",
    suffix = "svg",
    sep = ".",
    min.feat.per.set = 2,
    avoid.ties = TRUE,
    add.positive.values.only = FALSE,
    power.of.added.values = -6,
    xlab = "Log2 fold change",
    vertical.bar = NULL,
    cdf.median = TRUE,
    do.points = FALSE,
    do.points.subsets = TRUE,
    width = 21,
    height.per.plot = 7,
    height.per.title = 0.5
) {

    # Set dependent parameters
    if ( do.points ) do.points.subset <- TRUE

    # Return NULL if data is missing
    if ( is.null(dat) || length(dat) < min.feat.per.set ) return(NULL)

    # Remove ties in data
    min.limit <- if ( add.positive.values.only ) 0 else -1
    if ( avoid.ties ) dat <- dat + runif(length(dat), min.limit, 1) * 10^power.of.added.values
    p.exact <- if ( avoid.ties ) TRUE else FALSE

    # Calculate absolutes, density & cumulative distribution functions
    cdf <- ecdf(dat)
    abs <- abs(dat)
    cdf.abs <- ecdf(abs)
    dens <- density(dat, from=-max(abs), to=max(abs))

    # Calculate absolutes, density & cumulative distribution functions for subsets
    if ( ! is.null(subset.data) ) {

        # Iterate over subsets
        subsets <- lapply(names(subset.data), function(name) {

            # Initialize results container
            ls <- list()

            # Subset data
            ls$dat.pop <- dat[! names(dat) %in% subset.data[[name]]]
            ls$dat.smp <- dat[names(dat) %in% subset.data[[name]]]

            # Test whether enough data points are in subset & remaining features
            if ( length(ls$dat.smp) >= min.feat.per.set && length(ls$dat.pop) >= min.feat.per.set ) {

                # Calculate absolutes, densities & cumulative distribution functions
                ls$cdf.pop <- ecdf(ls$dat.pop)
                ls$cdf.smp <- ecdf(ls$dat.smp)
                ls$abs.pop <- abs(ls$dat.pop)
                ls$abs.smp <- abs(ls$dat.smp)
                ls$cdf.pop.abs <- ecdf(ls$abs.pop)
                ls$cdf.smp.abs <- ecdf(ls$abs.smp)
                ls$dens.pop <- density(ls$dat.pop, from=min(dens$x), to=max(dens$x))
                ls$dens.smp <- density(ls$dat.smp, from=min(dens$x), to=max(dens$x))

                # Calculate statistics (KS test, standard score)
                ls$ks <- ks.test(ls$dat.pop, ls$dat.smp, exact=p.exact)
                ls$ks.d <- ls$ks$statistic
                ls$ks.p <- ls$ks$p.value
                ls$ks.abs <- ks.test(ls$abs.pop, ls$abs.smp, exact=p.exact)
                ls$ks.abs.d <- ls$ks.abs$statistic
                ls$ks.abs.p <- ls$ks.abs$p.value
                ls$z <- (mean(ls$dat.pop) - mean(ls$dat.smp)) / sqrt( sd(ls$dat.pop)^2 / length(ls$dat.pop) + sd(ls$dat.smp)^2 / length(ls$dat.smp) )
                ls$z.p <- 2 * pnorm(-abs(ls$z))

                # Get subset description
                ls$desc <- if ( ! is.null(subset.anno) ) subset.anno[["description"]][match(name, subset.anno[["id"]])] else subset

                # Generate safe description for use in filenames
                ls$desc.safe <- gsub("_+", "_", gsub(":", "_", gsub("_*\\((.*)\\)", ".\\1", gsub(",", "", gsub(" ", "_", ls$desc)))))

                # Return results container
                return(ls)

            # ...else return NULL
            } else return(NULL)

        })

        # Set names for subsets
        names(subsets) <- names(subset.data)

        # Remove subsets that do not have enough data per set
        subsets <- subsets[! sapply(subsets, is.null)]

    # Set list of subsets to NULL if not subsets available
    } else subsets <- NULL

    # Build output filename
    out.file <- file.path(out.dir, paste(prefix, suffix, sep=sep))

    # Calculate total plot height
    height <- (height.per.title + height.per.plot) * (length(subsets) + 1)

    # Open graphics device
    svg(out.file, width=width, height=height)

    # Set plot margins
    mar.title <- c(0, 0, 0, 0)
    mar.plot <- par("mar")
    mar.plot[3] <- 0

    # Set layout grid
    plots.per.row <- 3
    order.titles <- lapply(seq(from=1, by=plots.per.row + 1, length.out=length(subsets) + 1), rep, plots.per.row)
    order.plots <- lapply(seq(from=2, by=plots.per.row + 1, length.out=length(subsets) + 1), seq, length.out=plots.per.row)
    order.all <- unlist(mapply(function(t, p) {
        return(c(t, p))
    }, order.titles, order.plots, SIMPLIFY=FALSE))
    layout(matrix(order.all, ncol=plots.per.row, byrow=TRUE), heights=rep(c(height.per.title, height.per.plot), length(subsets) + 1))

    # Plot title
    par(mar=mar.title)
    plot.new()
    if ( ! is.null(title) ) text(0.5, 0.5, title, cex=1.5, font=2)

    # Plot cumulative distribution
    par(mar=mar.plot)
    plot(cdf, main="", xlab=xlab, ylab="Cumulative fraction", do.points=do.points)
    if ( ! is.null(vertical.bar) ) abline(v=vertical.bar, lty=2)
    if ( cdf.median ) abline(h=0.5, lty=2)

    # Plot cumulative distribution (absolute values)
    par(mar=mar.plot)
    plot(cdf.abs, main=NULL, xlab=xlab, ylab="Cumulative fraction", do.points=do.points)
    if ( ! is.null(vertical.bar) && vertical.bar > 0 ) abline(v=vertical.bar, lty=2)
    if ( cdf.median ) abline(h=0.5, lty=2)

    # Plot density
    par(mar=mar.plot)
    plot(dens, main="", xlab=xlab, ylab="Density")
    if ( ! is.null(vertical.bar) ) abline(v=vertical.bar, lty=2)

    # Plot subset / population comparisons
    if ( ! is.null(subset.data) ) {

        # Iterate over subsets
        for ( subset in subsets ) {

            # Get title
            title.subset <- if ( ! is.null(title) ) paste(title, paste(subset$desc, "versus remaining", sep=" "), sep=": ") else subset$desc

            # Plot title
            par(mar=mar.title)
            plot.new()
            text(0.5, 0.5, title.subset, cex=1.5, font=2)
            par(mar=mar.plot)

            # Plot cumulative distribution
            plot(subset$cdf.pop, main="", xlab=xlab, ylab="Cumulative fraction", do.points=do.points)
            plot(subset$cdf.smp, do.points=do.points.subsets, col=2, pch=20, cex=0.75, add=TRUE)
            ks.d <- paste("D", signif(subset$ks.d, digits=3), sep=" = ")
            ks.p <- paste("P", signif(subset$ks.p, digits=3), sep=" = ")
            legend <- c("Kolmogorov-Smirnov test", ks.d, ks.p)
            legend("topleft", inset=c(0, 0.05), legend=legend, bty="n")
            legend("bottomright", inset=c(0.02, 0.05), legend=c(subset$desc, "remaining"), col=c(2, 1), lty=1, bty="n")
            if ( ! is.null(vertical.bar) ) abline(v=vertical.bar, lty=2)
            if ( cdf.median ) abline(h=0.5, lty=2)

            # Plot cumulative distribution (absolute values)
            plot(subset$cdf.pop.abs, main="", xlab=xlab, ylab="Cumulative fraction", do.points=do.points)
            plot(subset$cdf.smp.abs, do.points=do.points.subsets, col=2, pch=20, cex=0.75, add=TRUE)
            ks.d <- paste("D", signif(subset$ks.abs.d, digits=3), sep=" = ")
            ks.p <- paste("P", signif(subset$ks.abs.p, digits=3), sep=" = ")
            legend <- c("Kolmogorov-Smirnov test", ks.d, ks.p)
            legend("topright", inset=c(0.02, 0.05), legend=legend, bty="n")
            legend("bottomright", inset=c(0.02, 0.05), legend=c(subset$desc, "remaining"), col=c(2, 1), lty=1, bty="n")
            if ( ! is.null(vertical.bar) && vertical.bar > 0 ) abline(v=vertical.bar, lty=2)
            if ( cdf.median ) abline(h=0.5, lty=2)

            # Plot density
            ylim <- c(0, max(subset$dens.pop$y, subset$dens.smp$y) * 1.2)
            plot(subset$dens.pop, main="", xlab=xlab, ylab="Density", ylim=ylim)
            lines(subset$dens.smp, col=2)
            z <- paste("Z", signif(subset$z, digits=3), sep=" = ")
            z.p <- paste("P", signif(subset$z.p, digits=3), sep=" = ")
            legend <- c("Standard score", z, z.p)
            legend("topleft", inset=c(0, 0.02), legend=legend, bty="n")
            legend("topright", inset=c(0.02, 0.02), legend=c(subset$desc, "remaining"), col=c(2, 1), lty=1, bty="n")
            if ( ! is.null(vertical.bar) ) abline(v=vertical.bar, lty=2)

        }

    }

    # Close graphics device
    invisible(dev.off())

    # Return subset statistics
    return(subsets)

}


##############
###  MAIN  ###
##############

# Write log
if ( verb ) cat("Creating output directory...\n", sep="")

# Create output directories
dir.create(out.dir, recursive=TRUE, showWarnings=FALSE)

# Write log
if ( verb ) cat("Importing data...\n", sep="")

# Import sample data
dat <- read.delim(dat, stringsAsFactors=FALSE, row.names=1)

# Import subset-related files & die 
if ( incl.subset ) {
    subsets <- get.subset.data(dir=subset.dir, glob=subset.glob, annotation=subset.anno)
    if ( is.null(subsets) ) {
            print_help(opt_parser)
            stop("[ERROR] No subset files found or illegal value for option '--subset-glob' supplied! Aborted.")
    }
} else {
    subsets <- list()
    subsets$dat <- NULL
    subsets$anno <- NULL
}

# Import exclude list
if ( ! is.null(excl) ) excl <- readLines(excl)

# Write log
if ( verb ) cat("Processing data...\n", sep="")

# Filter data for samples to be excluded
if ( ! is.null(excl) ) expr <- expr[, ! colnames(expr) %in% excl]

# Replace column names with short names
colnames(dat) <- sub(name.suffix, "", sub(name.prefix, "", colnames(dat)))

# Write log
if ( verb ) cat("Plotting distributions...\n", sep="'")

# Iterate over data columns
all.results <- lapply(colnames(dat), function(name) {

    # Get pretty name
    name.pretty <- gsub("[._]", " ", name, perl=TRUE)

    # Write log
    if ( verb ) cat("Plotting distributions for column ", name.pretty, "...\n", sep="'")

    # Extract data
    col.dat <- setNames(dat[[name]], rownames(dat))

    # Plot distribution
    results <- plot.dist(
        dat = col.dat,
        subset.data = subsets$dat,
        subset.anno = subsets$anno,
        title = name.pretty,
        out.dir = out.dir,
        prefix = paste(run.id, name, sep="."),
        min.feat.per.set = min.feat.per.set,
        avoid.ties = ! avoid.ties.approx.p,
        add.positive.values.only = avoid.ties.add.pos,
        power.of.added.values = avoid.ties.power,
        xlab = xlab,
        vertical.bar = vbar,
        cdf.median = cdf.median,
        do.points = do.points,
        do.points.subsets = do.points.subsets,
        width = plot.width,
        height.per.plot = height.per.plot,
        height.per.title = height.per.title
    )

    # Return results
    return(results)

})

# Set names
names(all.results) <- colnames(dat)

# Remove conditions with too few data
all.results <- all.results[! sapply(all.results, is.null)]

# Extract statistics
mt.ks.d <- sapply(all.results, lapply, "[[", "ks.d")
mt.ks.p <- sapply(all.results, lapply, "[[", "ks.p")
mt.ks.abs.d <- sapply(all.results, lapply, "[[", "ks.abs.d")
mt.ks.abs.p <- sapply(all.results, lapply, "[[", "ks.abs.p")
mt.z <- sapply(all.results, lapply, "[[", "z")
mt.z.p <- sapply(all.results, lapply, "[[", "z.p")

# Build output names for statistics tables
out.file.ks.d <- file.path(out.dir, paste(run.id, "statistics", "ks", "d", "tsv", sep="."))
out.file.ks.p <- file.path(out.dir, paste(run.id, "statistics", "ks", "p_values", "tsv", sep="."))
out.file.ks.abs.d <- file.path(out.dir, paste(run.id, "statistics", "absolute_ks", "d", "tsv", sep="."))
out.file.ks.abs.p <- file.path(out.dir, paste(run.id, "statistics", "absolute_ks", "p_values", "tsv", sep="."))
out.file.z <- file.path(out.dir, paste(run.id, "statistics", "standard_score", "z", "tsv", sep="."))
out.file.z.p <- file.path(out.dir, paste(run.id, "statistics", "standard_score", "p_values", "tsv", sep="."))

# Write statistics tables
write.table(mt.ks.d, out.file.ks.d, col.names=TRUE, row.names=TRUE, quote=FALSE, sep="\t")
write.table(mt.ks.p, out.file.ks.p, col.names=TRUE, row.names=TRUE, quote=FALSE, sep="\t")
write.table(mt.ks.abs.d, out.file.ks.abs.d, col.names=TRUE, row.names=TRUE, quote=FALSE, sep="\t")
write.table(mt.ks.abs.p, out.file.ks.abs.p, col.names=TRUE, row.names=TRUE, quote=FALSE, sep="\t")
write.table(mt.z, out.file.z, col.names=TRUE, row.names=TRUE, quote=FALSE, sep="\t")
write.table(mt.z.p, out.file.z.p, col.names=TRUE, row.names=TRUE, quote=FALSE, sep="\t")

# Build output filename for R image
out.file.rimage <- file.path(out.dir, paste(run.id, "RData", sep="."))

# Write log
if ( verb ) cat("Writing R session image to file ", out.file.rimage ,"...\n", sep="'")

# Save image
save.image(out.file.rimage)

# Write log
if ( verb ) cat("Done.\n", sep="")
