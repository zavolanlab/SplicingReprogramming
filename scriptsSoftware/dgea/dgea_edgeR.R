#!/usr/bin/env Rscript

# (c) 2016 Alexander Kanitz, Biozentrum, University of Basel
# (@) alexander.kanitz@unibas.ch


#################
###  IMPORTS  ###
#################

# Import required packages
suppressPackageStartupMessages(library(edgeR))


####################
###  PARAMETERS  ###
####################

# Pass command line arguments
args = commandArgs(trailingOnly=TRUE)

# Set run identifier (e.g. organism)
run.id <- args[1]

# Set input files for expression data
sample.dat <- args[2]
sample.anno <- args[3]
sample.contrasts <- args[4]

# Set output directories
out.dir.root <- args[5]

# Other parameters
cutoff.cpm.global <- 1
cutoff.samples.global <- 0.1
cutoff.cpm.individual <- 0
cutoff.samples.individual <- 0
cutoff.p.value <- 0.05
cutoff.abs.log.fc <- 0
method.p.adjust <- "BH"
mds.legend.fraction <- 1/11
mds.gene.number <- 500


##############
###  MAIN  ###
##############

# Write log
cat("Importing data...\n")

# Import sample data
sample.dat <- read.delim(sample.dat, stringsAsFactors=FALSE, row.names=1)

# Import sample annotations
sample.anno <- read.delim(sample.anno, stringsAsFactors=FALSE)
sample.contrasts <- read.delim(sample.contrasts, stringsAsFactors=FALSE)

# Write log
cat("Processing data...\n")

# Filter data without annotations
sample.dat <- sample.dat[, colnames(sample.dat) %in% sample.anno$id]

# Filter annotations without data
sample.anno <- sample.anno[sample.anno$id %in% colnames(sample.dat), ]

# Enforce correct ordering of annotations
sample.anno <- sample.anno[match(sample.anno$id, colnames(sample.dat)),]

# Generate DGEList object
dge <- DGEList(counts=sample.dat, group=sample.anno$group)

# Filter features that are expressed (CPM > x) in at least n samples
if ( cutoff.cpm.global > 0 | cutoff.samples.global > 0 ) {
    if ( cutoff.samples.global < 1 ) cutoff.samples.global <- floor(ncol(dge) * cutoff.samples.global)
    dge <- dge[rowSums(cpm(dge) > cutoff.cpm.global) >= cutoff.samples.global, , keep.lib.sizes=FALSE]
}

