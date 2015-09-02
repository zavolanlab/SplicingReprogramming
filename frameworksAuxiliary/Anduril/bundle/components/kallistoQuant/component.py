#!/usr/bin/env python

# Import modules
import sys
import anduril
import krini_functions
from anduril.args import *

# Command template
command = '{_executable}$$$--bias^^^{bias}$$$--bootstrap-samples^^^{bootstrap_samples}$$$--fragment-length^^^{fragment_length}$$$--plaintext^^^{plaintext}$$$--sd^^^{sd}$$$--seed^^^{seed}$$$--single^^^{single}$$$--threads^^^{threads}$$$--index^^^INFILE_index$$$--output-dir^^^OUTDIR_output_dir$$$readseqs###INFILE_readseqs$$$>^^^OUTFILE_pseudobam'.format(_executable=_executable, bias=bias, bootstrap_samples=bootstrap_samples, fragment_length=fragment_length, plaintext=plaintext, sd=sd, seed=seed, single=single, threads=threads)

# Execute command
exit_status = krini_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
