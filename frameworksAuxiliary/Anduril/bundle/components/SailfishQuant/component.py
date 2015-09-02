#!/usr/bin/env python

# Import modules
import sys
import anduril
import krini_functions
from anduril.args import *

# Command template
command = '{_executable}$$$--delta^^^{delta}$$$--force^^^{force}$$$--iterations^^^{iterations}$$$--libtype^^^{libtype}$$$--min_abundance^^^{min_abundance}$$$--no_bias_correct^^^{no_bias_correct}$$$--polya^^^{polya}$$$--threads^^^{threads}$$$--index^^^INDIR_index$$$--mates1^^^INFILE_mates1$$$--mates2^^^INFILE_mates2$$$--unmated_reads^^^INFILE_unmated_reads$$$--out^^^OUTDIR_out$$$&>^^^OUTFILE_report'.format(_executable=_executable, delta=delta, force=force, iterations=iterations, libtype=libtype, min_abundance=min_abundance, no_bias_correct=no_bias_correct, polya=polya, threads=threads)

# Execute command
exit_status = krini_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
