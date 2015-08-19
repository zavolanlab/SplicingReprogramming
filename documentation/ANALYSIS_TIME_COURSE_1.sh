#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 19-AUG-2015                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# TODO Fill in


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Set wrapper parent directory as root directory
root=$(cd "$(dirname $(dirname "$0" ))" && pwd)


##################################
###  GET SEQUENCING LIBRARIES  ###
##################################

# TODO
# Currently, sequencing libraries are copied from the transfer directory of the sequencing facility.
# Eventually, libraries should be uploaded to the SRA repository and the script adapted to use the
# files as downloaded from there.

# Copy raw FASTQ files and metadata from transfer directory
# TODO TO BE REPLACED BY REPOSITORY DOWNLOADS
# cp /import/bc2/transfer/group_nz/bsse/2014-07-23/* "${root}/rawData"

# List of library and metadata files
# TODO TO BE REMOVED
# ls ${root}/rawData
# BSSE_QGF_21869_140718_SN792_0354_BC550KACXX_1_CGATGTA-NoIndex_L001_Day0_MEFs_metadata.tsv
# BSSE_QGF_21869_140718_SN792_0354_BC550KACXX_1_CGATGT_L001_R1_001_Day0_MEFs.fastq.gz
# BSSE_QGF_21869_21871_21873_21875_22014_140718_SN792_0354_BC550KACXX_lane1_Undetermined_L001_R1_001.fastq.gz
# BSSE_QGF_21871_140718_SN792_0354_BC550KACXX_1_ACAGTGA-NoIndex_L001_Day1Red_metadata.tsv
# BSSE_QGF_21871_140718_SN792_0354_BC550KACXX_1_ACAGTG_L001_R1_001_Day1Red.fastq.gz
# BSSE_QGF_21873_140718_SN792_0354_BC550KACXX_1_GCCAATA-NoIndex_L001_Day1E1_metadata.tsv
# BSSE_QGF_21873_140718_SN792_0354_BC550KACXX_1_GCCAAT_L001_R1_001_Day1E1.fastq.gz
# BSSE_QGF_21875_140718_SN792_0354_BC550KACXX_1_CAGATCA-NoIndex_L001_Day2C_metadata.tsv
# BSSE_QGF_21875_140718_SN792_0354_BC550KACXX_1_CAGATC_L001_R1_001_Day2C.fastq.gz
# BSSE_QGF_21877_140718_SN792_0354_BC550KACXX_2_TGACCAA-NoIndex_L002_Day1C_metadata.tsv
# BSSE_QGF_21877_140718_SN792_0354_BC550KACXX_2_TGACCA_L002_R1_001_Day1C.fastq.gz
# BSSE_QGF_21877_21879_21881_21883_22015_140718_SN792_0354_BC550KACXX_lane2_Undetermined_L002_R1_001.fastq.gz
# BSSE_QGF_21879_140718_SN792_0354_BC550KACXX_2_ACAGTGA-NoIndex_L002_Day3C_metadata.tsv
# BSSE_QGF_21879_140718_SN792_0354_BC550KACXX_2_ACAGTG_L002_R1_001_Day3C.fastq.gz
# BSSE_QGF_21879_140718_SN792_0354_BC550KACXX_2_ACAGTG_L002_R1_002_Day3C.fastq.gz
# BSSE_QGF_21881_140718_SN792_0354_BC550KACXX_2_CAGATCA-NoIndex_L002_Day2Red_metadata.tsv
# BSSE_QGF_21881_140718_SN792_0354_BC550KACXX_2_CAGATC_L002_R1_001_Day2Red.fastq.gz
# BSSE_QGF_21883_140718_SN792_0354_BC550KACXX_2_CTTGTAA-NoIndex_L002_Day2E1_metadata.tsv
# BSSE_QGF_21883_140718_SN792_0354_BC550KACXX_2_CTTGTA_L002_R1_001_Day2E1.fastq.gz
# BSSE_QGF_21885_140718_SN792_0354_BC550KACXX_3_ACAGTGA-NoIndex_L003_Day4Red_metadata.tsv
# BSSE_QGF_21885_140718_SN792_0354_BC550KACXX_3_ACAGTG_L003_R1_001_Day4Red.fastq.gz
# BSSE_QGF_21885_21887_21889_21891_22016_140718_SN792_0354_BC550KACXX_lane3_Undetermined_L003_R1_001.fastq.gz
# BSSE_QGF_21887_140718_SN792_0354_BC550KACXX_3_GCCAATA-NoIndex_L003_Day3Red_metadata.tsv
# BSSE_QGF_21887_140718_SN792_0354_BC550KACXX_3_GCCAAT_L003_R1_001_Day3Red.fastq.gz
# BSSE_QGF_21889_140718_SN792_0354_BC550KACXX_3_CAGATCA-NoIndex_L003_Day3E1_metadata.tsv
# BSSE_QGF_21889_140718_SN792_0354_BC550KACXX_3_CAGATC_L003_R1_001_Day3E1.fastq.gz
# BSSE_QGF_21891_140718_SN792_0354_BC550KACXX_3_CTTGTAA-NoIndex_L003_Day4C_metadata.tsv
# BSSE_QGF_21891_140718_SN792_0354_BC550KACXX_3_CTTGTA_L003_R1_001_Day4C.fastq.gz
# BSSE_QGF_21893_140718_SN792_0354_BC550KACXX_4_ACAGTGA-NoIndex_L004_Day5C_metadata.tsv
# BSSE_QGF_21893_140718_SN792_0354_BC550KACXX_4_ACAGTG_L004_R1_001_Day5C.fastq.gz
# BSSE_QGF_21893_21895_21897_21899_22017_140718_SN792_0354_BC550KACXX_lane4_Undetermined_L004_R1_001.fastq.gz
# BSSE_QGF_21895_140718_SN792_0354_BC550KACXX_4_GCCAATA-NoIndex_L004_Day4E1_metadata.tsv
# BSSE_QGF_21895_140718_SN792_0354_BC550KACXX_4_GCCAAT_L004_R1_001_Day4E1.fastq.gz
# BSSE_QGF_21897_140718_SN792_0354_BC550KACXX_4_CAGATCA-NoIndex_L004_Day5Red_metadata.tsv
# BSSE_QGF_21897_140718_SN792_0354_BC550KACXX_4_CAGATC_L004_R1_001_Day5Red.fastq.gz
# BSSE_QGF_21899_140718_SN792_0354_BC550KACXX_4_CTTGTAA-NoIndex_L004_Day5E1_metadata.tsv
# BSSE_QGF_21899_140718_SN792_0354_BC550KACXX_4_CTTGTA_L004_R1_001_Day5E1.fastq.gz
# BSSE_QGF_21901_140718_SN792_0354_BC550KACXX_6_TGACCAA-NoIndex_L006_Day6C_metadata.tsv
# BSSE_QGF_21901_140718_SN792_0354_BC550KACXX_6_TGACCA_L006_R1_001_Day6C.fastq.gz
# BSSE_QGF_21901_140718_SN792_0354_BC550KACXX_6_TGACCA_L006_R1_002_Day6C.fastq.gz
# BSSE_QGF_21901_21903_21905_22018_140718_SN792_0354_BC550KACXX_lane6_Undetermined_L006_R1_001.fastq.gz
# BSSE_QGF_21903_140718_SN792_0354_BC550KACXX_6_GCCAATA-NoIndex_L006_Day6Red_metadata.tsv
# BSSE_QGF_21903_140718_SN792_0354_BC550KACXX_6_GCCAAT_L006_R1_001_Day6Red.fastq.gz
# BSSE_QGF_21903_140718_SN792_0354_BC550KACXX_6_GCCAAT_L006_R1_002_Day6Red.fastq.gz
# BSSE_QGF_21905_140718_SN792_0354_BC550KACXX_6_CTTGTAA-NoIndex_L006_Day6E1_metadata.tsv
# BSSE_QGF_21905_140718_SN792_0354_BC550KACXX_6_CTTGTA_L006_R1_001_Day6E1.fastq.gz
# BSSE_QGF_21905_140718_SN792_0354_BC550KACXX_6_CTTGTA_L006_R1_002_Day6E1.fastq.gz
# BSSE_QGF_21907_140718_SN792_0354_BC550KACXX_7_TGACCAA-NoIndex_L007_Day7C_metadata.tsv
# BSSE_QGF_21907_140718_SN792_0354_BC550KACXX_7_TGACCA_L007_R1_001_Day7C.fastq.gz
# BSSE_QGF_21907_140718_SN792_0354_BC550KACXX_7_TGACCA_L007_R1_002_Day7C.fastq.gz
# BSSE_QGF_21907_21909_21911_22019_140718_SN792_0354_BC550KACXX_lane7_Undetermined_L007_R1_001.fastq.gz
# BSSE_QGF_21909_140718_SN792_0354_BC550KACXX_7_GCCAATA-NoIndex_L007_Day7Red_metadata.tsv
# BSSE_QGF_21909_140718_SN792_0354_BC550KACXX_7_GCCAAT_L007_R1_001_Day7Red.fastq.gz
# BSSE_QGF_21909_140718_SN792_0354_BC550KACXX_7_GCCAAT_L007_R1_002_Day7Red.fastq.gz
# BSSE_QGF_21911_140718_SN792_0354_BC550KACXX_7_CTTGTAA-NoIndex_L007_Day7E1_metadata.tsv
# BSSE_QGF_21911_140718_SN792_0354_BC550KACXX_7_CTTGTA_L007_R1_001_Day7E1.fastq.gz
# BSSE_QGF_21911_140718_SN792_0354_BC550KACXX_7_CTTGTA_L007_R1_002_Day7E1.fastq.gz
# BSSE_QGF_21913_140718_SN792_0354_BC550KACXX_8_TGACCAA-NoIndex_L008_Day8C_metadata.tsv
# BSSE_QGF_21913_140718_SN792_0354_BC550KACXX_8_TGACCA_L008_R1_001_Day8C.fastq.gz
# BSSE_QGF_21913_140718_SN792_0354_BC550KACXX_8_TGACCA_L008_R1_002_Day8C.fastq.gz
# BSSE_QGF_21913_21915_21917_22020_140718_SN792_0354_BC550KACXX_lane8_Undetermined_L008_R1_001.fastq.gz
# BSSE_QGF_21915_140718_SN792_0354_BC550KACXX_8_GCCAATA-NoIndex_L008_Day8Red_metadata.tsv
# BSSE_QGF_21915_140718_SN792_0354_BC550KACXX_8_GCCAAT_L008_R1_001_Day8Red.fastq.gz
# BSSE_QGF_21915_140718_SN792_0354_BC550KACXX_8_GCCAAT_L008_R1_002_Day8Red.fastq.gz
# BSSE_QGF_21917_140718_SN792_0354_BC550KACXX_8_CTTGTAA-NoIndex_L008_Day8E1_metadata.tsv
# BSSE_QGF_21917_140718_SN792_0354_BC550KACXX_8_CTTGTA_L008_R1_001_Day8E1.fastq.gz
# BSSE_QGF_21917_140718_SN792_0354_BC550KACXX_8_CTTGTA_L008_R1_002_Day8E1.fastq.gz
# BSSE_QGF_22014_140718_SN792_0354_BC550KACXX_1_NoIndex-NoIndex_L001_metadata.tsv
# BSSE_QGF_22015_140718_SN792_0354_BC550KACXX_2_NoIndex-NoIndex_L002_metadata.tsv
# BSSE_QGF_22016_140718_SN792_0354_BC550KACXX_3_NoIndex-NoIndex_L003_metadata.tsv
# BSSE_QGF_22017_140718_SN792_0354_BC550KACXX_4_NoIndex-NoIndex_L004_metadata.tsv
# BSSE_QGF_22018_140718_SN792_0354_BC550KACXX_6_NoIndex-NoIndex_L006_metadata.tsv
# BSSE_QGF_22019_140718_SN792_0354_BC550KACXX_7_NoIndex-NoIndex_L007_metadata.tsv
# BSSE_QGF_22020_140718_SN792_0354_BC550KACXX_8_NoIndex-NoIndex_L008_metadata.tsv

