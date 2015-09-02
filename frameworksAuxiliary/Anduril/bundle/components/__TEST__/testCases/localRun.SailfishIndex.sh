#!/bin/bash

# Set root directory
root="/import/bc2/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/frameworksAuxiliary/Anduril"
execDir="${root}/bundle/components/__TEST__/output"
inputDir="${root}/bundle/components/__TEST__/dataFiles"

# Run Anduril
time anduril "run-component" "SailfishIndex" --bundle "${root}/bundle" --execution-dir "$execDir" --log "${execDir}/SailfishIndex/log" \
 -I INFILE_transcripts="${inputDir}/100.fa" \
 -P _execMode="local"
