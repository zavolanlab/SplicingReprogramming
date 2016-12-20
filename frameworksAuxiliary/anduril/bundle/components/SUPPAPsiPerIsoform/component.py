#!/usr/bin/env python

# Import modules
import sys
import anduril
import anduril_custom_functions
from anduril.args import *

# Command template
command = '{_executable}$$$--mode^^^{mode}$$$--expression-file^^^INFILE_expression_file$$$--gtf-file^^^INFILE_gtf_file$$$--output-file^^^OUTFILE_output_file'.format(_executable=_executable, mode=mode)

# Execute command
exit_status = anduril_custom_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
