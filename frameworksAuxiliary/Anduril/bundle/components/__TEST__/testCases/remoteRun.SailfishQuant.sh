#!/bin/bash

# Set root directory
root="/import/bc2/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/frameworksAuxiliary/Anduril"
execDir="${root}/bundle/components/__TEST__/output"
inputDir="${root}/bundle/components/__TEST__/dataFiles"

# Run Anduril
time anduril "run-component" "SailfishQuant" --bundle "${root}/bundle" --execution-dir "$execDir" --log "${execDir}/SailfishQuant/log" \
 -I INDIR_index="${inputDir}/<<MAKE_ME>>" \
 -I INFILE_unmated_reads="${inputDir}/100.fq" \
 -P _execMode="remote"