# Iterate over contrasts
results <- apply(sample.contrasts[, c("endpoint_1", "endpoint_2")], 1, function(row) {

    # Get contrast descriptor
    row.1.split <- unlist(strsplit(row[[1]], ".", fixed=TRUE))
    row.2.split <- unlist(strsplit(row[[2]], ".", fixed=TRUE))
    study.id <- row.1.split[1]
    organism <- row.1.split[2]
    endpoint.1 <- paste(row.1.split[4:length(row.1.split)], collapse="-")
    endpoint.2 <- paste(row.2.split[4:length(row.2.split)], collapse="-")
    contrast.id <- paste(study.id, organism, endpoint.1, "over", endpoint.2, sep=".")

    # Write log
    cat("Processing contrast ", contrast.id, "...\n", sep="'")    

    # Create output directory for current contrast
    out.dir <- file.path(out.dir.root, run.id, contrast.id)
    dir.create(out.dir, recursive=TRUE, showWarnings=FALSE)

    # Get output filename prefix
    out.prefix <- file.path(out.dir, contrast.id)

    # Initialize results container
    r <- list()

    # Subset data for current comparison
    r$dge <- dge[, sample.anno$group %in% unlist(row), keep.lib.sizes=TRUE]

    # Filter expressed features in current comparison
    if ( cutoff.cpm.individual > 0 | cutoff.samples.individual > 0 ) {
        if ( cutoff.samples.individual < 1 ) cutoff.samples.individual <- floor(ncol(dge) * cutoff.samples.individual)
        r$dge <- r$dge[rowSums(cpm(r$dge) > cutoff.cpm.individual) >= cutoff.samples.individual, , keep.lib.sizes=FALSE]
    }

    # Calculate normalization factors for RNA composition bias
    r$dge <- calcNormFactors(r$dge)

    # Estimate common and tagwise dispersion
    r$dge <- estimateDisp(r$dge)

    # Calculate fold changes and P values
    r$et <- exactTest(r$dge, pair=c(row[2], row[1]))

    # Add false discovery rate
    r$et$table$FDR <- p.adjust(p=r$et$table$PValue, method=method.p.adjust)

    # Add differential expression flag
    r$et$table$diffExpr <- as.numeric(decideTestsDGE(r$et), adjust.method=method.p.adjust, p.value=cutoff.p.value, lfc=cutoff.abs.log.fc)

    # Write out fold change table
    out.file <- paste(out.prefix, "fold_changes", "tsv", sep=".")
    write.table(r$et$table, out.file, row.names=TRUE, col.names=TRUE, quote=FALSE, sep="\t")

    # Write out tables of differentially expressed, "upregulated" and "downregulated" features
    out.file.all <- paste(out.prefix, "all", "ids", "tsv", sep=".")
    out.file.de <- paste(out.prefix, "differentially_expressed", "ids", "tsv", sep=".")
    out.file.up <- paste(out.prefix, "up", "ids", "tsv", sep=".")
    out.file.down <- paste(out.prefix, "down", "ids", "tsv", sep=".")
    write.table(rownames(r$et$table), out.file.all, row.names=FALSE, col.names=FALSE, quote=FALSE, sep="\t")
    write.table(rownames(r$et$table[abs(r$et$table$diffExpr) == 1, ]), out.file.de, row.names=FALSE, col.names=FALSE, quote=FALSE, sep="\t")
    write.table(rownames(r$et$table[r$et$table$diffExpr == 1, ]), out.file.up, row.names=FALSE, col.names=FALSE, quote=FALSE, sep="\t")
    write.table(rownames(r$et$table[r$et$table$diffExpr == -1, ]), out.file.down, row.names=FALSE, col.names=FALSE, quote=FALSE, sep="\t")

    # Initialize plot container
    r$plots <- list()

    # Build output filename
    out.file <- paste(out.prefix, "plots", "pdf", sep=".")

    # Set up plot layout
    pdf(out.file, width=18, height=15)
    mar <- mar.bak <- par("mar")
    layout(matrix(c(rep(1, 5), rep(2, 2), rep(3, 5), rep(4, 5), rep(5, 2), rep(6, 5)), ncol=12, nrow=2, byrow=TRUE))

    # Set parameters for multidimensional scaling plots
    col <- c("black", "red")[as.integer(r$dge$samples$group)]
    pch <- c(0, 5)[as.integer(r$dge$samples$group)]

    # Generate multidimensional scaling plot, gene selection: common
    mar[4] <- 0.1
    par(mar=mar)
    r$plots$mds.common <- plotMDS(
        r$dge,
        main=paste("MDS,", mds.gene.number, "features,", "common"),
        top=mds.gene.number,
        gene.selection="common",
        col=col,
        pch=pch
    )

    # Plot legend for multidimensional scaling plots
    mar[2] <- 0.1
    par(mar=mar)
    plot(1, type="n", axes=FALSE, xlab="", ylab="")
    legend("top", legend=c(endpoint.1, endpoint.2), pch=unique(pch), col=unique(col), bty="n")

    # Generate multidimensional scaling plot, gene selection: pairwise
    mar[4] <- mar.bak[4]
    par(mar=mar)
    r$plots$mds.pairwise <- plotMDS(
        r$dge,
        main=paste("MDS,", mds.gene.number, "features,", "pairwise"),
        top=mds.gene.number,
        gene.selection="pairwise",
        col=col,
        pch=pch
    )

    # Generate BCV plot
    mar[2] <- mar.bak[2]
    mar[4] <- 0.1
    par(mar=mar)
    r$plots$bcv <- plotBCV(r$dge, main="BCV")

    # Plot placeholder
    mar[2] <- 0.1
    par(mar=mar)  
    plot(1, type="n", axes=FALSE, xlab="", ylab="")  

    # Generate smear plot
    mar[4] <- mar.bak[4]
    par(mar=mar)
    r$plots$smear <- plotSmear(r$et, main="Smear", de.tags=rownames(r$dge)[as.logical(r$et$table$diffExpr)])

    # Reset margins
    par(mar=mar.bak)

    # Close graphics device
    dev.off()

    # Return results
    return(r)

})

# Save image
save.image(file.path(out.dir.root, run.id, paste(run.id, "RData", sep=".")))

# Write log
cat("Done.\n")
