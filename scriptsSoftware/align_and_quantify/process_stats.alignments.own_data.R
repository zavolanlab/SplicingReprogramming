#!/usr/bin/env Rscript

# (c) 2016, Biozentrum, University of Basel
# Author: Alexander Kanitz
# Email: alexander.kanitz@alumni.ethz.ch


# Parameters: CLI
args <- commandArgs(trailingOnly = TRUE)
in.file <- args[1]
out.prefix <- file.path(args[2], args[3])

# Parameters: QC thresholds
thresholds <- list()
thresholds$reads <- list(NA, NA, " reads processed")
thresholds$mapped <- list(1000000, NA, " mapped reads")
thresholds$mapped.unique <- list(NA, NA, " uniquely mapped reads")
thresholds$pct.mapped <- list(70, NA, "% mapped reads")
thresholds$pct.mapped.unique <- list(50, NA, "% uniquely mapped reads")
thresholds$pct.mapped.multi <- list(NA, NA, "% multimapping reads")
thresholds$pct.unmapped <- list(NA, NA, "% unmapped reads")
thresholds$pct.unmapped.loci <- list(NA, NA, "% unmapped reads, too many loci")
thresholds$pct.unmapped.mismatches <- list(NA, NA, "% unmapped reads, too many mismatches")
thresholds$pct.unmapped.short <- list(NA, NA, "% unmapped reads, reads too short")
thresholds$pct.unmapped.other <- list(NA, NA, "% unmapped reads, other")
thresholds$mismatch.rate <- list(NA, 10, " mismatch rate per base")
thresholds$deletion.rate <- list(NA, 5, " deletion rate per base")
thresholds$insertion.rate <- list(NA, 5, " insertion rate per base")
thresholds$length.input <- list(NA, NA, " median length, processed reads")
thresholds$length.mapped <- list(30, NA, " average length, mapped reads")
thresholds$splices_per_mapped_read <- list(NA, NA, " splices per mapped read")
thresholds$pct.splices.sjdb <- list(90, NA, "% annotated splice junctions")
thresholds$mapping.speed <- list(NA, NA, " mapping spped, mio reads per h")

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
sample <- sapply(lapply(lapply(strsplit(df[, 1], split="_", fixed=TRUE), "[", 4:5), na.omit), paste, collapse="_")
study <- sapply(lapply(lapply(strsplit(df[, 1], split="_", fixed=TRUE), "[", 1:3), na.omit), paste, collapse="_")
mapped <- df[, 8] + df[, 22]
pct.mapped <- df[, 9] + df[, 23]
pct.unmapped <- 100 - pct.mapped
splices_per_mapped_read <- df[, 11] / mapped
pct.splices.sjdb <- df[, 12] / df[, 11] * 100

# Generate new data frame
dat <- data.frame(
    study=study,
    identifier=df[, 1],
    sample=sample,
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
    row.names=df[, 1],
    stringsAsFactors=FALSE
)

# Identify studies to be discarded
discard.ls <- mapply(function(col, lim) {
    df.min <- na.omit(dat[col < lim[1], 2, drop=FALSE])
    df.max <- na.omit(dat[col > lim[2], 2, drop=FALSE])
    df.min$criteria <- rep(paste("<", lim[1], lim[3], sep=""), nrow(df.min))
    df.max$criteria <- rep(paste(">", lim[2], lim[3], sep=""), nrow(df.max))
    rbind(df.min, df.max)
}, dat[4:ncol(dat)], thresholds, SIMPLIFY=FALSE)

# Generate data frame
discard.df <- do.call(rbind, discard.ls)

# Aggregate data
discard.df <- aggregate(discard.df$criteria ~ discard.df$identifier, discard.df, paste, collapse="; ")
colnames(discard.df) <- c("identifier", "criteria")

