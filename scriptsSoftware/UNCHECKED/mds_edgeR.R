#!/usr/bin/env Rscript

# (c) 2017 Alexander Kanitz, Biozentrum, University of Basel
# (@) alexander.kanitz@unibas.ch


#################
###  IMPORTS  ###
#################

# Import required packages
if ( suppressWarnings(suppressPackageStartupMessages(require("optparse"))) == FALSE ) { stop("[ERROR] Package 'optparse' required! Aborted.") }
if ( suppressWarnings(suppressPackageStartupMessages(require("edgeR"))) == FALSE ) { stop("[ERROR] Package 'edgeR' required! Aborted.") }


#######################
###  PARSE OPTIONS  ###
#######################

# Get script name
script <- sub("--file=", "", basename(commandArgs(trailingOnly=FALSE)[4]))

# Build description message
description <- "Generate multidimensional scaling plots with edgeR.\n"
author <- "Author: Alexander Kanitz, Biozentrum, University of Basel"
version <- "Version: 1.0.0 (11-JAN-2017)"
requirements <- "Requires: edgeR, optparse"
msg <- paste(description, author, version, requirements, sep="\n")

# Define list of arguments
option_list <- list(
    make_option(
        "--count-table",
        action="store",
        type="character",
        default=NULL,
        help="Count table containing feature/gene IDs in the first column, sequencing read counts in the remaining columns and a header line with sample IDs. The header line must contain one field less than the remaining lines (i.e. no field for the first/feature ID column). Required.",
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
        help="Text file containing identifiers of samples to be excluded from the analysis. Expected format: One identifier per line. Identifiers have to match column headers of '--count-table'. Default: NULL.",
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
        help="Annotation table column/field number containing sample descriptor for the calculation of sample means. Read counts of samples with identical descriptors are averaged. Required if '--include-means' is specified. Default: NULL.",
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
        help="Directory containing one or more files containing subsets of feature/gene identifiers, each to be analyzed separately. Identifiers have to match those in '--count-table' and have to specified one per line. Requires that a valid argument to '--subset-glob' is also provided. If not specified, separate analyses per subset are not performed. Default: NULL.",
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
        "--cutoff-counts",
        action="store",
        type="numeric",
        default=1,
        help="Consider only features/genes with the specified minimum read count across at least '--cutoff-sample-no'. Set to 0 to disable filtering. Default: 1.",
        metavar="float"
    ),
    make_option(
        "--cutoff-sample-no",
        action="store",
        type="numeric",
        default=0.1,
        help="Number (integer >1) or fraction (float <1) of samples that have to have at least '--cutoff-counts' for a feature/gene to be considered. Set to 0 to disable filtering. Default: 0.1.",
        metavar="float|int"
    ),
    make_option(
        "--write-tables",
        action="store_true",
        default=FALSE,
        help="Indicates whether processed count tables shall be written out. Default: FALSE."
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
        "--feature-number",
        action="store",
        type="numeric",
        default=500,
        help="Number (integer >1) or fraction (float <1) of genes/features to consider for generating the MDS plots. Default: 500.",
        metavar="float|int"
    ),
    make_option(
        "--subset-feature-number",
        action="store",
        type="numeric",
        default=0.1,
        help="Number (integer >1) or fraction (float <1) of genes/features to consider for generating MDS plots per subset. Default: 0.1.",
        metavar="float|int"
    ),
    make_option(
        "--pairwise",
        action="store_true",
        default=FALSE,
        help="Compare samples in a pairwise manner. By default, samples are compared via the common top features (see 'edgeR' manual). Default: FALSE."
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
opt_parser <- OptionParser(usage=paste("Usage:", script, "[OPTIONS] --count-table <TSV>\n", sep=" "), option_list = option_list, add_help_option=FALSE, description=msg)
opt <- parse_args(opt_parser)

# Re-assign variables
cnts <- opt$`count-table`
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
cutoff.counts <- opt$`cutoff-counts`
cutoff.samples <- opt$`cutoff-sample-no`
write.tables <- opt$`write-tables`
plot.components <- opt$`plot-components`
plot.feat.no <- opt$`feature-number`
plot.feat.no.subsets <- opt$`subset-feature-number`
plot.pairwise <- opt$`pairwise`
plot.width <- opt$`plot-width`
plot.width.legend <- opt$`plot-width-legend`
plot.height <- opt$`plot-height`
plot.height.title <- opt$`plot-height-title`
plot.sym.cex <- opt$`plot-symbol-expansion`
verb <- opt$`verbose`

# Validate required arguments
if ( is.null(cnts) ) {
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

# Generate MDS plot
plot.mds <- function(
    dge,
    anno = NULL,
    dge.mean = NULL,
    anno.mean = NULL,
    title = NULL,
    out.dir = getwd(),
    prefix = "mds",
    suffix = "svg",
    sep = ".",
    top = 500,
    pairwise = FALSE,
    colors = FALSE,
    symbols = FALSE,
    def.col = 1,
    def.sym = 16,
    width = 18,
    width.legend = 4,
    height = 8,
    height.title = 1,
    cex.sym = 2
) {

    # Set gene selection
    gene.selection <- if ( pairwise ) "pairwise" else "common"

    # Set legend positioning
    if ( ! is.null(dge.mean) && ! is.null(anno.mean) ) {
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

    # Set number of genes by fraction
    if (top <= 1) {
        top.all <- ceiling(top * nrow(dge))
        if ( incl.mean ) top.mean <- ceiling(top * nrow(dge.mean))
    } else {
        top.all <- top.mean <- top
    }

    # Build output filename
    out.file <- file.path(out.dir, paste(prefix, suffix, sep=sep))

    # Open graphics device
    svg(out.file, width=width, height=height)

    # Get default margins
    mar <- mar.bak <- par("mar")

    # Set layout grid
    if ( incl.mean ) {
        width.plot <- (width - width.legend) / 2
        layout(matrix(c(rep(1, width), rep(2, width.plot), rep(3, width.legend), rep(4, width.plot)), nrow=2, byrow=TRUE), heights=c(height.title, height - height.title))
    } else {
        width.plot <- width - width.legend
        layout(matrix(c(rep(1, width), rep(2, width.plot), rep(3, width.legend)), nrow=2, byrow=TRUE), heights=c(height.title, height - height.title))
    }

    # Plot title
    par(mar=c(0, 0, 0, 0), oma=c(0, 0, 0, 0))
    plot.new()
    if ( ! is.null(title) ) text(0.5, 0.5, title, cex=1.5, font=2)

    # Plot individual samples
    mar[4] <- 0.1
    main <- paste("Individual samples; n = ", top.all, "; gene selection: '", gene.selection, "'", sep="")
    par(mar=mar)
    plotMDS(dge, main=main, pch=pch.label, col=col.label, top=top.all, gene.selection=gene.selection, cex=cex.sym)

    # Plot legends
    mar[2] <- 0.1
    par(mar=mar)
    plot(1, type="n", axes=FALSE, xlab="", ylab="")
    if ( colors ) legend(legend.orient.col, legend=col.text, col=col.legend, lwd=3, bty="n")
    if ( symbols ) legend(legend.orient.sym, legend=pch.text, pch=pch.legend, col=def.col, bty="n")

    # Plot means
    if ( incl.mean ) {
        mar[2] <- mar.bak[2]
        mar[4] <- mar.bak[4]
        main.mean <- paste("Sample means; n = ", top.mean, "; gene selection: '", gene.selection, "'", sep="")
        par(mar=mar)
        plotMDS(dge.mean, main=main.mean, pch=pch.label.mean, col=col.label.mean, top=top.mean, gene.selection=gene.selection, cex=cex.sym)
    }

    # Close graphics device
    invisible(dev.off())

}


##############
###  MAIN  ###
##############

# Write log
if ( verb ) cat("Creating output directory...\n")

# Create output directories
dir.create(out.dir, recursive=TRUE, showWarnings=FALSE)

# Write log
if ( verb ) cat("Importing data...\n")

# Import sample data
cnts <- read.delim(cnts, stringsAsFactors=FALSE, row.names=1)

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
    names(subset.dat) <- sapply(strsplit(basename(subset.paths), ".", fixed=TRUE), "[[", 2)

    # Import subset annotation
    if ( ! is.null(subset.anno) ) subset.anno <- read.delim(subset.anno, header=FALSE, stringsAsFactors=FALSE, colClasses=rep("character", 2), col.names=c("id", "description"))

}

# Write log
if ( verb ) cat("Processing data...\n", sep="")

# Filter data without annotations
if ( ! is.null(anno) ) cnts <- cnts[, colnames(cnts) %in% anno[["id"]]]

# Filter data for samples to be excluded
if ( ! is.null(excl) ) cnts <- cnts[, ! colnames(cnts) %in% excl]

# Filter annotations without data
if ( ! is.null(anno) ) anno <- anno[anno[["id"]] %in% colnames(cnts), ]

# Enforce correct ordering of annotations
if ( ! is.null(anno) ) anno <- anno[match(anno[["id"]], colnames(cnts)),]

# Filter features that are expressed (expression value > x) in at least n samples
if ( cutoff.counts > 0 | cutoff.samples > 0 ) {
    if ( cutoff.samples <= 1 ) cutoff.samples <- floor(ncol(cnts) * cutoff.samples)
    cnts <- cnts[rowSums(cnts > cutoff.counts) >= cutoff.samples, , drop=FALSE]
}

# Calculate replicate means
if ( incl.mean ) {
    mean.groups <- aggregate(anno[["id"]] ~ anno[["group"]], anno, c)
    mean.cnts <- sapply(mean.groups[, 2], function(group.members) {
        rowMeans(cnts[, group.members, drop=FALSE])
    })
    colnames(mean.cnts) <- mean.groups[, 1]
    mean.anno <- unique(anno[, na.omit(match(c("group", "col.cat", "sym.cat"), colnames(anno))), drop=FALSE])
    mean.anno <- mean.anno[match(colnames(mean.cnts), mean.anno[["group"]]), ]
} else {
    dge.mean.cnts <- NULL
    mean.anno <- NULL
}

# Write tables
if ( write.tables ) {

    # Write log
    if ( verb ) cat("Writing out processed count tables...\n", sep="")

    # Write out processed count tables
    out.file.cnts <- file.path(out.dir, paste(run.id, "processed_counts", "tsv", sep="."))
    write.table(cnts, out.file.cnts, row.names=TRUE, col.names=TRUE, quote=FALSE, sep="\t")
    if ( incl.mean ) {
        out.file.mean.cnts <- file.path(out.dir, paste(run.id, "processed_counts_mean", "tsv", sep="."))
        write.table(mean.cnts, out.file.mean.cnts, row.names=TRUE, col.names=TRUE, quote=FALSE, sep="\t")
    }

}

# Check if enough data is available
if ( nrow(cnts) > 1 && ncol(cnts) > 1 ) {

    # Create DGEList objects
    dge.cnts <- DGEList(counts=cnts)
    if ( incl.mean && nrow(mean.cnts) > 1 && ncol(mean.cnts) > 1 ) {
        dge.mean.cnts <- DGEList(counts=mean.cnts)
    } else {
        dge.mean.cnts <- NULL
        if ( verb && incl.mean ) cat("[WARNING] Not enough data to perform analysis of sample means. Skipped.\n")
    }

    # Write log
    if ( verb ) cat("Generating MDS plot...\n", sep="")

    # Generate multidimensional scaling plots: all genes
    plot.mds(
        dge          = dge.cnts,
        anno         = anno,
        dge.mean     = dge.mean.cnts,
        anno.mean    = mean.anno,
        title        = NULL,
        out.dir      = out.dir,
        prefix       = paste(run.id, sep="."),
        top          = plot.feat.no,
        pairwise     = plot.pairwise,
        colors       = ! is.null(col.cat.col),
        symbols      = ! is.null(sym.cat.col),
        width        = plot.width,
        width.legend = plot.width.legend,
        height       = plot.height,
        height.title = plot.height.title,
        cex.sym      = plot.sym.cex
    )

} else {

    # Issue warning
    if ( verb ) cat("[WARNING] Not enough data to perform analysis. Skipped.\n")

}

# Generate MDS plots for each subset
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
        cnts.filt <- cnts[rownames(cnts) %in% subset.dat[[subset]], , drop=FALSE]
        if ( incl.mean ) mean.cnts.filt <- mean.cnts[rownames(mean.cnts) %in% subset.dat[[subset]], , drop=FALSE]

        # Check if enough data is available
        if ( nrow(cnts.filt) > 1 && ncol(cnts.filt) > 1 ) {

            # Create DGEList objects
            dge.cnts.filt <- DGEList(counts=cnts.filt)
            if ( incl.mean && nrow(mean.cnts.filt) > 1 && ncol(mean.cnts.filt) > 1 ) {
                dge.mean.cnts.filt <- DGEList(counts=mean.cnts.filt)
            } else {
                dge.mean.cnts.filt <- NULL
                if ( verb && incl.mean ) cat("[WARNING] Not enough data to perform analysis of sample means. Skipped.\n")
            }

            # Write log
            if ( verb ) cat("Generating MDS plot...\n", sep="")

            # Set title
            title <- paste(subset.desc, "; top ", plot.feat.no.subsets * 100, "% of genes", sep="")

            # Generate multidimensional scaling plot: subsets
            plot.mds(
                dge          = dge.cnts.filt,
                anno         = anno,
                dge.mean     = dge.mean.cnts.filt,
                anno.mean    = mean.anno,
                title        = title,
                out.dir      = out.dir.subset,
                prefix       = paste(run.id, subset.desc.safe, sep="."),
                top          = plot.feat.no.subsets,
                pairwise     = plot.pairwise,
                colors       = ! is.null(col.cat.col),
                symbols      = ! is.null(sym.cat.col),
                width        = plot.width,
                width.legend = plot.width.legend,
                height       = plot.height,
                height.title = plot.height.title,
                cex.sym      = plot.sym.cex
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
if ( verb ) cat("Done.\n")
