#!/usr/bin/env python

# Import modules
import sys
import anduril
import krini_functions
from anduril.args import *

# Command template
command = '{_executable}$$$-B^^^{B}$$$-C^^^{C}$$$-F^^^{F}$$$-H^^^{H}$$$-1.0^^^{_10}$$$-@^^^{at}$$$-b^^^{b}$$$-c^^^{c}$$$-f^^^{f}$$$-h^^^{h}$$$-l^^^{l}$$$-m^^^{m}$$$-q^^^{q}$$$-r^^^{r}$$$-s^^^{s}$$$-u^^^{u}$$$-x^^^{x}$$$-L^^^INFILE_L$$$-R^^^INFILE_R$$$-T^^^INFILE_T$$$-t^^^INFILE_t$$$-U^^^OUTFILE_U$$$-o^^^OUTFILE_o$$$infile###INFILE_infile$$$region###{region}'.format(_executable=_executable, B=B, C=C, F=F, H=H, _10=_10, at=at, b=b, c=c, f=f, h=h, l=l, m=m, q=q, r=r, s=s, u=u, x=x, region=region)

# Execute command
exit_status = krini_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
