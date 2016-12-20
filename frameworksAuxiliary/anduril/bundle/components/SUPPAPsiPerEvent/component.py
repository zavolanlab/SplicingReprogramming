#!/usr/bin/env python

# Import modules
import sys
import anduril
import anduril_custom_functions
from anduril.args import *

# Command template
command = '{_executable}$$$--mode^^^{mode}$$$--total-filter^^^{total_filter}$$$--expression-file^^^INFILE_expression_file$$$--ioe-file^^^INFILE_ioe_file$$$--output-file^^^OUTFILE_output_file'.format(_executable=_executable, mode=mode, total_filter=total_filter)

# Execute command
exit_status = anduril_custom_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
