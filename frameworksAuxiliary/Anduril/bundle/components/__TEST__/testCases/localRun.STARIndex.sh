#!/bin/bash

# Set root directory
root="/import/bc2/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/frameworksAuxiliary/Anduril"
execDir="${root}/bundle/components/__TEST__/output"
inputDir="${root}/bundle/components/__TEST__/dataFiles"

# Run Anduril
time anduril "run-component" "STAR" --bundle "${root}/bundle" --execution-dir "$execDir_INDEX" --log "${execDir}/STAR/log_INDEX" \
 -P runMode="genomeGenerate" \
 -I INFILE_genomeFastaFiles="${inputDir}/<<MAKE_ME>>" \
 -P _OUTDIRMAKE_genomeDir="true" \
 -P twopass1readsN="{{FALSE}}" \
 -P _cores=8 \
 -P _execMode="local"
