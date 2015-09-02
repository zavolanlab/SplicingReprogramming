#!/usr/bin/env python

# Import modules
import sys
import anduril
import krini_functions
from anduril.args import *

# Command template
command = '{_executable}$$$--multimappers^^^{multimappers}$$$--sam^^^INFILE_sam$$$--mean^^^OUTFILE_mean$$$--sd^^^OUTFILE_sd'.format(_executable=_executable, multimappers=multimappers)

# Execute command
exit_status = krini_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
