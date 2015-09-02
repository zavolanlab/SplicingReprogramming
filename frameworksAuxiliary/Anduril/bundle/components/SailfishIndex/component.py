#!/usr/bin/env python

# Import modules
import sys
import anduril
import krini_functions
from anduril.args import *

# Command template
command = '{_executable}$$$--force^^^{force}$$$--kmerSize^^^{kmerSize}$$$--threads^^^{threads}$$$--tgmap^^^INFILE_tgmap$$$--transcripts^^^INFILE_transcripts$$$--out^^^OUTDIR_out$$$&>^^^OUTFILE_report'.format(_executable=_executable, force=force, kmerSize=kmerSize, threads=threads)

# Execute command
exit_status = krini_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
