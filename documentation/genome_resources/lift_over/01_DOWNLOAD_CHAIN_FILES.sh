# Set parameters
root="/scicore/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming"
outDir="${root}/publicResources/genome_resources/lift_over"

# Create output directories
mkdir -p "$outDir" "$outDir/raw"

# Download chain files
wget --output-document "$outDir/raw/hg38ToMm10.over.chain.gz" http://hgdownload.cse.ucsc.edu/goldenPath/hg38/liftOver/hg38ToMm10.over.chain.gz
wget --output-document "$outDir/raw/mm10ToHg38.over.chain.gz" http://hgdownload.cse.ucsc.edu/goldenPath/mm10/liftOver/mm10ToHg38.over.chain.gz
