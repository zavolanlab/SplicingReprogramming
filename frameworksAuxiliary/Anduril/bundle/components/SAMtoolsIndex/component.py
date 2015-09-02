#!/usr/bin/env python

# Import modules
import sys
import anduril
import krini_functions
from anduril.args import *

# Command template
command = '{_executable}$$$infile###INFILE_infile$$$outfile###OUTFILE_outfile'.format(_executable=_executable)

# Execute command
exit_status = krini_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
