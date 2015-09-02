#!/usr/bin/env python

# Import modules
import sys
import anduril
import krini_functions
from anduril.args import *

# Command template
command = '{_executable}$$$-A^^^{A}$$$-B^^^{B}$$$-G^^^{G}$$$-U^^^{U}$$$--adapter^^^{adapter}$$$--anywhere^^^{anywhere}$$$--bwa^^^{bwa}$$$--colorspace^^^{colorspace}$$$--cut^^^{cut}$$$--discard-trimmed^^^{discard_trimmed}$$$--discard-untrimmed^^^{discard_untrimmed}$$$--double-encode^^^{double_encode}$$$--error-rate^^^{error_rate}$$$--format^^^{format}$$$--front^^^{front}$$$--length-tag^^^{length_tag}$$$--maq^^^{maq}$$$--mask-adapter^^^{mask_adapter}$$$--match-read-wildcards^^^{match_read_wildcards}$$$--max-n^^^{max_n}$$$--maximum-length^^^{maximum_length}$$$--minimum-length^^^{minimum_length}$$$--no-indels^^^{no_indels}$$$--no-trim^^^{no_trim}$$$--no-zero-cap^^^{no_zero_cap}$$$--overlap^^^{overlap}$$$--prefix^^^{prefix}$$$--quality-base^^^{quality_base}$$$--quality-cutoff^^^{quality_cutoff}$$$--quiet^^^{quiet}$$$--strip-f3^^^{strip_f3}$$$--strip-suffix^^^{strip_suffix}$$$--suffix^^^{suffix}$$$--times^^^{times}$$$--trim-n^^^{trim_n}$$$--trim-primer^^^{trim_primer}$$$--info-file^^^OUTFILE_info_file$$$--output^^^OUTFILE_output$$$--paired-output^^^OUTFILE_paired_output$$$--rest-file^^^OUTFILE_rest_file$$$--too-long-output^^^OUTFILE_too_long_output$$$--too-short-output^^^OUTFILE_too_short_output$$$--untrimmed-output^^^OUTFILE_untrimmed_output$$$--untrimmed-paired-output^^^OUTFILE_untrimmed_paired_output$$$--wildcard-file^^^OUTFILE_wildcard_file$$$input###INFILE_input$$$input-mate###INFILE_input_mate$$$>###OUTFILE_report'.format(_executable=_executable, A=A, B=B, G=G, U=U, adapter=adapter, anywhere=anywhere, bwa=bwa, colorspace=colorspace, cut=cut, discard_trimmed=discard_trimmed, discard_untrimmed=discard_untrimmed, double_encode=double_encode, error_rate=error_rate, format=format, front=front, length_tag=length_tag, maq=maq, mask_adapter=mask_adapter, match_read_wildcards=match_read_wildcards, max_n=max_n, maximum_length=maximum_length, minimum_length=minimum_length, no_indels=no_indels, no_trim=no_trim, no_zero_cap=no_zero_cap, overlap=overlap, prefix=prefix, quality_base=quality_base, quality_cutoff=quality_cutoff, quiet=quiet, strip_f3=strip_f3, strip_suffix=strip_suffix, suffix=suffix, times=times, trim_n=trim_n, trim_primer=trim_primer)

# Execute command
exit_status = krini_functions.main(component, command, tempdir)

# Return exit status
sys.exit(exit_status)
