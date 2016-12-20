#!/usr/bin/env python

# Import modules
import sys
import anduril
import anduril_custom_functions
from anduril.args import *

# Command template
command = '{_executable}$$$--counts^^^{counts}$$$--round^^^{round}$$$--sampleName^^^{sampleName}$$$--verbose^^^{verbose}$$$--inputDir^^^INDIR_inputDir$$$--outFile^^^OUTFILE_outFile'.format(_executable=_executable, counts=counts, round=round, sampleName=sampleName, verbose=verbose)

# Execute command
exit_status = anduril_custom_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
