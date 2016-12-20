#!/usr/bin/env python

# Import modules
import sys
import anduril
import anduril_custom_functions
from anduril.args import *

# Command template
command = '{_executable}$$$--aligned^^^{aligned}$$$--bzip^^^{bzip}$$$--disable-multithreading^^^{disable_multithreading}$$$--fasta^^^{fasta}$$$--gzip^^^{gzip}$$$--keep-empty-files^^^{keep_empty_files}$$$--log-level^^^{log_level}$$$--minReadLen^^^{minReadLen}$$$--offset^^^{offset}$$$--split-files^^^{split_files}$$$--unaligned^^^{unaligned}$$$--outdir^^^OUTDIR_outdir$$$infile###INFILE_infile'.format(_executable=_executable, aligned=aligned, bzip=bzip, disable_multithreading=disable_multithreading, fasta=fasta, gzip=gzip, keep_empty_files=keep_empty_files, log_level=log_level, minReadLen=minReadLen, offset=offset, split_files=split_files, unaligned=unaligned)

# Execute command
exit_status = anduril_custom_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
