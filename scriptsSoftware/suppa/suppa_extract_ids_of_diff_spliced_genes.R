#!/usr/bin/env Rscript

# Extracts IDs of differentially spliced genes per comparison from a P value data table assembled from multiple outputs of SUPPA's `diffSplice` tool

# Usage: 

# DATA_TABLE requires a data table of P values with m features (rows) by n comparisons (columns); the first row is expected to indicate comparison names and the first column must indicate feature IDs (only the part until the first semicolon will be used!)
# Default OUTPUT_DIRECTORY: current working directory
# Default P_VALUE_THRESHOLD: 0.05

# Usage
usage <- "Usage: suppa_extract_ids_of_diff_spliced_genes.R DATA_TABLE (OUTPUT_DIRECTORY P_VALUE_THRESHOLD)"

# CLI parameters
args <- commandArgs(trailingOnly=TRUE)
if ( length(args) < 1 ) stop("Input file missing. ", usage) else in.file <- args[1]
out.dir <- if ( length(args) >= 2 ) args[2] else "."
threshold <- if ( length(args) == 3 ) args[3] else 0.05

# Parameters
prefix.fg <- "fg.passed_threshold."
prefix.bg <- "bg.all_features"
suffix <- ".txt"

# Read data
dat <- read.delim(in.file, stringsAsFactors=FALSE)

# Extract names
ids.all <- sapply(strsplit(rownames(dat), ";", fixed=TRUE), "[[", 1)

# Apply threshold
dat.bool <- as.data.frame(dat <= threshold)

# Get IDs of unique features passing threshold
ids <- lapply(dat.bool, function(comp) { unique(ids.all[comp]) })

# Create output directory
dir.create(out.dir, showWarnings = FALSE)

# Write IDs of all unique features
writeLines(unique(ids.all), paste(file.path(out.dir, prefix.bg), suffix, sep=""))

# Write IDs of unique features passing the threshold for each comparison
for (comp in names(ids)) {
    writeLines(ids[[comp]], paste(file.path(out.dir, prefix.fg), comp, suffix, sep=""))
}