# Concatenate files
# TODO TO BE REPLACED BY FORMAT CONVERSION, IF REQUIRED
# zcat "${root}/rawData/BSSE_QGF_21879_140718_SN792_0354_BC550KACXX_2_ACAGTG_L002_R1_001_Day3C.fastq.gz" "${root}/rawData/_QGF_21879_140718_SN792_0354_BC550KACXX_2_ACAGTG_L002_R1_002_Day3C.fastq.gz" | gzip > "${root}/rawData/concatenated/BSSE_QGF_21879_140718_SN792_0354_BC550KACXX_2_ACAGTG_L002_R1_cat_Day3C.fastq.gz"
# zcat "${root}/rawData/BSSE_QGF_21901_140718_SN792_0354_BC550KACXX_6_TGACCA_L006_R1_001_Day6C.fastq.gz" "${root}/rawData/_QGF_21901_140718_SN792_0354_BC550KACXX_6_TGACCA_L006_R1_002_Day6C.fastq.gz" | gzip > "${root}/rawData/concatenated/BSSE_QGF_21901_140718_SN792_0354_BC550KACXX_6_TGACCA_L006_R1_cat_Day6C.fastq.gz"
# zcat "${root}/rawData/BSSE_QGF_21903_140718_SN792_0354_BC550KACXX_6_GCCAAT_L006_R1_001_Day6Red.fastq.gz" "${root}/rawData/_QGF_21903_140718_SN792_0354_BC550KACXX_6_GCCAAT_L006_R1_002_Day6Red.fastq.gz" | gzip > "${root}/rawData/concatenated/BSSE_QGF_21903_140718_SN792_0354_BC550KACXX_6_GCCAAT_L006_R1_cat_Day6Red.fastq.gz"
# zcat "${root}/rawData/BSSE_QGF_21905_140718_SN792_0354_BC550KACXX_6_CTTGTA_L006_R1_001_Day6E1.fastq.gz" "${root}/rawData/_QGF_21905_140718_SN792_0354_BC550KACXX_6_CTTGTA_L006_R1_002_Day6E1.fastq.gz" | gzip > "${root}/rawData/concatenated/BSSE_QGF_21905_140718_SN792_0354_BC550KACXX_6_CTTGTA_L006_R1_cat_Day6E1.fastq.gz"
# zcat "${root}/rawData/BSSE_QGF_21907_140718_SN792_0354_BC550KACXX_7_TGACCA_L007_R1_001_Day7C.fastq.gz" "${root}/rawData/_QGF_21907_140718_SN792_0354_BC550KACXX_7_TGACCA_L007_R1_002_Day7C.fastq.gz" | gzip > "${root}/rawData/concatenated/BSSE_QGF_21907_140718_SN792_0354_BC550KACXX_7_TGACCA_L007_R1_cat_Day7C.fastq.gz"
# zcat "${root}/rawData/BSSE_QGF_21909_140718_SN792_0354_BC550KACXX_7_GCCAAT_L007_R1_001_Day7Red.fastq.gz" "${root}/rawData/_QGF_21909_140718_SN792_0354_BC550KACXX_7_GCCAAT_L007_R1_002_Day7Red.fastq.gz" | gzip > "${root}/rawData/concatenated/BSSE_QGF_21909_140718_SN792_0354_BC550KACXX_7_GCCAAT_L007_R1_cat_Day7Red.fastq.gz"
# zcat "${root}/rawData/BSSE_QGF_21911_140718_SN792_0354_BC550KACXX_7_CTTGTA_L007_R1_001_Day7E1.fastq.gz" "${root}/rawData/_QGF_21911_140718_SN792_0354_BC550KACXX_7_CTTGTA_L007_R1_002_Day7E1.fastq.gz" | gzip > "${root}/rawData/concatenated/BSSE_QGF_21911_140718_SN792_0354_BC550KACXX_7_CTTGTA_L007_R1_cat_Day7E1.fastq.gz"
# zcat "${root}/rawData/BSSE_QGF_21913_140718_SN792_0354_BC550KACXX_8_TGACCA_L008_R1_001_Day8C.fastq.gz" "${root}/rawData/_QGF_21913_140718_SN792_0354_BC550KACXX_8_TGACCA_L008_R1_002_Day8C.fastq.gz" | gzip > "${root}/rawData/concatenated/BSSE_QGF_21913_140718_SN792_0354_BC550KACXX_8_TGACCA_L008_R1_cat_Day8C.fastq.gz"
# zcat "${root}/rawData/BSSE_QGF_21915_140718_SN792_0354_BC550KACXX_8_GCCAAT_L008_R1_001_Day8Red.fastq.gz" "${root}/rawData/_QGF_21915_140718_SN792_0354_BC550KACXX_8_GCCAAT_L008_R1_002_Day8Red.fastq.gz" | gzip > "${root}/rawData/concatenated/BSSE_QGF_21915_140718_SN792_0354_BC550KACXX_8_GCCAAT_L008_R1_cat_Day8Red.fastq.gz"
# zcat "${root}/rawData/BSSE_QGF_21917_140718_SN792_0354_BC550KACXX_8_CTTGTA_L008_R1_001_Day8E1.fastq.gz" "${root}/rawData/_QGF_21917_140718_SN792_0354_BC550KACXX_8_CTTGTA_L008_R1_002_Day8E1.fastq.gz" | gzip > "${root}/rawData/concatenated/BSSE_QGF_21917_140718_SN792_0354_BC550KACXX_8_CTTGTA_L008_R1_cat_Day8E1.fastq.gz"

