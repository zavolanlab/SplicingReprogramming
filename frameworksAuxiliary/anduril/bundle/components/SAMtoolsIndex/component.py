#!/usr/bin/env python

# Import modules
import sys
import anduril
import anduril_custom_functions
from anduril.args import *

# Command template
command = '{_executable}$$$-b^^^{b}$$$-c^^^{c}$$$-m^^^{m}$$$infile###INFILE_infile$$$outfile###OUTFILE_outfile'.format(_executable=_executable, b=b, c=c, m=m)

# Execute command
exit_status = anduril_custom_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
