#!/usr/bin/env python

# Import modules
import sys
import anduril
import krini_functions
from anduril.args import *

# Command template
command = '{_executable}$$$--quiet^^^{quiet}$$$--sam^^^INFILE_sam$$$--body^^^OUTFILE_body$$$--head^^^OUTFILE_head'.format(_executable=_executable, quiet=quiet)

# Execute command
exit_status = krini_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
