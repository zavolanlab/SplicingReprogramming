#!/bin/bash

# Set root directory
root="/import/bc2/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/frameworksAuxiliary/Anduril"
execDir="${root}/bundle/components/__TEST__/output"
inputDir="${root}/bundle/components/__TEST__/dataFiles"

# Run Anduril
time anduril "run-component" "SAMtoolsIndex" --bundle "${root}/bundle" --execution-dir "$execDir" --log "${execDir}/SAMtoolsIndex/log" \
 -I INFILE_infile="${inputDir}/100.bam" \
 -P _execMode="none"
