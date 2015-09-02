#!/bin/bash

# Set root directory
root="/import/bc2/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/frameworksAuxiliary/Anduril"
execDir="${root}/bundle/components/__TEST__/output"
inputDir="${root}/bundle/components/__TEST__/dataFiles"

# Run Anduril
time anduril "run-component" "segemehl" --bundle "${root}/bundle" --execution-dir "$execDir" --log "${execDir}/segemehl/log" \
 -I INFILE_database="${inputDir}/chr.fa" \
 -P _OUTFILE_generate="true" \
 -P _execMode="local"
