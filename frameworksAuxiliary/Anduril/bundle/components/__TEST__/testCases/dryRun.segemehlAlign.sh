#!/bin/bash

# Set root directory
root="/import/bc2/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/frameworksAuxiliary/Anduril"
execDir="${root}/bundle/components/__TEST__/output"
inputDir="${root}/bundle/components/__TEST__/dataFiles"

# Run Anduril
time anduril "run-component" "segemehl" --bundle "${root}/bundle" --execution-dir "$execDir" --log "${execDir}/segemehl/log" \
 -I INFILE_database="${inputDir}/chr.fa" \
 -I INFILE_index="${inputDir}/<<MAKE_ME>>" \
 -I INFILE_query="${inputDir}/100.fq" \
 -P _OUTFILE_outfile="true" \
 -P _execMode="none"
