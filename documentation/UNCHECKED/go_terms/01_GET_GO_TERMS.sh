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
intResDir="${root}/internalResources/sra_data"

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

# Split GO terms by category
goBase="$(basename "$goPath" .obo.gz)"
perl -lne 'if ( $term ) { if ( /^$/ ) { if ( $rec[1] =~ /biological_process/ ) { print $rec[0] } ; @rec = () } elsif ( /^(id|namespace):/ ) { push @rec, $_ } } elsif (/^\[Term\]$/) { $term = 1 }' <(zcat "$goPath") | sed 's/id: //' | sort -u > "${outDir}/${goBase}.bp"
perl -lne 'if ( $term ) { if ( /^$/ ) { if ( $rec[1] =~ /molecular_function/ ) { print $rec[0] } ; @rec = () } elsif ( /^(id|namespace):/ ) { push @rec, $_ } } elsif (/^\[Term\]$/) { $term = 1 }' <(zcat "$goPath") | sed 's/id: //' | sort -u > "${outDir}/${goBase}.mf"
perl -lne 'if ( $term ) { if ( /^$/ ) { if ( $rec[1] =~ /cellular_component/ ) { print $rec[0] } ; @rec = () } elsif ( /^(id|namespace):/ ) { push @rec, $_ } } elsif (/^\[Term\]$/) { $term = 1 }' <(zcat "$goPath") | sed 's/id: //' | sort -u > "${outDir}/${goBase}.cc"

# Prepare GO ID to name lookup table
perl -lne 'if ( $term ) { if ( /^$/ ) { print "$rec[0]\t$rec[1]\t$rec[2]"; @rec = (); $term = 0 } elsif ( /^(id|name|namespace):/ ) { @ls = split /\s/, $_, 2; push @rec, $ls[1] } } elsif (/^\[Term\]$/) { $term = 1 } ' <(zcat "$goPath") | sed 's/id: //' | sort -u > "${outDir}/${goBase}.ids_2_names"

# Compile list of relevant GO terms
outFile="${intResDir}/go_terms"
echo "Compiling list of relevant GO terms..." >> "$logFile"
cat > "$outFile" <<- EOF
0000398	mRNA splicing, via spliceosome (GO:0000398)
0003676	nucleic acid binding (GO:0003676)
0003723	RNA binding (GO:0003723)
0006396	RNA processing (GO:0006396)
0006397	mRNA processing (GO:0006397)
0008380	RNA splicing (GO:0008380)
0010467	gene expression (GO:0010467)
0034660	ncRNA metabolic process (GO:0034660)
0044822	poly(A) RNA binding (GO:0044822)
1990904	ribonucleoprotein complex (GO:1990904)
EOF


#############
###  END  ###
#############

echo "Gene ontology OBO file: $goPath" >> "$logFile"
echo "Relevant GO terms: $outFile" >> "$logFile"
echo "Temporary data stored in: $tmpDir" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
