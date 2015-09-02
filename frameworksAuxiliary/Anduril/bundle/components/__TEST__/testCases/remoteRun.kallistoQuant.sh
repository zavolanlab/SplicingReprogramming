#!/bin/bash

# Set root directory
root="/import/bc2/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/frameworksAuxiliary/Anduril"
execDir="${root}/bundle/components/__TEST__/output"
inputDir="${root}/bundle/components/__TEST__/dataFiles"

# Run Anduril
time anduril "run-component" "kallistoQuant" --bundle "${root}/bundle" --execution-dir "$execDir" --log "${execDir}/kallistoQuant/log" \
 -I INFILE_readseqs="${inputDir}/100.fq" \
 -I INFILE_index="${inputDir}/kallisto.idx" \
 -P _execMode="remote"
