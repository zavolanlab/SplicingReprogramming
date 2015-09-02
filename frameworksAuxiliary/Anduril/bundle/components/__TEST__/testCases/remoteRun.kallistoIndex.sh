#!/bin/bash

# Set root directory
root="/import/bc2/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/frameworksAuxiliary/Anduril"
execDir="${root}/bundle/components/__TEST__/output"
inputDir="${root}/bundle/components/__TEST__/dataFiles"

# Run Anduril
time anduril "run-component" "kallistoIndex" --bundle "${root}/bundle" --execution-dir "$execDir" --log "${execDir}/kallistoIndex/log" \
 -I INFILE_refseqs="${inputDir}/chr.fa" \
 -P _execMode="remote"
