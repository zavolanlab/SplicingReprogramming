#!/usr/bin/env python

# Import modules
import sys
import anduril
import krini_functions
from anduril.args import *

# Command template
command = '{_executable}$$$-O^^^{O}$$$-T^^^{T}$$$-@^^^{at}$$$-l^^^{l}$$$-m^^^{m}$$$-n^^^{n}$$$-o^^^OUTFILE_o$$$infile###INFILE_infile'.format(_executable=_executable, O=O, T=T, at=at, l=l, m=m, n=n)

# Execute command
exit_status = krini_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
