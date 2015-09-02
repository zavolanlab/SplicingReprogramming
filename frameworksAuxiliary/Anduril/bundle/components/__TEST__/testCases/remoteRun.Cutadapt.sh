#!/bin/bash

# Set root directory
root="/import/bc2/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/frameworksAuxiliary/Anduril"
execDir="${root}/bundle/components/__TEST__/output"
inputDir="${root}/bundle/components/__TEST__/dataFiles"

# Run Anduril
time anduril "run-component" "Cutadapt" --bundle "${root}/bundle" --execution-dir "$execDir" --log "${execDir}/Cutadapt/log" \
 -I INFILE_input="${inputDir}/100.fq" \
 -I INFILE_input_mate="${inputDir}/100.fq" \
 -P _OUTFILE_paired_output="true" \
 -P adapter="{{[[AAAA//CCCC//GGGG//TTTT]]}}" \
 -P A="{{[[AAAA//CCCC//GGGG//TTTT]]}}" \
 -P trim_n="{{TRUE}}" \
 -P _execMode="remote"
