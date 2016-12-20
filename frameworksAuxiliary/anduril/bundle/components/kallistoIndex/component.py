#!/usr/bin/env python

# Import modules
import sys
import anduril
import anduril_custom_functions
from anduril.args import *

# Command template
command = '{_executable}$$$--kmer-size^^^{kmer_size}$$$--make-unique^^^{make_unique}$$$--index^^^OUTFILE_index$$$refseqs###INFILE_refseqs'.format(_executable=_executable, kmer_size=kmer_size, make_unique=make_unique)

# Execute command
exit_status = anduril_custom_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
