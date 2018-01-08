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
description <- "Run a principal component analysis on a matrix of expression/abundance values.\n"
author <- "Author: Alexander Kanitz, Biozentrum, University of Basel"
version <- "Version: 1.0.1 (08-AUG-2017)"
requirements <- "Requires: optparse"
msg <- paste(description, author, version, requirements, sep="\n")

# Define list of arguments
option_list <- list(
    make_option(
        "--expression",
        action="store",
        type="character",
        default=NULL,
        help="Expression table containing feature/gene IDs in the first column, expression/abundance values in the remaining columns and a header line with sample IDs. The header line must contain one field less than the remaining lines (i.e. no field for the first/feature ID column). Required.",
        metavar="tsv"
    ),
    make_option(
        "--output-directory",
        action="store",
        type="character",
        default=getwd(),
        help="Directory where output files shall be written. Default: working directory.",
        metavar="directory"
    ),
    make_option(
        "--run-id",
        action="store",
        type="character",
        default="experiment",
        help="String used as analysis identifier prefix for output files. Default: 'experiment'.",
        metavar="file"
    ),
    make_option(
        "--exclude",
        action="store",
        type="character",
        default=NULL,
        help="Text file containing identifiers of samples to be excluded from the analysis. Expected format: One identifier per line. Identifiers have to match column headers of '--expression'. Default: NULL.",
        metavar="file"
    ),
    make_option(
        "--annotation",
        action="store",
        type="character",
        default=NULL,
        help="Annotation table with one row for each sample. If provided, samples without annotation are not considered. Required if '--include-means', --color-category-column' and/or '--symbol-category-column' are specified. Specify '--anno-has-header' if table includes a header line. Default: NULL.",
        metavar="tsv"
    ),
    make_option(
        "--anno-has-header",
        action="store_true",
        default=FALSE,
        help="Indicates whether the annotation table includes a header line. Default: FALSE."
    ),
    make_option(
        "--include-means",
        action="store_true",
        default=FALSE,
        help="Indicates whether the analysis shall be run on sample means as well. Default: FALSE."
    ),
    make_option(
        "--sample-id-column",
        action="store",
        type="integer",
        default=NULL,
        help="Annotation table column/field number containing sample identifiers. Required if '--annotation' is specified. Default: NULL.",
        metavar="int"
    ),
    make_option(
        "--replicate-column",
        action="store",
        type="integer",
        default=NULL,
        help="Annotation table column/field number containing sample descriptor for the calculation of sample means. Expression values of samples with identical descriptors are averaged. Required if '--include-means' is specified. Default: NULL.",
        metavar="int"
    ),
    make_option(
        "--color-category-column",
        action="store",
        type="integer",
        default=NULL,
        help="Annotation table column/field number containing categorical information for each sample that is to be plotted in distinct colors (e.g. cell type, genotype, treatment). Default: NULL (symbols in all plots will be black).",
        metavar="int"
    ),
    make_option(
        "--color-column",
        action="store",
        type="integer",
        default=NULL,
        help="Annotation table column/field number containing hexadecimal color values (e.g. '#000000'). Samples belonging to the same color category (as defined by '--color-category-column') should also have the same color value in order for the legend to match the plot colors. If NULL, colors for each category in '--color-category-column' (if provided) are assigned automatically. Default: NULL.",
        metavar="int"
    ),
    make_option(
        "--symbol-category-column",
        action="store",
        type="integer",
        default=NULL,
        help="Annotation table column/field number containing categorical information for each sample that is to be plotted in distinct symbol shapes/types (e.g. cell type, genotype, treatment). Default: NULL (symbols in all plots will be circles, i.e. pch=16).",
        metavar="int"
    ),
    make_option(
        "--symbol-column",
        action="store",
        type="integer",
        default=NULL,
        help="Annotation table column/field number containing integers represent R plot symbols (see '?pch'). Samples belonging to the same symbol category (as defined by '--symbol-category-column') should also have the same plot symbol value in order for the legend to match the plot symbols. If NULL, symbols for each category in '--symbol-category-column' (if provided) are assigned automatically. Default: NULL.",
        metavar="int"
    ),
    make_option(
        "--subset-directory",
        action="store",
        type="character",
        default=NULL,
        help="Directory containing one or more files containing subsets of feature/gene identifiers, each to be analyzed separately. Identifiers have to match those in '--expression' and have to specified one per line. Requires that a valid argument to '--subset-glob' is also provided. If not specified, separate analyses per subset are not performed. Default: NULL.",
        metavar="directory"
    ),
    make_option(
        "--subset-glob",
        action="store",
        type="character",
        default=NULL,
        help="File glob to identify subset feature/gene identifier files in '--subset-directory'. Valid values include either a single asterisk '*' or a single stretch of question marks (e.g. '???'). Values matched by the wildcard will be used as identifiers for the respective subsets. Therefore, include prefixes/suffixes that are identical to all files literally in the glob string (e.g. 'prefix.*.suffix'). Required if '--subset-directory' is specified. Default: NULL.",
        metavar="glob"
    ),
    make_option(
        "--subset-annotation",
        action="store",
        type="character",
        default=NULL,
        help="Optional annotation table for the subsets of feature/gene identifiers defined by the '--subset-directory' and '--subset-glob' options. The table should be headerless and contain the following in the first two columns: (1) the values matched by the wildcard in '--subset-glob', (2) a short descriptive name or official identifier (e.g. GO term name and/or identifier) for the subset. If provided, the descriptive name is used in plots and filenames instead of the value matched by the wildcard. Default: NULL.",
        metavar="tsv"
    ),
    make_option(
        "--cutoff-expression",
        action="store",
        type="numeric",
        default=1,
        help="Consider only features/genes with at least '--cutoff-sample-no' samples above the specified threshold. Set to 0 to disable filtering. Default: 1.",
        metavar="float"
    ),
    make_option(
        "--cutoff-negative-expression",
        action="store",
        type="numeric",
        default=NULL,
        help="Consider only features/genes with at most '--cutoff-sample-no' samples below the specified expression threshold. Disabled by default.",
        metavar="float"
    ),
    make_option(
        "--cutoff-sample-no",
        action="store",
        type="numeric",
        default=0.1,
        help="Number (integer >1) or fraction (float <1) of samples that have to have at least '--cutoff-expression' for a feature/gene to be considered. Set to 0 to disable filtering. Default: 0.1.",
        metavar="float|int"
    ),
    make_option(
        "--log-space",
        action="store_true",
        default=FALSE,
        help="Indicate if expression values are already in log space. Default: FALSE."
    ),
    make_option(
        "--pseudo-count",
        action="store",
        type="numeric",
        default=1/32,
        help="Value to be added to small/zero expression/abundance values for log transformation. Default: 1/32 (log2 = -5).",
        metavar="float"
    ),
    make_option(
        "--write-tables",
        action="store_true",
        default=FALSE,
        help="Indicates whether processed expression/abundance tables shall be written out. Default: FALSE."
    ),
    make_option(
        "--plot-components",
        action="store",
        type="integer",
        default=2,
        help="Number of components n to plot. All unique combinations C(n, 2) will be plotted in 2D scatterplots, i.e. n = 5 will generate 10 plots. Default: 2.",
        metavar="int"
    ),
    make_option(
        "--plot-width",
        action="store",
        type="integer",
        default=16,
        help="Plot width in inches. Default: 16.",
        metavar="int"
    ),
    make_option(
        "--plot-width-legend",
        action="store",
        type="integer",
        default=2,
        help="Width of plot legend in inches. Default: 2.",
        metavar="int"
    ),
    make_option(
        "--plot-height",
        action="store",
        type="numeric",
        default=7.25,
        help="Plot height in inches. Default: 7.25.",
        metavar="float"
    ),
    make_option(
        "--plot-height-title",
        action="store",
        type="numeric",
        default=0.25,
        help="Height of plot title in inches. Default: 0.25.",
        metavar="float"
    ),
    make_option(
        "--plot-symbol-expansion",
        action="store",
        type="numeric",
        default=1.8,
        help="Expansion factor for plot symbols. Default: 1.8.",
        metavar="float"
    ),
    make_option(
        "--plot-tick-label-expansion",
        action="store",
        type="numeric",
        default=1.6,
        help="Expansion factor for plot tick labels. Default: %default.",
        metavar="float"
    ),
    make_option(
        "--plot-axis-label-expansion",
        action="store",
        type="numeric",
        default=1.8,
        help="Expansion factor for plot axis labels. Default: %default.",
        metavar="float"
    ),
    make_option(
        "--plot-legend-label-expansion",
        action="store",
        type="numeric",
        default=1.6,
        help="Expansion factor for legend labels. Default: %default.",
        metavar="float"
    ),
    make_option(
        "--plot-legend-title-colors",
        action="store",
        type="character",
        default=NULL,
        help="Title for legend part explaining difference in colors (if applicable). Default: %default.",
        metavar="string"
    ),
    make_option(
        "--plot-legend-title-symbols",
        action="store",
        type="character",
        default=NULL,
        help="Title for legend part explaining difference in symbols (if applicable). Default: %default.",
        metavar="string"
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
opt_parser <- OptionParser(usage=paste("Usage:", script, "[OPTIONS] --expression <TSV>\n", sep=" "), option_list = option_list, add_help_option=FALSE, description=msg)
opt <- parse_args(opt_parser)

# Re-assign variables
expr <- opt$`expression`
out.dir <- opt$`output-directory`
run.id <- opt$`run-id`
excl <- opt$`exclude`
anno <- opt$`annotation`
anno.header <- opt$`anno-has-header`
incl.mean <- opt$`include-means`
id.col <- opt$`sample-id-column`
repl.col <- opt$`replicate-column`
col.cat.col <- opt$`color-category-column`
col.col <- opt$`color-column`
sym.cat.col <- opt$`symbol-category-column`
sym.col <- opt$`symbol-column`
subset.anno <- opt$`subset-annotation`
subset.dir <- opt$`subset-directory`
subset.glob <- opt$`subset-glob`
log.space <- opt$`log-space`
pseudo.count <- opt$`pseudo-count`
cutoff.expr <- opt$`cutoff-expression`
cutoff.neg.expr <- opt$`cutoff-negative-expression`
cutoff.samples <- opt$`cutoff-sample-no`
write.tables <- opt$`write-tables`
plot.components <- opt$`plot-components`
plot.width <- opt$`plot-width`
plot.width.legend <- opt$`plot-width-legend`
plot.height <- opt$`plot-height`
plot.height.title <- opt$`plot-height-title`
plot.sym.cex <- opt$`plot-symbol-expansion`
plot.tick.label.cex <- opt$`plot-tick-label-expansion`
plot.axis.label.cex <- opt$`plot-axis-label-expansion`
plot.legend.cex <- opt$`plot-legend-label-expansion`
plot.legend.title.col <- opt$`plot-legend-title-colors`
plot.legend.title.sym <- opt$`plot-legend-title-symbols`
verb <- opt$`verbose`

# Validate required arguments
if ( is.null(expr) ) {
        print_help(opt_parser)
        stop("[ERROR] Required argument missing! Aborted.")
}
if ( is.null(anno) && ( incl.mean || ! is.null(col.cat.col) || ! is.null(sym.cat.col) ) ) {
        print_help(opt_parser)
        stop("[ERROR] Argument '--annotation' missing! Aborted.")
}
if ( is.null(id.col) && ! is.null(anno) ) {
        print_help(opt_parser)
        stop("[ERROR] Argument '--sample-id-column' missing! Aborted.")
}
if ( is.null(repl.col) && incl.mean ) {
        print_help(opt_parser)
        stop("[ERROR] Argument '--replicate-column' missing! Aborted.")
}
if ( is.null(subset.glob) && ! is.null(subset.dir) ) {
        print_help(opt_parser)
        stop("[ERROR] Argument '--subset-glob' missing! Aborted.")
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

# Generate PCA plot
plot.pca <- function(
    pca,
    anno = NULL,
    pca.mean = NULL,
    anno.mean = NULL,
    title = NULL,
    out.dir = getwd(),
    prefix = "pca",
    suffix = "svg",
    sep = ".",
    components = 2,
    colors = FALSE,
    symbols = FALSE,
    def.col = 1,
    def.sym = 16,
    width = 18,
    width.legend = 4,
    height = 8,
    height.title = 1,
    cex.sym = 2,
    cex.axis = 1.6,
    cex.lab = 1.8,
    cex.legend = 1.6,
    legend.title.col = "Colors",
    legend.title.sym = "Symbols"
) {

    # Set legend positioning
    if ( ! is.null(pca.mean) && ! is.null(anno.mean) ) {
        incl.mean <- TRUE
        if ( colors && symbols ) {
            legend.orient.col <- "top"
            legend.orient.sym <- "bottom"
        } else {
            legend.orient.col <- legend.orient.sym <- "top"
        }
    } else {
        incl.mean <- FALSE
        if ( colors && symbols ) {
            legend.orient.col <- "topleft"
            legend.orient.sym <- "bottomleft"
        } else {
            legend.orient.col <- legend.orient.sym <- "topleft"
        }
    }

    # Set colors
    if ( colors ) {
        if ( is.null(anno[["col"]]) ) {
            col.legend <- rainbow(length(levels(as.factor(anno[["col.cat"]]))))
            col.text <- gsub("_", " ", levels(as.factor(anno[["col.cat"]])))
        } else {
            col.legend <- anno[["col"]][match(levels(as.factor(anno[["col.cat"]])), anno[["col.cat"]])]
            col.text <- levels(as.factor(anno[["col.cat"]]))
        }
        col.label <- col.legend[as.integer(as.factor(anno[["col.cat"]]))]
        if ( incl.mean ) col.label.mean <- col.legend[as.integer(as.factor(anno.mean[["col.cat"]]))]
    } else {
        col.label <- rep(def.col, ncol(dge))
        if ( incl.mean ) col.label.mean <- rep(def.col, ncol(dge.mean))
    }

    # Set plotting characters
    if ( symbols ) {
        if ( is.null(anno[["sym"]]) ) {
            pch.legend <- 1:length(levels(as.factor(anno[["sym.cat"]])))
            pch.text <- gsub("_", " ", levels(as.factor(anno[["sym.cat"]])))
        } else {
            pch.legend <- anno[["sym"]][match(levels(as.factor(anno[["sym.cat"]])), anno[["sym.cat"]])]
            pch.text <- levels(as.factor(anno[["sym.cat"]]))
        }
        pch.label <- pch.legend[as.integer(as.factor(anno[["sym.cat"]]))]
        if ( incl.mean ) pch.label.mean <- pch.legend[as.integer(as.factor(anno.mean[["sym.cat"]]))]
    } else {
        pch.label <- rep(def.sym, ncol(dge))
        if ( incl.mean ) pch.label.mean <- rep(def.sym, ncol(dge.mean))
    }

    # Generate component pairs
    comp.pairs <- combn(components, 2)

    # Iterate over component pairs
    for ( i in 1:ncol(comp.pairs) ) {

        # Set component ordinances
        pc1 <- comp.pairs[, i][1]
        pc2 <- comp.pairs[, i][2]

        # Get xy plot values
        x <- pca$x[, pc1]
        y <- pca$x[, pc2]
        if ( incl.mean ) {
            x.mean <- pca.mean$x[, pc1]
            y.mean <- pca.mean$x[, pc2]
        }

        # Get explained variances per component
        var.expl <- pca$sdev ^ 2 / sum( pca$sdev ^ 2 )
        var.expl.x <- var.expl[pc1]
        var.expl.y <- var.expl[pc2]
        if ( incl.mean ) {
            var.expl.mean <- pca.mean$sdev ^ 2 / sum( pca.mean$sdev ^ 2 )
            var.expl.mean.x <- var.expl.mean[pc1]
            var.expl.mean.y <- var.expl.mean[pc2]
        }

        # Set axes labels
        xlab <- paste("Principal component ", pc1, " (", round(var.expl.x * 100, digits=2), "% of variance explained)", sep="")
        ylab <- paste("Principal component ", pc2, " (", round(var.expl.y * 100, digits=2), "% of variance explained)", sep="")
        if ( incl.mean ) {
            xlab.mean <- paste("Principal component ", pc1, " (", round(var.expl.mean.x * 100, digits=2), "% of variance explained)", sep="")
            ylab.mean <- paste("Principal component ", pc2, " (", round(var.expl.mean.y * 100, digits=2), "% of variance explained)", sep="")
        }

        # Build output filename
        out.file <- file.path(out.dir, paste(prefix, paste("pc", pc1, sep=""), paste("pc", pc2, sep=""), suffix, sep=sep))

        # Open graphics device
        svg(out.file, width=width, height=height)

        # Set equal margins
        mar.bak <- par("mar")
        mar.plot <- c(5.1, 5.1, 5.1, 5.1)
        mar.null <- c(0, 0, 0, 0)
        mar.leg <- c(5.1, 0.1, 5.1, 0.1)

        # Set layout grid
        if ( incl.mean ) {
            width.plot <- (width - width.legend) / 2
            layout(matrix(c(rep(1, width), rep(2, width.plot), rep(3, width.legend), rep(4, width.plot)), nrow=2, byrow=TRUE), heights=c(height.title, height - height.title))
        } else {
            width.plot <- width - width.legend
            layout(matrix(c(rep(1, width), rep(2, width.plot), rep(3, width.legend)), nrow=2, byrow=TRUE), heights=c(height.title, height - height.title))
        }

        # Plot title
        par(mar=mar.null, oma=mar.null)
        plot.new()
        if ( ! is.null(title) ) text(0.5, 0.5, title, cex=1.5, font=2)

        # Plot individual samples
        main <- paste("Individual samples", sep="")
        par(mar=mar.plot)
        plot(x, y, main=main, xlab=xlab, ylab=ylab, pch=pch.label, col=col.label, cex=cex.sym, cex.axis=cex.axis, cex.lab=cex.lab)

        # Plot legends
        par(mar=mar.leg)
        plot(1, type="n", axes=FALSE, xlab="", ylab="")
        if ( colors ) legend(legend.orient.col, legend=col.text, title=legend.title.col, col=col.legend, lwd=3, bty="n", cex=cex.legend)
        if ( symbols ) legend(legend.orient.sym, legend=pch.text, title=legend.title.sym, pch=pch.legend, col=def.col, bty="n", cex=cex.legend)

        # Plot means
        if ( incl.mean ) {
            main.mean <- paste("Sample means", sep="")
            par(mar=mar.plot)
            plot(x.mean, y.mean, main=main.mean, xlab=xlab.mean, ylab=ylab.mean, pch=pch.label.mean, col=col.label.mean, cex=cex.sym, cex.axis=cex.axis, cex.lab=cex.lab)
        }

        # Close graphics device
        invisible(dev.off())

    }

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
expr <- read.delim(expr, stringsAsFactors=FALSE, row.names=1)

# Import sample annotations & exclude list
if ( ! is.null(anno) ) {
    anno <- read.delim(anno, stringsAsFactors=FALSE)
    if ( ncol(anno) < max(id.col, repl.col, col.cat.col, col.col, sym.cat.col, sym.col) ) {
        print_help(opt_parser)
        stop("[ERROR] Annotation table misses required columns! Aborted.")
    }
    colnames(anno)[id.col] <- "id"
    if ( ! is.null(repl.col) ) colnames(anno)[repl.col] <- "group"
    if ( ! is.null(col.cat.col) ) colnames(anno)[col.cat.col] <- "col.cat"
    if ( ! is.null(col.col) ) colnames(anno)[col.col] <- "col"
    if ( ! is.null(sym.cat.col) ) colnames(anno)[sym.cat.col] <- "sym.cat"
    if ( ! is.null(sym.col) ) colnames(anno)[sym.col] <- "sym"
}
if ( ! is.null(excl) ) excl <- readLines(excl)

# Import subset-related files
if ( incl.subset ) {

    # Import feature/gene identifiers associated with subsets
    subset.paths <- sort(dir(subset.dir, pattern=glob2rx(subset.glob), recursive=FALSE, full.names=TRUE))
    subset.used <- get.wildcard.matches(subset.glob, basename(subset.paths))
    if ( is.null(subset.used) ) {
        print_help(opt_parser)
        stop("[ERROR] Illegal value provided for '--subset-glob'! Aborted.")
    }
    subset.dat <- lapply(subset.paths, scan, "", quiet=TRUE)
    names(subset.dat) <- subset.used

    # Import subset annotation
    if ( ! is.null(subset.anno) ) subset.anno <- read.delim(subset.anno, header=FALSE, stringsAsFactors=FALSE, colClasses=rep("character", 2), col.names=c("id", "description"))

}

# Write log
if ( verb ) cat("Processing data...\n", sep="")

# Filter data without annotations
if ( ! is.null(anno) ) expr <- expr[, colnames(expr) %in% anno[["id"]]]

# Filter data for samples to be excluded
if ( ! is.null(excl) ) expr <- expr[, ! colnames(expr) %in% excl]

# Filter annotations without data
if ( ! is.null(anno) ) anno <- anno[anno[["id"]] %in% colnames(expr), ]

# Enforce correct ordering of annotations
if ( ! is.null(anno) ) anno <- anno[match(anno[["id"]], colnames(expr)),]

# Filter features by minimum/maximum expression
if ( cutoff.samples > 0 & cutoff.samples <= 1 ) cutoff.samples <- floor(ncol(expr) * cutoff.samples)
if ( cutoff.expr > 0 & cutoff.samples > 0 ) {
    expr <- expr[rowSums(expr > cutoff.expr) >= cutoff.samples, , drop=FALSE]
}
if ( ! is.null(cutoff.neg.expr) & cutoff.samples > 0 ) {
    expr <- expr[rowSums(expr < cutoff.neg.expr) > cutoff.samples, , drop=FALSE]
}

# Transform expression data to log space
if ( ! log.space ) expr <- log2(expr + pseudo.count)

# Calculate replicate means
if ( incl.mean ) {
    mean.groups <- aggregate(anno[["id"]] ~ anno[["group"]], anno, c)
    mean.expr <- sapply(mean.groups[, 2], function(group.members) {
        rowMeans(expr[, group.members, drop=FALSE])
    })
    colnames(mean.expr) <- mean.groups[, 1]
    mean.anno <- unique(anno[ , na.omit(match(c("group", "col.cat", "sym.cat"), colnames(anno))), drop=FALSE])
    mean.anno <- mean.anno[match(colnames(mean.expr), mean.anno[["group"]]), ]
} else {
    pca.mean.expr <- NULL
    mean.anno <- NULL
}

# Shift mean expression values per row and column to 0
expr.shift <- apply(expr, 2, scale, scale=FALSE, center=TRUE)
expr.shift <- t(apply(expr.shift, 1, scale, scale=FALSE, center=TRUE))
dimnames(expr.shift) <- dimnames(expr)
if ( incl.mean ) {
    mean.expr.shift <- apply(mean.expr, 2, scale, scale=FALSE, center=TRUE)
    mean.expr.shift <- t(apply(mean.expr.shift, 1, scale, scale=FALSE, center=TRUE))
    dimnames(mean.expr.shift) <- dimnames(mean.expr)
}

# Write tables
if ( write.tables ) {

    # Write log
    if ( verb ) cat("Writing out processed/transformed and zero-shifted expression/abundance tables...\n", sep="")

    # Write out processed and shifted expression/abundance tables
    out.file.expr <- file.path(out.dir, paste(run.id, "expression", "log_transformed", "tsv", sep="."))
    out.file.expr.shift <- file.path(out.dir, paste(run.id, "expression", "log_transformed", "zero_centered", "tsv", sep="."))
    write.table(expr, out.file.expr, row.names=TRUE, col.names=TRUE, quote=FALSE, sep="\t")
    write.table(expr.shift, out.file.expr.shift, row.names=TRUE, col.names=TRUE, quote=FALSE, sep="\t")
    if ( incl.mean ) {
        out.file.mean.expr <- file.path(out.dir, paste(run.id, "expression_mean", "log_transformed", "tsv", sep="."))
        out.file.mean.expr.shift <- file.path(out.dir, paste(run.id, "expression_mean", "log_transformed", "zero_centered", "tsv", sep="."))
        write.table(mean.expr, out.file.mean.expr, row.names=TRUE, col.names=TRUE, quote=FALSE, sep="\t")
        write.table(mean.expr.shift, out.file.mean.expr.shift, row.names=TRUE, col.names=TRUE, quote=FALSE, sep="\t")
    }

}

# Check if enough data is available
if ( min(ncol(expr.shift), nrow(expr.shift)) >= plot.components ) {

    # Write log
    if ( verb ) cat("Running principal component analysis...\n", sep="")

    # Run PCA
    pca.expr <- prcomp(t(expr.shift), center=FALSE, scale=FALSE)
    if ( incl.mean && min(ncol(mean.expr.shift), nrow(mean.expr.shift)) >= plot.components ) {
        pca.mean.expr <- prcomp(t(mean.expr.shift), center=FALSE, scale=FALSE)
    } else {
        pca.mean.expr <- NULL
        mean.anno <- NULL
        if ( verb && incl.mean ) cat("[WARNING] Not enough data to perform analysis of sample means. Skipped.\n")
    }

    # Write log
    if ( verb ) cat("Generating PCA plot...\n", sep="")

    # Generate multidimensional scaling plots: all genes
    plot.pca(
        pca              = pca.expr,
        anno             = anno,
        pca.mean         = pca.mean.expr,
        anno.mean        = mean.anno,
        title            = NULL,
        out.dir          = out.dir,
        prefix           = paste(run.id, sep="."),
        components       = plot.components,
        colors           = ! is.null(col.cat.col),
        symbols          = ! is.null(sym.cat.col),
        width            = plot.width,
        width.legend     = plot.width.legend,
        height           = plot.height,
        height.title     = plot.height.title,
        cex.sym          = plot.sym.cex,
        cex.axis         = plot.tick.label.cex,
        cex.lab          = plot.axis.label.cex,
        cex.legend       = plot.legend.cex,
        legend.title.col = plot.legend.title.col,
        legend.title.sym = plot.legend.title.sym
    )

} else {

    # Issue warning
    if ( verb ) cat("[WARNING] Not enough data to perform analysis. Skipped.\n")

}

# Run PCAs for each subset
if ( incl.subset ) {

    # Write log
    if ( verb ) cat("Processing subsets...\n", sep="'")

    # Create output directory
    out.dir.subset <- file.path(out.dir, "subsets")
    dir.create(out.dir.subset, showWarnings=FALSE)

    # Iterate over subsets
    for ( subset in subset.used ) {

        # Get subset description
        subset.desc <- if ( ! is.null(subset.anno) ) subset.anno[["description"]][match(subset, subset.anno[["id"]])] else subset
        subset.desc.safe <- gsub("_+", "_", gsub(":", "_", gsub("_*\\((.*)\\)", ".\\1", gsub(",", "", gsub(" ", "_", subset.desc)))))

        # Write log
        if ( verb ) cat("Applying subset ", subset.desc ,"...\n", sep="'")

        # Filter features/genes
        expr.shift.filt <- expr.shift[rownames(expr.shift) %in% subset.dat[[subset]], , drop=FALSE]
        if ( incl.mean ) mean.expr.shift.filt <- mean.expr.shift[rownames(mean.expr.shift) %in% subset.dat[[subset]], , drop=FALSE]

        # Check if enough data is available
        if ( min(ncol(expr.shift.filt), nrow(expr.shift.filt)) >= plot.components ) {

            # Write log
            if ( verb ) cat("Running principal component analysis...\n", sep="")

            # Run PCA
            pca.expr.filt <- prcomp(t(expr.shift.filt), center=FALSE, scale=FALSE)
            if ( incl.mean && min(ncol(mean.expr.shift.filt), nrow(mean.expr.shift.filt)) >= plot.components ) {
                pca.mean.expr.filt <- prcomp(t(mean.expr.shift.filt), center=FALSE, scale=FALSE)
            } else {
                pca.mean.expr.filt <- NULL
                if ( verb && incl.mean ) cat("[WARNING] Not enough data to perform analysis of sample means. Skipped.\n")
            }

            # Write log
            if ( verb ) cat("Generating PCA plot...\n", sep="")

            # Set title
            title <- paste(subset.desc, sep="")

            # Generate multidimensional scaling plot: subsets
            plot.pca(
                pca              = pca.expr.filt,
                anno             = anno,
                pca.mean         = pca.mean.expr.filt,
                anno.mean        = mean.anno,
                title            = title,
                out.dir          = out.dir.subset,
                prefix           = paste(run.id, subset.desc.safe, sep="."),
                components       = plot.components,
                colors           = ! is.null(col.cat.col),
                symbols          = ! is.null(sym.cat.col),
                width            = plot.width,
                width.legend     = plot.width.legend,
                height           = plot.height,
                height.title     = plot.height.title,
                cex.sym          = plot.sym.cex,
                cex.axis         = plot.tick.label.cex,
                cex.lab          = plot.axis.label.cex,
                cex.legend       = plot.legend.cex,
                legend.title.col = plot.legend.title.col,
                legend.title.sym = plot.legend.title.sym
            )

        } else {

            # Issue warning
            if ( verb ) cat("[WARNING] Not enough data to perform analysis. Skipped.\n")

        }

    }

}

# Build output filename for R image
out.file.rimage <- file.path(out.dir, paste(run.id, "RData", sep="."))

# Write log
if ( verb ) cat("Writing R session image to file ", out.file.rimage ,"...\n", sep="'")

# Save image
save.image(out.file.rimage)

# Write log
if ( verb ) cat("Done.\n", sep="")
