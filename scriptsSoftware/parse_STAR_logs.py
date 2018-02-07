#!/usr/bin/env python

"""Writes a table listing the self-reported statistics of multiple STAR runs."""

__author__ = "Alexander Kanitz"
__copyright__ = "Copyright 2016, Biozentrum, University of Basel"
__license__ = "MIT"
__version__ = "1.0.0"
__maintainer__ = "Alexander Kanitz"
__email__ = "alexander.kanitz@alumni.ethz.ch"

# Import packages
import os
import sys
import glob
import re

# Assign CLI arguments
indir = str(sys.argv[1])
prefix = str(sys.argv[2])
suffix = str(sys.argv[3])

# Write log
sys.stderr.write("Compiling alignment statistics table from files in directory '{}'...\n".format(indir))

# Build glob expression
glob_exp = "{0}/*{1}".format(indir, suffix)

# Initialize container list
values_container = list()

# Initialize header list and switch
header = list()
haveHeader = False

# Get matching files
files = sorted(glob.glob(glob_exp))

# Iterate over files
for f in files:

    # Write log
    sys.stderr.write("Processing file '{}'...\n".format(os.path.basename(f)))

    # Initialize values list
    values = list()

    # Add file identifier (basename of filename minus prefix and suffix) to values list
    values.append(os.path.basename(f[len(prefix):-len(suffix)]))

    # Read lines into list
    with open(f) as handle:
        lines = handle.readlines()

    # Iterate over lines
    for line in lines:
        # Split lines by separator
        line_list = line.split("|")
        # If line contains key and value...
        if len(line_list) == 2:
            # ...add values to list
            values.append(line_list[1].strip())
            # ...and if header switch not yet set...
            if not haveHeader:
                # ...add keys to header list
                header.append(line_list[0].strip())

    # Add values string to container
    values_container.append("\t".join(values))

    # If header switch not set...
    if not haveHeader and len(header):
        # ...convert header list to string
        header = "\t".join(header)
        # ...and set header switch
        haveHeader = True

# Write log
sys.stderr.write("Writing output to STDOUT...\n")

# Write output
sys.stdout.write("Identifier\t{0}\n".format(header))
for value_string in values_container:
    sys.stdout.write("{0}\n".format(value_string))

# Write log
sys.stderr.write("Done.\n")
