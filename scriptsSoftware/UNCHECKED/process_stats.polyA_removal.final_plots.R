#!/usr/bin/env Rscript

# (c) 2016, Biozentrum, University of Basel
# Author: Alexander Kanitz
# Email: alexander.kanitz@alumni.ethz.ch


# Parameters: CLI
args <- commandArgs(trailingOnly = TRUE)
in.file <- args[1]
samples <- args[2]
out.prefix <- file.path(args[3], args[4])

# NOTE: Additional parameters are defined in the individual plotting sections


# Import data
df <- read.delim(in.file, stringsAsFactors=FALSE)

# Add columns
df$Study <- sapply(strsplit(df$Identifier, split="_", fixed=TRUE), "[", 1)
df$Sample <- sapply(strsplit(df$Identifier, split="_", fixed=TRUE), "[", 2)

# Subset samples of interest
samples <- readLines(samples)
df <- df[df$Sample %in% samples, ]

# Subset data of interest per study
reads <- split(log10(df$Read.read.pairs.processed), f=df$Study)

# Plot library sizes
svg(paste(out.prefix, "library_sizes.svg", sep="."), width=14, height=7)
main="Library sizes per study"
xlab="Study"
ylab="Reads"
yax.pos=log10(c(100000, 500000, 1000000, 5000000, 10000000, 50000000, 100000000))
yax.lab=expression(1%*%10^5, 5%*%10^5, 1%*%10^6, 5%*%10^6, 1%*%10^7, 5%*%10^7, 1%*%10^8)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(reads, main=main, xaxt="n", yaxt="n", log="y")
axis(1, at=1:length(reads), labels=FALSE)
axis(side=2, at=yax.pos, labels=FALSE)
text(1:length(reads), 10^(par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04), labels=names(reads), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, yax.pos, labels=yax.lab, srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())