# Write out studies to be discarded
write.table(discard.df, paste(out.prefix, "samples_to_filter", sep="."), row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")

# Subset data of interest per study
dat.ls <- lapply(dat[, 3:ncol(dat)], split, f=dat$study)

# Plot number of reads
data <- dat.ls$reads
h <- thresholds$reads
main <- "Number of reads per study"
xlab <- "Study"
ylab <- "Number of input reads"
yax.pos <- c(100000, 500000, 1000000, 5000000, 10000000, 50000000, 100000000)
yax.lab <- expression(1%*%10^5, 5%*%10^5, 1%*%10^6, 5%*%10^6, 1%*%10^7, 5%*%10^7, 1%*%10^8)
svg(paste(out.prefix, "reads_per_study.input.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", log="y")
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(dat.ls$reads), labels=FALSE)
axis(side=2, at=yax.pos, labels=FALSE)
text(1:length(dat.ls$reads), 10^(par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04), labels=names(dat.ls$reads), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, yax.pos, labels=yax.lab, srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot number of mapped reads
data <- dat.ls$mapped
h <- thresholds$mapped
main <- "Number of mapped reads per study"
xlab <- "Study"
ylab <- "Number of mapped reads"
yax.pos <- c(100000, 500000, 1000000, 5000000, 10000000, 50000000, 100000000)
yax.lab <- expression(1%*%10^5, 5%*%10^5, 1%*%10^6, 5%*%10^6, 1%*%10^7, 5%*%10^7, 1%*%10^8)
svg(paste(out.prefix, "reads_per_study.mapped.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", log="y")
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(side=2, at=yax.pos, labels=FALSE)
text(1:length(data), 10^(par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04), labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, yax.pos, labels=yax.lab, srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot number of uniquely mapped reads
data <- dat.ls$mapped.unique
h <- thresholds$mapped.unique
main <- "Number of uniquely mapped reads per study"
xlab <- "Study"
ylab <- "Number of uniquely mapped reads"
yax.pos <- c(100000, 500000, 1000000, 5000000, 10000000, 50000000, 100000000)
yax.lab <- expression(1%*%10^5, 5%*%10^5, 1%*%10^6, 5%*%10^6, 1%*%10^7, 5%*%10^7, 1%*%10^8)
svg(paste(out.prefix, "reads_per_study.mapped.unique.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", log="y")
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(side=2, at=yax.pos, labels=FALSE)
text(1:length(data), 10^(par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04), labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, yax.pos, labels=yax.lab, srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot percentages of mapped reads
data <- dat.ls$pct.mapped
h <- thresholds$pct.mapped
main <- "Percent mapped reads per study"
xlab <- "Study"
ylab <- "% mapped reads"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.mapped.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot percentages of uniquely mapped reads
data <- dat.ls$pct.mapped.unique
h <- thresholds$pct.mapped.unique
main="Percent uniquely mapped reads per study"
xlab <- "Study"
ylab <- "% uniquely mapped reads"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.mapped.unique.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot percentages of multimapping reads
data <- dat.ls$pct.mapped.multi
h <- thresholds$pct.mapped.multi
main="Percent multimapping reads per study"
xlab <- "Study"
ylab <- "% multimapping reads"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.mapped.multi.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot percentages of unmapped reads: all
data <- dat.ls$pct.unmapped
h <- thresholds$pct.unmapped
main="Percent unmapped reads per study"
xlab <- "Study"
ylab <- "% unmapped reads"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.unmapped.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot percentages of unmapped reads: too many loci
data <- dat.ls$pct.unmapped.loci
h <- thresholds$pct.unmapped.loci
main="Percent unmapped reads per study: too many loci"
xlab <- "Study"
ylab <- "% unmapped reads (too many mapped loci)"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.unmapped.loci.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot percentages of unmapped reads: too many mismatches
data <- dat.ls$pct.unmapped.mismatches
h <- thresholds$pct.unmapped.mismatches
main="Percent unmapped reads per study: too many mismatches"
xlab <- "Study"
ylab <- "% unmapped reads (too many mismatches)"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.unmapped.mismatches.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot percentages of unmapped reads: too short
data <- dat.ls$pct.unmapped.short
h <- thresholds$pct.unmapped.short
main="Percent unmapped reads per study: reads too short"
xlab <- "Study"
ylab <- "% unmapped reads (reads too short)"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.unmapped.short.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot percentages of unmapped reads: other
data <- dat.ls$pct.unmapped.other
h <- thresholds$pct.unmapped.other
main="Percent unmapped reads per study: other"
xlab <- "Study"
ylab <- "% unmapped reads (other)"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.unmapped.other.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot mismatch rates
data <- dat.ls$mismatch.rate
h <- thresholds$mismatch.rate
main="Mismatch rates per study"
xlab <- "Study"
ylab <- "Mismatch rate"
ylim <- c(0, round(max(unlist(data)) * 1.1, digits=1))
ystep <- ceiling(10^-floor(log10(ylim[2])) * ylim[2]) / 10^-floor(log10(ylim[2])) / 10
svg(paste(out.prefix, "reads_per_study.rate.mismatch.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], ystep), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], ystep), labels=as.character(seq(ylim[1], ylim[2], ystep)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot deletion rates
data <- dat.ls$deletion.rate
h <- thresholds$deletion.rate
main="Deletion rates per study"
xlab <- "Study"
ylab <- "Deletion rate"
ylim <- c(0, round(max(unlist(data)) * 1.1, digits=2))
ystep <- ceiling(10^-floor(log10(ylim[2])) * ylim[2]) / 10^-floor(log10(ylim[2])) / 10
svg(paste(out.prefix, "reads_per_study.rate.deletion.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], ystep), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], ystep), labels=as.character(seq(ylim[1], ylim[2], ystep)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot insertion rates
data <- dat.ls$insertion.rate
h <- thresholds$insertion.rate
main="Insertion rates per study"
xlab <- "Study"
ylab <- "Insertion rate"
ylim <- c(0, round(max(unlist(data)) * 1.1, digits=2))
ystep <- ceiling(10^-floor(log10(ylim[2])) * ylim[2]) / 10^-floor(log10(ylim[2])) / 10
svg(paste(out.prefix, "reads_per_study.rate.insertion.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], ystep), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], ystep), labels=as.character(seq(ylim[1], ylim[2], ystep)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot median input read lengths
data <- dat.ls$length.input
h <- thresholds$length.input
main="Median input read lengths per study"
xlab <- "Study"
ylab <- "Median input read length"
ylim <- c(0, ceiling(max(unlist(data)) * 1.1))
ystep <- ceiling(10^-floor(log10(ylim[2])) * ylim[2]) / 10^-floor(log10(ylim[2])) / 10
svg(paste(out.prefix, "reads_per_study.length.input.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], ystep), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], ystep), labels=as.character(seq(ylim[1], ylim[2], ystep)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot mean mapped read lengths
data <- dat.ls$length.mapped
h <- thresholds$length.mapped
main="Mean mapped read lengths per study"
xlab <- "Study"
ylab <- "Mean mapped read length"
ylim <- c(0, ceiling(max(unlist(data)) * 1.1))
ystep <- ceiling(10^-floor(log10(ylim[2])) * ylim[2]) / 10^-floor(log10(ylim[2])) / 10
svg(paste(out.prefix, "reads_per_study.length.mapped.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], ystep), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], ystep), labels=as.character(seq(ylim[1], ylim[2], ystep)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot splicing events per mapped read
data <- dat.ls$splices_per_mapped_read
h <- thresholds$splices_per_mapped_read
main="Splicing events per mapped read per study"
xlab <- "Study"
ylab <- "Splicing events per mapped read"
ylim <- c(0, ceiling(max(unlist(data)) * 1.1))
ystep <- ceiling(10^-floor(log10(ylim[2])) * ylim[2]) / 10^-floor(log10(ylim[2])) / 10
svg(paste(out.prefix, "reads_per_study.splicing_events_per_mapped_read.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], ystep), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], ystep), labels=as.character(seq(ylim[1], ylim[2], ystep)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot percentages of annotated splicing events
data <- dat.ls$pct.splices.sjdb
h <- thresholds$pct.splices.sjdb
main <- "Percent annotated splicing events per study"
xlab <- "Study"
ylab <- "% annotated splicing events"
ylim <- c(0, 100)
svg(paste(out.prefix, "reads_per_study.percent.annotated_splicing_events.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], 10), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], 10), labels=as.character(seq(ylim[1], ylim[2], 10)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())

# Plot mapping speed
data <- dat.ls$mapping.speed
h <- thresholds$mapping.speed
main="Mapping speed per study"
xlab <- "Study"
ylab <- "Mapping speed (million reads per hour)"
ylim <- c(0, ceiling(max(unlist(data)) * 1.1))
ystep <- ceiling(10^-floor(log10(ylim[2])) * ylim[2]) / 10^-floor(log10(ylim[2])) / 10
svg(paste(out.prefix, "reads_per_study.mapping_speed.svg", sep="."), width=14, height=7)
par(mar=c(7, 6, 4, 2) + 0.1)
boxplot(data, main=main, xaxt="n", yaxt="n", ylim=ylim)
abline(h=h[[1]], lty=2, col="red")
abline(h=h[[2]], lty=2, col="red")
axis(1, at=1:length(data), labels=FALSE)
axis(2, at=seq(ylim[1], ylim[2], ystep), labels=FALSE)
text(1:length(data), par("usr")[3] - (par("usr")[4] - par("usr")[3]) * 0.04, labels=names(data), srt=45, adj=1, xpd=TRUE, cex=0.8)
text(par("usr")[1] - (par("usr")[2] - par("usr")[1]) * 0.02, seq(ylim[1], ylim[2], ystep), labels=as.character(seq(ylim[1], ylim[2], ystep)), srt=45, adj=1, xpd=TRUE, cex=0.8)
mtext(1, text=xlab, line=5)
mtext(2, text=ylab, line=4)
invisible(dev.off())
