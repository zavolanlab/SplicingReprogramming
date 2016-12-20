#!/usr/bin/env python

# Import modules
import sys
import anduril
import anduril_custom_functions
from anduril.args import *

# Command template
command = '{_executable}$$$--boundary^^^{boundary}$$$--event-type^^^{event_type}$$$--exon-length^^^{exon_length}$$$--mode^^^{mode}$$$--pool-genes^^^{pool_genes}$$$--threshold^^^{threshold}$$$--input-file^^^INFILE_input_file$$$--output-file^^^OUTDIRMAKE_output_file'.format(_executable=_executable, boundary=boundary, event_type=event_type, exon_length=exon_length, mode=mode, pool_genes=pool_genes, threshold=threshold)

# Execute command
exit_status = anduril_custom_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
