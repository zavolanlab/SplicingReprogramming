#!/usr/bin/env Rscript

# (c) 2016, Biozentrum, University of Basel
# Author: Alexander Kanitz
# Email: alexander.kanitz@alumni.ethz.ch


# Parameters: CLI
args <- commandArgs(trailingOnly = TRUE)
in.file <- args[1]
out.prefix <- file.path(args[2], args[3])

# Parameters: QC thresholds
min.reads <- 1000000
min.fract.reads <- 0.2
min.fract.bases <- 0.2

# NOTE: Additional parameters are defined in the individual plotting sections


# Import data
df <- read.delim(in.file, stringsAsFactors=FALSE)

# Add columns
df$Study <- sapply(strsplit(df$Identifier, split="_", fixed=TRUE), "[", 1)
df$Read.pairs.written.fraction <- df$Reads.pairs.that.passed.filters / df$Read.read.pairs.processed
df$Bases.written.fraction <- df$Bases.written / df$Bases.processed

# Identify samples to be discarded
discard.reads <- df$Identifier[df$Read.read.pairs.processed < min.reads]
discard.fract.reads <- df$Identifier[1 - df$Read.pairs.written.fraction > min.fract.reads]
discard.fract.bases <- df$Identifier[1 - df$Bases.written.fraction > min.fract.bases]

# Generate vector of unique samples to discard
discard.samples <- sort(unique(c(discard.reads, discard.fract.reads, discard.fract.bases)))

# Generate names for filtering criteria
crit.discard.reads <- paste("<", min.reads, " reads", sep="")
crit.discard.fract.reads <- paste(">", min.fract.reads * 100, "% reads processed", sep="")
crit.discard.fract.bases <- paste(">", min.fract.bases * 100, "% bases processed", sep="")

# Generate vector of criteria
crit <- rep(NA, length(discard.samples))
crit <- ifelse(discard.samples %in% discard.reads, paste(crit, crit.discard.reads, sep="; "), crit)
crit <- ifelse(discard.samples %in% discard.fract.reads, paste(crit, crit.discard.fract.reads, sep="; "), crit)
crit <- ifelse(discard.samples %in% discard.fract.bases, paste(crit, crit.discard.fract.bases, sep="; "), crit)
crit <- sub("^NA; ", "", crit, perl=TRUE)

# Generate table of discarded samples and criteria
discard.df <- data.frame(identifier=discard.samples, criteria=crit)

# Write out samples to be discarded
write.table(discard.df, paste(out.prefix, "samples_to_filter", sep="."), row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")

# Subset data of interest per study
reads <- split(log10(df$Read.read.pairs.processed), f=df$Study)
reads.fraction <- split(df$Read.pairs.written.fraction, f=df$Study)
bases.fraction <- split(df$Bases.written.fraction, f=df$Study)

# Plot library sizes
svg(paste(out.prefix, "library_sizes.svg", sep="."), width=14, height=7)
main="Library sizes per study"
xlab="Study"
ylab="Reads"
yax.pos=log10(c(100000, 500000, 1000000, 5000000, 10000000, 50000000, 100000000))
yax.lab=expression(1%*%10^5, 5%*%10^5, 1%*%10^6, 5%*%10^6, 1%*%10^7, 5%*%10^7, 1%*%10^8)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(reads, main=main, xaxt="n", yaxt="n", log="y")
abline(h=log10(min.reads), lty=2, col="red")
axis(1, at=1:length(reads), labels=FALSE)
axis(side=2, at=yax.pos, labels=FALSE)
text(1:length(reads), 10^(par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04), labels=names(reads), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, yax.pos, labels=yax.lab, srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot fractions of reads filtered during poly(A) tail removal
svg(paste(out.prefix, "discarded.reads.svg", sep="."), width=14, height=7)
main="Fractions of discarded reads per study"
xlab="Study"
ylab="Fraction of reads"
ylim=c(0.0, max(1 - min(unlist(reads.fraction)), 0.5))
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(lapply(reads.fraction, function(vec) 1 - vec), main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=min.fract.reads, lty=2, col="red")
axis(1, at=1:length(reads.fraction), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 0.1), labels=FALSE)
text(1:length(reads.fraction), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(reads.fraction), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 0.1), labels=as.character(seq(ylim[1], ylim[2], 0.1)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot fractions of bases filtered during poly(A) tail removal
svg(paste(out.prefix, "discarded.bases.svg", sep="."), width=14, height=7)
main="Fractions of discarded bases per study"
xlab="Study"
ylab="Fraction of bases"
ylim=c(0.0, max(1 - min(unlist(bases.fraction)), 0.5))
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(lapply(bases.fraction, function(vec) 1 - vec), main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=min.fract.bases, lty=2, col="red")
axis(1, at=1:length(bases.fraction), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 0.1), labels=FALSE)
text(1:length(bases.fraction), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(bases.fraction), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 0.1), labels=as.character(seq(ylim[1], ylim[2], 0.1)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())
