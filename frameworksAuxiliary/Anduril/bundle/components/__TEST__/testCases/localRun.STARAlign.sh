#!/bin/bash

# Set root directory
root="/import/bc2/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/frameworksAuxiliary/Anduril"
execDir="${root}/bundle/components/__TEST__/output"
inputDir="${root}/bundle/components/__TEST__/dataFiles"

# Run Anduril
time anduril "run-component" "STAR" --bundle "${root}/bundle" --execution-dir "$execDir_ALIGN" --log "${execDir}/STAR/log_ALIGN" \
 -P runMode="alignReads" \
 -I INDIR_genomeDir="${inputDir}/<<MAKE_ME>>" \
 -I INFILE_readFilesIn="${inputDir}/100.fq" \
 -P twopass1readsN="{{FALSE}}" \
 -P _cores=4 \
 -P _execMode="local"
