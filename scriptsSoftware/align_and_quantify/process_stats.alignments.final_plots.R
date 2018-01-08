#!/usr/bin/env Rscript

# (c) 2016, Biozentrum, University of Basel
# Author: Alexander Kanitz
# Email: alexander.kanitz@alumni.ethz.ch


# Parameters: CLI
args <- commandArgs(trailingOnly = TRUE)
in.file <- args[1]
samples <- args[2]
out.prefix <- file.path(args[3], args[4])

# Parameters: Other
pct.cols <- c(9, 17, 18, 20, 23, 25, 26, 27, 28)

# NOTE: Additional parameters are defined in the individual plotting sections


# Import data
df <- read.delim(in.file, stringsAsFactors=FALSE)

# Data columns after import
#  [1] "Identifier"
#  [2] "Started.job.on"
#  [3] "Started.mapping.on"
#  [4] "Finished.on"
#  [5] "Mapping.speed..Million.of.reads.per.hour"
#  [6] "Number.of.input.reads"
#  [7] "Average.input.read.length"
#  [8] "Uniquely.mapped.reads.number"
#  [9] "Uniquely.mapped.reads.."
# [10] "Average.mapped.length"
# [11] "Number.of.splices..Total"
# [12] "Number.of.splices..Annotated..sjdb."
# [13] "Number.of.splices..GT.AG"
# [14] "Number.of.splices..GC.AG"
# [15] "Number.of.splices..AT.AC"
# [16] "Number.of.splices..Non.canonical"
# [17] "Mismatch.rate.per.base..."
# [18] "Deletion.rate.per.base"
# [19] "Deletion.average.length"
# [20] "Insertion.rate.per.base"
# [21] "Insertion.average.length"
# [22] "Number.of.reads.mapped.to.multiple.loci"
# [23] "X..of.reads.mapped.to.multiple.loci"
# [24] "Number.of.reads.mapped.to.too.many.loci"
# [25] "X..of.reads.mapped.to.too.many.loci"
# [26] "X..of.reads.unmapped..too.many.mismatches"
# [27] "X..of.reads.unmapped..too.short"
# [28] "X..of.reads.unmapped..other"

# Remove percent signs and cast to numeric type
df <- as.data.frame(lapply(1:ncol(df), function(col) {
    if (col %in% pct.cols) return(as.numeric(gsub("%", "", df[, col])))
    return(df[, col])
}), stringsAsFactors=FALSE)

# Derive data of interest
sample <- sapply(strsplit(df[, 1], split="_", fixed=TRUE), "[", 2)
study <- sapply(strsplit(df[, 1], split="_", fixed=TRUE), "[", 1)
mapped <- df[, 8] + df[, 22]
pct.mapped <- df[, 9] + df[, 23]
pct.unmapped <- 100 - pct.mapped
splices_per_mapped_read <- df[, 11] / mapped
pct.splices.sjdb <- df[, 12] / df[, 11] * 100

# Generate new data frame
dat <- data.frame(
    study=study,
    identifier=df[, 1],
    reads=df[, 6],
    mapped=mapped,
    mapped.unique=df[, 8],
    pct.mapped=pct.mapped,
    pct.mapped.unique=df[, 9],
    pct.mapped.multi=df[, 23],
    pct.unmapped=pct.unmapped,
    pct.unmapped.loci=df[, 25],
    pct.unmapped.mismatches=df[, 26],
    pct.unmapped.short=df[, 27],
    pct.unmapped.other=df[, 28],
    mismatch.rate=df[, 17],
    deletion.rate=df[, 18],
    insertion.rate=df[, 20],
    length.input=df[, 7],
    length.mapped=df[, 10],
    splices_per_mapped_read=splices_per_mapped_read,
    pct.splices.sjdb=pct.splices.sjdb,
    mapping.speed=df[, 5],
    row.names=sample,
    stringsAsFactors=FALSE
)

# Subset samples of interest
samples <- readLines(samples)
dat <- dat[rownames(dat) %in% samples, ]

# Subset data of interest per study
dat.ls <- lapply(dat[, 3:ncol(dat)], split, f=dat$study)

