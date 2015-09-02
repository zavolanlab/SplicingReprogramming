#!/bin/bash

# Set root directory
root="/import/bc2/home/zavolan/kanitz/PROJECTS/SpliceFactorsReprogramming/frameworksAuxiliary/Anduril"
execDir="${root}/bundle/components/__TEST__/output"
inputDir="${root}/bundle/components/__TEST__/dataFiles"

# Run Anduril
time anduril "run-component" "kallistoHDF5dump" --bundle "${root}/bundle" --execution-dir "$execDir" --log "${execDir}/kallistoHDF5dump/log" \
 -I INFILE_refseqs="${inputDir}/kallisto.hdf5" \
 -P _execMode="remote"
