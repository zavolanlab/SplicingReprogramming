# TODO
# Constant legend height & width (dendrograms etc)
# Width multiplicator (similar to height)
# Generate heatmaps per organism (remove short name, only keep corresponding gene symbol)
# Separate fold change table generation into separate script


#################
###  IMPORTS  ###
#################

# Import required packages
suppressPackageStartupMessages(library(gplots))
suppressPackageStartupMessages(library(RColorBrewer))


####################
###  PARAMETERS  ###
####################

# Set input files for expression data
sample.dat <- "/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/analyzedData/align_and_quantify/sra_data/merged/abundances/tpm/all.orthologous_genes.tpm"
sample.anno <- "/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/internalResources/sra_data/samples.annotations.tsv"
sample.contrasts <- "/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/internalResources/sra_data/samples.contrasts.tsv"

# Set input files for GO terms and members
go.info <- "/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/publicResources/go_terms/go_terms"
go.dir <- "/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/publicResources/go_terms"
go.glob <- "*.common_gene_symbols"

# Set output filename parts
out.dir <- "/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/analyzedData/align_and_quantify/sra_data/plots/fold_changes/heatmaps"

# Set other parameters
short_names.contrasts <- c("hsa|ERP014707.WT.NPC|neuron", "hsa|ERP014707.PD.NPC|neuron", "mmu|SRP011318.MEF_iPSC|MEF", "mmu|SRP011318.APC2_iPSC|APC2", "mmu|SRP011318.HPC_iPSC|HPC", "mmu|SRP011318.APC3_iPSC|APC3", "hsa|SRP016568.iPSC|foreskin_fibro", "hsa|SRP017684.iPSC|neuron", "hsa|SRP017684.iPSC|NPC", "hsa|SRP017684.NPC|neuron", "mmu|SRP026281.CiPS|MEF", "mmu|SRP033561.iPSC_fast|MEF_slow", "hsa|SRP033569.iPSC_Retro|fibro", "hsa|SRP033569.iPSC_Sendai|fibro", "mmu|SRP033700.iPSC|MEF", "hsa|SRP039361.iPSC|macrophage_iPSC", "mmu|SRP045688.iPSC|MEF", "ptr|SRP045999.iPSC_fibro|dermal_fibro", "hsa|SRP045999.iPSC_LCL|LCL", "hsa|SRP045999.iPSC_fibro|dermal_fibro", "mmu|SRP047225.iCPC_young|cardiac_fibro", "mmu|SRP047225.iCPC_old|cardiac_fibro", "hsa|SRP049340.iPSC_hiF|hiF", "hsa|SRP049340.iPSC_hiF-T|hiF-T", "hsa|SRP049593.7dupASD.iPSC_fibro|MSC_iPSC", "hsa|SRP049593.WT.iPSC_fibro|MSC_iPSC", "hsa|SRP049593.WBS.iPSC_fibro|MSC_iPSC", "hsa|SRP049593.AtWBS.iPSC_fibro|MSC_iPSC", "mmu|SRP051710.iTSC|MEF", "mmu|SRP052014.iPSC_SSC|SSC", "mmu|SRP056571.trans_NSC|MEF", "mmu|SRP056571.iPSC|MEF", "hsa|SRP056822.WT.iPSC|neuron_iPSC", "hsa|SRP056822.WT.iPSC|NPC_iPSC", "hsa|SRP056822.WT.NPC_iPSC|neuron_iPSC", "hsa|SRP056822.ASD.iPSC|neuron_iPSC", "hsa|SRP056822.ASD.iPSC|NPC_iPSC", "hsa|SRP056822.ASD.NPC_iPSC|neuron_iPSC", "mmu|SRP058020.iPSC_NPC|NPC", "hsa|SRP059205.iPSC_PBMC|myel_prog_iPSC_PBMC", "hsa|SRP059205.iPSC_PBMC|promyeloc_iPSC_PBMC", "hsa|SRP059205.iPSC_PBMC|MSC_iPSC_PBMC", "hsa|SRP059205.iPSC_fibro|MSC_iPSC_fibro", "hsa|SRP059205.iPSC_cord_blood|MSC_iPSC_cord_blood", "mmu|SRP059670.iPSC|MEF", "mmu|SRP060709.WT.iPSC|MEF", "mmu|SRP060709.MKOS.iPSC|MEF", "mmu|SRP060709.OKMS.iPSC|MEF", "hsa|SRP061880.WT.NPC_iPSC|neuron_iPSC", "hsa|SRP061880.CHD8+/-.NPC_iPSC|neuron_iPSC", "hsa|SRP063867.iPSC_isogenic|fibro_isogenic", "mmu|SRP064357.ciPSC|MEF", "hsa|SRP065036.WT.iPSC|NSC", "hsa|SRP065036.HD.iPSC|NSC", "mmu|SRP069058.ieCPC_p12|fibro", "mmu|SRP069058.ieCPC_p3|fibro", "mmu|SRP069058.ieCPC_p3|cardiac", "mmu|SRP069058.ieCPC_p12|cardiac", "mmu|SRP069250.iXEN_ES_medium|MEF", "mmu|SRP069250.iXEN_XEN_medium|MEF", "mmu|SRP071205.ciNSLC|MEF", "hsa|SRP076951.ADRC-40_iPSC.NPC|neurons", "hsa|SRP076951.WT-33_iPSC.NPC|neurons", "ptr|SRP076951.PR00818_iPSC.NPC|neurons", "ptr|SRP076951.PR01209_iPSC.NPC|neurons")
short_names.organisms <- setNames(c("hsa", "mmu", "ptr"), c("Homo_sapiens", "Mus_musculus", "Pan_troglodytes"))
pseudo.count <- 2^-10
de.threshold <- 1
plot.width <- 10
plot.height.min <- 10
plot.height.max <- 300
plot.height.factor <- 0.2  # Multiplied by number of genes