# Plot percentages of mapped reads
data <- dat.ls$pct.mapped
main <- "Percent mapped reads per study"
xlab <- "Study"
ylab <- "% mapped reads"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.mapped.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot percentages of uniquely mapped reads
data <- dat.ls$pct.mapped.unique
main="Percent uniquely mapped reads per study"
xlab <- "Study"
ylab <- "% uniquely mapped reads"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.mapped.unique.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot percentages of unmapped reads: too many loci
data <- dat.ls$pct.unmapped.loci
main="Percent unmapped reads per study: too many loci"
xlab <- "Study"
ylab <- "% unmapped reads (too many mapped loci)"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.unmapped.loci.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot percentages of unmapped reads: too many mismatches
data <- dat.ls$pct.unmapped.mismatches
main="Percent unmapped reads per study: too many mismatches"
xlab <- "Study"
ylab <- "% unmapped reads (too many mismatches)"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.unmapped.mismatches.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot percentages of unmapped reads: too short
data <- dat.ls$pct.unmapped.short
main="Percent unmapped reads per study: reads too short"
xlab <- "Study"
ylab <- "% unmapped reads (reads too short)"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.unmapped.short.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot percentages of unmapped reads: other
data <- dat.ls$pct.unmapped.other
main="Percent unmapped reads per study: other"
xlab <- "Study"
ylab <- "% unmapped reads (other)"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.unmapped.other.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot mismatch rates
data <- dat.ls$mismatch.rate
main="Mismatch rates per study"
xlab <- "Study"
ylab <- "Mismatch rate"
ylim <- c(0, round(max(unlist(data)) * 1.1, digits=1))
ystep <- ceiling(10^-floor(log10(ylim[2])) * ylim[2]) / 10^-floor(log10(ylim[2])) / 10
svg(paste(out.prefix, "reads_per_study.rate.mismatch.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], ystep), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], ystep), labels=as.character(seq(ylim[1], ylim[2], ystep)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot deletion rates
data <- dat.ls$deletion.rate
main="Deletion rates per study"
xlab <- "Study"
ylab <- "Deletion rate"
ylim <- c(0, round(max(unlist(data)) * 1.1, digits=2))
ystep <- ceiling(10^-floor(log10(ylim[2])) * ylim[2]) / 10^-floor(log10(ylim[2])) / 10
svg(paste(out.prefix, "reads_per_study.rate.deletion.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], ystep), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], ystep), labels=as.character(seq(ylim[1], ylim[2], ystep)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot insertion rates
data <- dat.ls$insertion.rate
main="Insertion rates per study"
xlab <- "Study"
ylab <- "Insertion rate"
ylim <- c(0, round(max(unlist(data)) * 1.1, digits=2))
ystep <- ceiling(10^-floor(log10(ylim[2])) * ylim[2]) / 10^-floor(log10(ylim[2])) / 10
svg(paste(out.prefix, "reads_per_study.rate.insertion.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], ystep), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], ystep), labels=as.character(seq(ylim[1], ylim[2], ystep)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot splicing events per mapped read
data <- dat.ls$splices_per_mapped_read
main="Splicing events per mapped read per study"
xlab <- "Study"
ylab <- "Splicing events per mapped read"
ylim <- c(0, ceiling(max(unlist(data)) * 1.1))
ystep <- ceiling(10^-floor(log10(ylim[2])) * ylim[2]) / 10^-floor(log10(ylim[2])) / 10
svg(paste(out.prefix, "reads_per_study.splicing_events_per_mapped_read.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], ystep), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], ystep), labels=as.character(seq(ylim[1], ylim[2], ystep)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot percentages of annotated splicing events
data <- dat.ls$pct.splices.sjdb
main <- "Percent annotated splicing events per study"
xlab <- "Study"
ylab <- "% annotated splicing events"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.annotated_splicing_events.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot median input read lengths
data <- dat.ls$length.input
main="Median input read lengths per study"
xlab <- "Study"
ylab <- "Median input read length"
ylim <- c(0, ceiling(max(unlist(data)) * 1.1))
ystep <- ceiling(10^-floor(log10(ylim[2])) * ylim[2]) / 10^-floor(log10(ylim[2])) / 10
svg(paste(out.prefix, "reads_per_study.length.input.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], ystep), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], ystep), labels=as.character(seq(ylim[1], ylim[2], ystep)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot mean mapped read lengths
data <- dat.ls$length.mapped
main="Mean mapped read lengths per study"
xlab <- "Study"
ylab <- "Mean mapped read length"
ylim <- c(0, ceiling(max(unlist(data)) * 1.1))
ystep <- ceiling(10^-floor(log10(ylim[2])) * ylim[2]) / 10^-floor(log10(ylim[2])) / 10
svg(paste(out.prefix, "reads_per_study.length.mapped.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], ystep), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], ystep), labels=as.character(seq(ylim[1], ylim[2], ystep)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())
