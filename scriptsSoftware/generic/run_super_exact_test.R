#!/usr/bin/env Rscript
# (c) 2017 Alexander Kanitz, Biozentrum, University of Basel, alexander.kanitz@alumni.ethz.ch

# Load required package
if ( suppressWarnings(suppressPackageStartupMessages(require("SuperExactTest"))) == FALSE ) { stop("[ERROR] Package 'SuperExactTest' required! Aborted.") }

# Get CLI arguments
args = commandArgs(trailingOnly=TRUE)

# Process CLI arguments
pop <- as.integer(args[1])
fls <- args[-1]

# Load data
dat <- sapply(fls, readLines)

# Run test
res <- supertest(dat, n=pop)

# Prepare output table
dat.out <- summary(res)$Table
dat.out <- dat.out[dat.out$Degree > 1, ]

# Write results to file
write.table(dat.out, file=stdout(), row.names=FALSE, quote=FALSE, sep="\t")