###################
###  FUNCTIONS  ###
###################

# Define plotting function
plot.heat <- function(
    x,
    trace        = "none",
    margins      = c(20,9),
    density.info = "density",
    denscol      = 1,
    key.title    = "Color key",
    key.xlab     = "Log2 fold change",
    xlab         = "Comparison",
    ylab         = "Gene",
    ...
) {

    # Coerce data to matrix
    x <- as.matrix(x)

    # Set colors
    col <- colorRampPalette(c("blue", "white", "orange"))(n = 299)

    # Plot heatmap
    heatmap.2(
        x,
        col          = col,
        trace        = trace,
        margins      = margins,
        density.info = density.info,
        denscol      = 1,
        key.title    = key.title,
        key.xlab     = key.xlab,
        xlab         = xlab,
        ylab         = ylab,
        ...
    )

}


##############
###  MAIN  ###
##############

# Import sample data
sample.dat <- read.delim(sample.dat, stringsAsFactors=FALSE, row.names=1)

# Import sample annotations
sample.anno <- read.delim(sample.anno, stringsAsFactors=FALSE)
sample.contrasts <- read.delim(sample.contrasts, stringsAsFactors=FALSE)

# Filter samples in annotation vector
sample.dat <- sample.dat[, sample.anno$id]

# Calculate replicate means
sample.groups <- aggregate(sample.anno$id ~ paste(sample.anno$study_id, sample.anno$descriptor, sep="."), sample.anno, c)
sample.dat <- sapply(sample.groups[, 2], function(group.members) {
    rowMeans(sample.dat[, group.members, drop=FALSE])
})
colnames(sample.dat) <- sample.groups[, 1]

# Set pseudocount
sample.dat[sample.dat < pseudo.count] <- pseudo.count

# Calculate fold changes for sample contrasts
sample.contrasts <- data.frame(endpoint_1=paste(sample.contrasts$study_id, sample.contrasts$endpoint_1, sep="."), endpoint_2=paste(sample.contrasts$study_id, sample.contrasts$endpoint_2, sep="."), stringsAsFactors=FALSE)
sample.dat <- apply(sample.contrasts, 1, function(contrast) {
    log2(sample.dat[, contrast[[1]]] / sample.dat[, contrast[[2]]])
})
colnames(sample.dat) <- short_names.contrasts

# Import and process GO term information
go.info <- read.delim(go.info, header=FALSE, stringsAsFactors=FALSE, colClasses=rep("character", 3), col.names=c("full_id", "short_id", "description"))

# Import gene symbols associated with GO terms
go.paths <- sort(dir(go.dir, pattern=glob2rx(go.glob), recursive=FALSE, full.names=TRUE))
go.dat <- lapply(go.paths, scan, "", quiet=TRUE)
names(go.dat) <- sapply(strsplit(basename(go.paths), ".", fixed=TRUE), "[[", 1)

# Iterate over GO terms
for ( term in names(go.dat) ) {

    # Get GO term full name and description
    term.full <- go.info$full_id[match(term, go.info$short_id)]
    term.desc <- go.info$description[match(term, go.info$short_id)]
    term.desc.safe <- gsub(",", "", gsub(" ", "_", term.desc))
    term.plot <- paste(term.full, term.desc, sep=", ")
    term.filt.plot <- paste(term.plot, ", |log2 fold change| > ", de.threshold, sep="")

    # Set output file prefix
    out.prefix <- file.path(out.dir, term.desc.safe)

    # Subset GO term member genes
    sample.dat.plot <- sample.dat[rownames(sample.dat) %in% go.dat[[term]], , drop=FALSE]

    # Check if enough data is available
    if ( nrow(sample.dat.plot) > 1 & ncol(sample.dat.plot) > 1 ) {

        # Set output filename
        out.file <- paste(out.prefix, "all", "pdf", sep=".")

        # Generate heatmap
        height=max(plot.height.min, min(plot.height.max, plot.height.factor * nrow(sample.dat.plot)))
        pdf(out.file, width=plot.width, height=height)
        plot.heat(sample.dat.plot, main=term.plot)
        dev.off()

    }

    # Subset only differentially expressed genes
    sample.dat.filt.plot <- sample.dat.plot[abs(rowMeans(sample.dat.plot)) > de.threshold, ]

    # Check if enough data is available
    if ( nrow(sample.dat.filt.plot) > 1 & ncol(sample.dat.filt.plot) > 1 ) {

        # Set output filename
        out.file.filt <- paste(out.prefix, "diff_expr", "pdf", sep=".")

        # Generate heatmap
        height=max(plot.height.min, min(plot.height.max, plot.height.factor * nrow(sample.dat.filt.plot)))
        pdf(out.file.filt, width=plot.width, height=height)
        plot.heat(sample.dat.filt.plot, main=term.filt.plot)
        dev.off()

    }

}