# Rename files
# TODO ORIGIN FILENAMES TO BE REPLACED WITH NAMES OF FILES DOWNLOAED FROM REPOSITORY
# rename BSSE_QGF_21869_140718_SN792_0354_BC550KACXX_1_CGATGT_L001_R1_001_Day0_MEFs.fastq.gz Day0_MEFs.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21871_140718_SN792_0354_BC550KACXX_1_ACAGTG_L001_R1_001_Day1Red.fastq.gz Day1Red.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21873_140718_SN792_0354_BC550KACXX_1_GCCAAT_L001_R1_001_Day1E1.fastq.gz Day1E1.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21875_140718_SN792_0354_BC550KACXX_1_CAGATC_L001_R1_001_Day2C.fastq.gz Day2C.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21877_140718_SN792_0354_BC550KACXX_2_TGACCA_L002_R1_001_Day1C.fastq.gz Day1C.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21879_140718_SN792_0354_BC550KACXX_2_ACAGTG_L002_R1_cat_Day3C.fastq.gz Day3C.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21881_140718_SN792_0354_BC550KACXX_2_CAGATC_L002_R1_001_Day2Red.fastq.gz Day2Red.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21883_140718_SN792_0354_BC550KACXX_2_CTTGTA_L002_R1_001_Day2E1.fastq.gz Day2E1.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21885_140718_SN792_0354_BC550KACXX_3_ACAGTG_L003_R1_001_Day4Red.fastq.gz Day4Red.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21887_140718_SN792_0354_BC550KACXX_3_GCCAAT_L003_R1_001_Day3Red.fastq.gz Day3Red.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21889_140718_SN792_0354_BC550KACXX_3_CAGATC_L003_R1_001_Day3E1.fastq.gz Day3E1.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21891_140718_SN792_0354_BC550KACXX_3_CTTGTA_L003_R1_001_Day4C.fastq.gz Day4C.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21893_140718_SN792_0354_BC550KACXX_4_ACAGTG_L004_R1_001_Day5C.fastq.gz Day5C.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21895_140718_SN792_0354_BC550KACXX_4_GCCAAT_L004_R1_001_Day4E1.fastq.gz Day4E1.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21897_140718_SN792_0354_BC550KACXX_4_CAGATC_L004_R1_001_Day5Red.fastq.gz Day5Red.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21899_140718_SN792_0354_BC550KACXX_4_CTTGTA_L004_R1_001_Day5E1.fastq.gz Day5E1.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21901_140718_SN792_0354_BC550KACXX_6_TGACCA_L006_R1_cat_Day6C.fastq.gz Day6C.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21903_140718_SN792_0354_BC550KACXX_6_GCCAAT_L006_R1_cat_Day6Red.fastq.gz Day6Red.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21905_140718_SN792_0354_BC550KACXX_6_CTTGTA_L006_R1_cat_Day6E1.fastq.gz Day6E1.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21907_140718_SN792_0354_BC550KACXX_7_TGACCA_L007_R1_cat_Day7C.fastq.gz Day7C.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21909_140718_SN792_0354_BC550KACXX_7_GCCAAT_L007_R1_cat_Day7Red.fastq.gz Day7Red.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21911_140718_SN792_0354_BC550KACXX_7_CTTGTA_L007_R1_cat_Day7E1.fastq.gz Day7E1.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21913_140718_SN792_0354_BC550KACXX_8_TGACCA_L008_R1_cat_Day8C.fastq.gz Day8C.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21915_140718_SN792_0354_BC550KACXX_8_GCCAAT_L008_R1_cat_Day8Red.fastq.gz Day8Red.fastq.gz "${root}/rawData/"*
# rename BSSE_QGF_21917_140718_SN792_0354_BC550KACXX_8_CTTGTA_L008_R1_cat_Day8E1.fastq.gz Day8E1.fastq.gz "${root}/rawData/"*

# Create md5 hash sum file
# TODO TO BE REPLACED WITH MD5SUM CHECK
# cd "$root"
# md5sum "rawData/Day"* >> "${root}/documenation/time_course_1.md5_sums.tab"

#
