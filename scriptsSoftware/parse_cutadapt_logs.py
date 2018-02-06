#!/usr/bin/env python

"""Writes a table listing the self-reported statistics of multiple cutadapt runs."""

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
    if not haveHeader:
        header.append("Identifier")

    # Read lines into list
    with open(f) as handle:
        lines = handle.readlines()

    # Iterate over lines
    for line in lines:

        # Check for command
        if line.startswith("Command line parameters:"):
            line_list = line.split(":")
            values.append(line_list[1].strip())
            if not haveHeader:
                header.append("Command")

        # Check for processed reads (single-ended)
        if line.startswith("Total reads processed:"):
            line_list = line.split(":")
            values.append("SINGLE")
            values.append(line_list[1].strip().translate(None, ','))
            if not haveHeader:
                header.append("Library type")
                header.append("Read/read pairs processed")

        # Check for processed reads (paired-end)
        if line.startswith("Total read pairs processed:"):
            line_list = line.split(":")
            values.append("PAIRED")
            values.append(line_list[1].strip().translate(None, ','))
            if not haveHeader:
                header.append("Library type")
                header.append("Read/read pairs processed")

        # Check for processed reads (single-end)
        if line.startswith("Reads with adapters:"):
            line_list = line.split(":")
            val_list = line_list[1].strip().split(" ")
            values.append(val_list[0].strip().translate(None, ','))
            values.append("NA")
            if not haveHeader:
                header.append("Reads/mates 1 with adapters")
                header.append("Mates 2 with adapters")

        # Check for processed reads (paired-end, mate 1)
        if line.strip().startswith("Read 1 with adapter:"):
            line_list = line.split(":")
            val_list = line_list[1].strip().split(" ")
            values.append(val_list[0].strip().translate(None, ','))
            if not haveHeader:
                header.append("Reads/mates 1 with adapters")

        # Check for processed reads (paired-end, mate 2)
        if line.strip().startswith("Read 2 with adapter:"):
            line_list = line.split(":")
            val_list = line_list[1].strip().split(" ")
            values.append(val_list[0].strip().translate(None, ','))
            if not haveHeader:
                header.append("Mates 2 with adapters")

        # Check for too short reads
        if line.startswith("Reads that were too short:") or line.startswith("Pairs that were too short:"):
            line_list = line.split(":")
            val_list = line_list[1].strip().split(" ")
            values.append(val_list[0].strip().translate(None, ','))
            if not haveHeader:
                header.append("Too short reads/pairs")

        # Check for too many Ns
        if line.startswith("Reads with too many N:") or line.startswith("Pairs with too many N:"):
            line_list = line.split(":")
            val_list = line_list[1].strip().split(" ")
            values.append(val_list[0].strip().translate(None, ','))
            if not haveHeader:
                header.append("Reads/pairs with too many Ns")

        # Check for written reads/pairs
        if line.startswith("Reads written (passing filters):") or line.startswith("Pairs written (passing filters):"):
            line_list = line.split(":")
            val_list = line_list[1].strip().split(" ")
            values.append(val_list[0].strip().translate(None, ','))
            if not haveHeader:
                header.append("Reads/pairs that passed filters")

        # Check for processed basepairs
        if line.startswith("Total basepairs processed:"):
            idx = lines.index(line)
            line_list = line.split(":")
            val_list = line_list[1].strip().split(" ")
            values.append(val_list[0].strip().translate(None, ','))
            if lines[idx+1].strip().startswith("Read 1:"):
                line_list = lines[idx+1].split(":")
                val_list = line_list[1].strip().split(" ")
                values.append(val_list[0].strip().translate(None, ','))
                line_list = lines[idx+2].split(":")
                val_list = line_list[1].strip().split(" ")
                values.append(val_list[0].strip().translate(None, ','))
            else:
                values.append("NA")
                values.append("NA")
            if not haveHeader:
                header.append("Bases processed")
                header.append("Mate 1 bases processed")
                header.append("Mate 2 bases processed")

        # Check for written basepairs
        if line.startswith("Total written (filtered):"):
            idx = lines.index(line)
            line_list = line.split(":")
            val_list = line_list[1].strip().split(" ")
            values.append(val_list[0].strip().translate(None, ','))
            if lines[idx+1].strip().startswith("Read 1:"):
                line_list = lines[idx+1].split(":")
                val_list = line_list[1].strip().split(" ")
                values.append(val_list[0].strip().translate(None, ','))
                line_list = lines[idx+2].split(":")
                val_list = line_list[1].strip().split(" ")
                values.append(val_list[0].strip().translate(None, ','))
            else:
                values.append("NA")
                values.append("NA")
            if not haveHeader:
                header.append("Bases written")
                header.append("Mate 1 bases written")
                header.append("Mate 2 bases written")

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
sys.stdout.write("{0}\n".format(header))
for value_string in values_container:
    sys.stdout.write("{0}\n".format(value_string))

# Write log
sys.stderr.write("Done.\n")
