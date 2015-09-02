#!/usr/bin/env python

# Import modules
import sys
import anduril
import krini_functions
from anduril.args import *

# Command template
command = '{_executable}$$$--head^^^{head}$$$--include-monoexonic^^^{include_monoexonic}$$$--min-overlap^^^{min_overlap}$$$--no-strand-info^^^{no_strand_info}$$$--quiet^^^{quiet}$$$--tag^^^{tag}$$$--exons^^^INFILE_exons$$$--in^^^INFILE_in$$$--out^^^OUTFILE_out$$$>^^^OUTFILE_print_report'.format(_executable=_executable, head=head, include_monoexonic=include_monoexonic, min_overlap=min_overlap, no_strand_info=no_strand_info, quiet=quiet, tag=tag)

# Execute command
exit_status = krini_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
