#!/usr/bin/env python

# Import modules
import sys
import anduril
import krini_functions
from anduril.args import *

# Command template
command = '{_executable}$$$--MEOP^^^{MEOP}$$$--SEGEMEHL^^^{SEGEMEHL}$$$--accuracy^^^{accuracy}$$$--autoclip^^^{autoclip}$$$--brief^^^{brief}$$$--checkidx^^^{checkidx}$$$--clipacc^^^{clipacc}$$$--differences^^^{differences}$$$--dropoff^^^{dropoff}$$$--evalue^^^{evalue}$$$--extensionpenalty^^^{extensionpenalty}$$$--extensionscore^^^{extensionscore}$$$--hardclip^^^{hardclip}$$$--hitstrategy^^^{hitstrategy}$$$--jump^^^{jump}$$$--maxinsertsize^^^{maxinsertsize}$$$--maxinterval^^^{maxinterval}$$$--maxout^^^{maxout}$$$--maxsplitevalue^^^{maxsplitevalue}$$$--minfraglen^^^{minfraglen}$$$--minfragscore^^^{minfragscore}$$$--minsize^^^{minsize}$$$--minsplicecover^^^{minsplicecover}$$$--nohead^^^{nohead}$$$--order^^^{order}$$$--polyA^^^{polyA}$$$--prime3^^^{prime3}$$$--prime5^^^{prime5}$$$--showalign^^^{showalign}$$$--silent^^^{silent}$$$--splicescorescale^^^{splicescorescale}$$$--threads^^^{threads}$$$--database^^^INFILE_database$$$--index^^^INFILE_index$$$--index2^^^INFILE_index2$$$--mate^^^INFILE_mate$$$--query^^^INFILE_query$$$--generate^^^OUTFILE_generate$$$--generate2^^^OUTFILE_generate2$$$--nomatchfilename^^^OUTFILE_nomatchfilename$$$--outfile^^^OUTFILE_outfile'.format(_executable=_executable, MEOP=MEOP, SEGEMEHL=SEGEMEHL, accuracy=accuracy, autoclip=autoclip, brief=brief, checkidx=checkidx, clipacc=clipacc, differences=differences, dropoff=dropoff, evalue=evalue, extensionpenalty=extensionpenalty, extensionscore=extensionscore, hardclip=hardclip, hitstrategy=hitstrategy, jump=jump, maxinsertsize=maxinsertsize, maxinterval=maxinterval, maxout=maxout, maxsplitevalue=maxsplitevalue, minfraglen=minfraglen, minfragscore=minfragscore, minsize=minsize, minsplicecover=minsplicecover, nohead=nohead, order=order, polyA=polyA, prime3=prime3, prime5=prime5, showalign=showalign, silent=silent, splicescorescale=splicescorescale, threads=threads)

# Execute command
exit_status = krini_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
