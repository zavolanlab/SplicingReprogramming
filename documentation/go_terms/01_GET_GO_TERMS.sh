#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 06-DEC-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Get list of relevant GO terms


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))"

# Set output directories
outDir="${root}/publicResources/go_terms"
tmpDir="${root}/.tmp/publicResources/go_terms"
logDir="${root}/logFiles/publicResources/go_terms"

# Gene ontology URL
goUrl="ftp://ftp.geneontology.org/pub/go/ontology-archive/gene_ontology_edit.obo.2016-03-01.gz"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir --parents "$outDir"
mkdir --parents "$tmpDir"
mkdir --parents "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

# Get gene ontology file
echo "Downloading gene ontologies..." >> "$logFile"
goPath="${outDir}/go.2016-03-01.obo.gz"
wget -qO- "$goUrl" > "$goPath"

# Compile list of relevant GO terms
outFile="${outDir}/go_terms"
echo "Compiling list of relevant GO terms..." >> "$logFile"
cat > "$outFile" <<- EOF
GO:0010467	0010467	gene expression
GO:0010468	0010468	regulation of gene expression
GO:0006396	0006396	RNA processing
GO:0008380	0008380	RNA splicing
GO:0043484	0043484	regulation of RNA splicing
GO:0006397	0006397	mRNA processing
GO:0050684	0050684	regulation of mRNA processing
GO:0000398	0000398	mRNA splicing, via spliceosome
GO:0048024	0048024	regulation of mRNA splicing, via spliceosome
GO:0003723	0003723	RNA binding
GO:0003729	0003729	mRNA binding
GO:1902415	1902415	regulation of mRNA binding
GO:0003730	0003730	mRNA 3'-UTR binding
GO:1903837	1903837	regulation of mRNA 3'-UTR binding
EOF


#############
###  END  ###
#############

echo "Gene ontology OBO file: $goPath" >> "$logFile"
echo "Relevant GO terms: $outFile" >> "$logFile"
echo "Temporary data stored in: $tmpDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
