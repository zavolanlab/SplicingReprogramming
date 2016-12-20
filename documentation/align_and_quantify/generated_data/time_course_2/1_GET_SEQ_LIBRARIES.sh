#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 26-SEP-2015                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Obtains/copies sequencing libraries.


####################
###  PARAMETERS  ###
####################

root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"
rawDataDir="${root}/rawData/time_course_2"
sampleInfoDir="${root}/documentation/time_course_2"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir --parents "$rawDataDir"
mkdir --parents "$sampleInfoDir"


##################################
###  GET SEQUENCING LIBRARIES  ###
##################################

# TODO
# Currently, sequencing libraries are copied from the transfer directory of the sequencing facility.
# Eventually, libraries should be uploaded to the SRA repository and the script adapted to use the
# files as downloaded from there.

# Copy raw FASTQ files and metadata from transfer directory
# TODO TO BE REPLACED BY REPOSITORY DOWNLOADS
transferDir="/scicore/projects/openbis/userstore/biozentrum_zavolan"
cp "${transferDir}/BSSE_QGF_371"??"_C7TYGANXX_"*/* "$rawDataDir"

# List of library and metadata files
# TODO TO BE REMOVED
# ls "$rawDataDir"
# BSSE_QGF_37125_C7TYGANXX_1_D_0_E1_CGATGTA_S1_L001_metadata.tsv
# BSSE_QGF_37125_C7TYGANXX_1_D_0_E1_CGATGTA_S1_L001_R1_001.fastq.gz
# BSSE_QGF_37126_C7TYGANXX_1_D_0_E2_TTAGGCA_S3_L001_metadata.tsv
# BSSE_QGF_37126_C7TYGANXX_1_D_0_E2_TTAGGCA_S3_L001_R1_001.fastq.gz
# BSSE_QGF_37127_C7TYGANXX_1_D_0_Msi1_TGACCAA_S4_L001_metadata.tsv
# BSSE_QGF_37127_C7TYGANXX_1_D_0_Msi1_TGACCAA_S4_L001_R1_001.fastq.gz
# BSSE_QGF_37128_C7TYGANXX_1_D_0_Luci_ACAGTGA_S2_L001_metadata.tsv
# BSSE_QGF_37128_C7TYGANXX_1_D_0_Luci_ACAGTGA_S2_L001_R1_001.fastq.gz
# BSSE_QGF_37129_C7TYGANXX_1_D_1_E1_GCCAATA_S5_L001_metadata.tsv
# BSSE_QGF_37129_C7TYGANXX_1_D_1_E1_GCCAATA_S5_L001_R1_001.fastq.gz
# BSSE_QGF_37130_C7TYGANXX_2_D_1_E2_CAGATCA_S10_L002_metadata.tsv
# BSSE_QGF_37130_C7TYGANXX_2_D_1_E2_CAGATCA_S10_L002_R1_001.fastq.gz
# BSSE_QGF_37131_C7TYGANXX_2_D_1_Msi1_ACTTGAA_S8_L002_metadata.tsv
# BSSE_QGF_37131_C7TYGANXX_2_D_1_Msi1_ACTTGAA_S8_L002_R1_001.fastq.gz
# BSSE_QGF_37132_C7TYGANXX_2_D_1_Luci_GATCAGA_S9_L002_metadata.tsv
# BSSE_QGF_37132_C7TYGANXX_2_D_1_Luci_GATCAGA_S9_L002_R1_001.fastq.gz
# BSSE_QGF_37133_C7TYGANXX_2_D_2_E1_TAGCTTA_S7_L002_metadata.tsv
# BSSE_QGF_37133_C7TYGANXX_2_D_2_E1_TAGCTTA_S7_L002_R1_001.fastq.gz
# BSSE_QGF_37134_C7TYGANXX_2_D_2_E2_ATCACGA_S6_L002_metadata.tsv
# BSSE_QGF_37134_C7TYGANXX_2_D_2_E2_ATCACGA_S6_L002_R1_001.fastq.gz
# BSSE_QGF_37135_C7TYGANXX_3_D_2_Msi1_CGATGTA_S11_L003_metadata.tsv
# BSSE_QGF_37135_C7TYGANXX_3_D_2_Msi1_CGATGTA_S11_L003_R1_001.fastq.gz
# BSSE_QGF_37136_C7TYGANXX_3_D_2_Luci_TTAGGCA_S12_L003_metadata.tsv
# BSSE_QGF_37136_C7TYGANXX_3_D_2_Luci_TTAGGCA_S12_L003_R1_001.fastq.gz
# BSSE_QGF_37137_C7TYGANXX_3_D_3_E1_TGACCAA_S13_L003_metadata.tsv
# BSSE_QGF_37137_C7TYGANXX_3_D_3_E1_TGACCAA_S13_L003_R1_001.fastq.gz
# BSSE_QGF_37138_C7TYGANXX_3_D_3_E2_ACAGTGA_S14_L003_metadata.tsv
# BSSE_QGF_37138_C7TYGANXX_3_D_3_E2_ACAGTGA_S14_L003_R1_001.fastq.gz
# BSSE_QGF_37139_C7TYGANXX_3_D_3_Msi1_GCCAATA_S15_L003_metadata.tsv
# BSSE_QGF_37139_C7TYGANXX_3_D_3_Msi1_GCCAATA_S15_L003_R1_001.fastq.gz
# BSSE_QGF_37140_C7TYGANXX_4_D_3_Luci_CAGATCA_S20_L004_metadata.tsv
# BSSE_QGF_37140_C7TYGANXX_4_D_3_Luci_CAGATCA_S20_L004_R1_001.fastq.gz
# BSSE_QGF_37141_C7TYGANXX_4_D_4_E1_ACTTGAA_S17_L004_metadata.tsv
# BSSE_QGF_37141_C7TYGANXX_4_D_4_E1_ACTTGAA_S17_L004_R1_001.fastq.gz
# BSSE_QGF_37142_C7TYGANXX_4_D_4_E2_GATCAGA_S19_L004_metadata.tsv
# BSSE_QGF_37142_C7TYGANXX_4_D_4_E2_GATCAGA_S19_L004_R1_001.fastq.gz
# BSSE_QGF_37143_C7TYGANXX_4_D_4_Msi1_TAGCTTA_S18_L004_metadata.tsv
# BSSE_QGF_37143_C7TYGANXX_4_D_4_Msi1_TAGCTTA_S18_L004_R1_001.fastq.gz
# BSSE_QGF_37144_C7TYGANXX_4_D_4_Luci_ATCACGA_S16_L004_metadata.tsv
# BSSE_QGF_37144_C7TYGANXX_4_D_4_Luci_ATCACGA_S16_L004_R1_001.fastq.gz
# BSSE_QGF_37145_C7TYGANXX_5_D_5_E1_CGATGTA_S25_L005_metadata.tsv
# BSSE_QGF_37145_C7TYGANXX_5_D_5_E1_CGATGTA_S25_L005_R1_001.fastq.gz
# BSSE_QGF_37146_C7TYGANXX_5_D_5_E2_TTAGGCA_S21_L005_metadata.tsv
# BSSE_QGF_37146_C7TYGANXX_5_D_5_E2_TTAGGCA_S21_L005_R1_001.fastq.gz
# BSSE_QGF_37147_C7TYGANXX_5_D_5_Msi1_TGACCAA_S22_L005_metadata.tsv
# BSSE_QGF_37147_C7TYGANXX_5_D_5_Msi1_TGACCAA_S22_L005_R1_001.fastq.gz
# BSSE_QGF_37148_C7TYGANXX_5_D_5_Luci_ACAGTGA_S23_L005_metadata.tsv
# BSSE_QGF_37148_C7TYGANXX_5_D_5_Luci_ACAGTGA_S23_L005_R1_001.fastq.gz
# BSSE_QGF_37149_C7TYGANXX_5_D_0_NI_GCCAATA_S24_L005_metadata.tsv
# BSSE_QGF_37149_C7TYGANXX_5_D_0_NI_GCCAATA_S24_L005_R1_001.fastq.gz
# BSSE_QGF_37150_C7TYGANXX_6_D_1_NI_CAGATCA_S30_L006_metadata.tsv
# BSSE_QGF_37150_C7TYGANXX_6_D_1_NI_CAGATCA_S30_L006_R1_001.fastq.gz
# BSSE_QGF_37151_C7TYGANXX_6_D_2_NI_ACTTGAA_S28_L006_metadata.tsv
# BSSE_QGF_37151_C7TYGANXX_6_D_2_NI_ACTTGAA_S28_L006_R1_001.fastq.gz
# BSSE_QGF_37152_C7TYGANXX_6_D_3_NI_GATCAGA_S27_L006_metadata.tsv
# BSSE_QGF_37152_C7TYGANXX_6_D_3_NI_GATCAGA_S27_L006_R1_001.fastq.gz
# BSSE_QGF_37153_C7TYGANXX_6_D_4_NI_TAGCTTA_S29_L006_metadata.tsv
# BSSE_QGF_37153_C7TYGANXX_6_D_4_NI_TAGCTTA_S29_L006_R1_001.fastq.gz
# BSSE_QGF_37154_C7TYGANXX_6_D_5_NI_ATCACGA_S26_L006_metadata.tsv
# BSSE_QGF_37154_C7TYGANXX_6_D_5_NI_ATCACGA_S26_L006_R1_001.fastq.gz
# BSSE_QGF_37155_C7TYGANXX_7_D_15_E1_CGATGTA_S32_L007_metadata.tsv
# BSSE_QGF_37155_C7TYGANXX_7_D_15_E1_CGATGTA_S32_L007_R1_001.fastq.gz
# BSSE_QGF_37156_C7TYGANXX_7_D_15_E2_TTAGGCA_S31_L007_metadata.tsv
# BSSE_QGF_37156_C7TYGANXX_7_D_15_E2_TTAGGCA_S31_L007_R1_001.fastq.gz
# BSSE_QGF_37157_C7TYGANXX_7_D_15_Msi1_TGACCAA_S33_L007_metadata.tsv
# BSSE_QGF_37157_C7TYGANXX_7_D_15_Msi1_TGACCAA_S33_L007_R1_001.fastq.gz
# BSSE_QGF_37158_C7TYGANXX_7_D_15_Luci_ACAGTGA_S34_L007_metadata.tsv
# BSSE_QGF_37158_C7TYGANXX_7_D_15_Luci_ACAGTGA_S34_L007_R1_001.fastq.gz
# BSSE_QGF_37159_C7TYGANXX_7_D_15_NI_GCCAATA_S35_L007_metadata.tsv
# BSSE_QGF_37159_C7TYGANXX_7_D_15_NI_GCCAATA_S35_L007_R1_001.fastq.gz

# Rename files
# TODO ORIGIN FILENAMES TO BE REPLACED WITH NAMES OF FILES DOWNLOAED FROM REPOSITORY
rename BSSE_QGF_37125_C7TYGANXX_1_D_0_E1_CGATGTA_S1_L001_R1_001.fastq.gz D0_E1.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37126_C7TYGANXX_1_D_0_E2_TTAGGCA_S3_L001_R1_001.fastq.gz D0_E2.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37127_C7TYGANXX_1_D_0_Msi1_TGACCAA_S4_L001_R1_001.fastq.gz D0_M1.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37128_C7TYGANXX_1_D_0_Luci_ACAGTGA_S2_L001_R1_001.fastq.gz D0_Luc.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37129_C7TYGANXX_1_D_1_E1_GCCAATA_S5_L001_R1_001.fastq.gz D1_E1.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37130_C7TYGANXX_2_D_1_E2_CAGATCA_S10_L002_R1_001.fastq.gz D1_E2.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37131_C7TYGANXX_2_D_1_Msi1_ACTTGAA_S8_L002_R1_001.fastq.gz D1_M1.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37132_C7TYGANXX_2_D_1_Luci_GATCAGA_S9_L002_R1_001.fastq.gz D1_Luc.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37133_C7TYGANXX_2_D_2_E1_TAGCTTA_S7_L002_R1_001.fastq.gz D2_E1.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37134_C7TYGANXX_2_D_2_E2_ATCACGA_S6_L002_R1_001.fastq.gz D2_E2.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37135_C7TYGANXX_3_D_2_Msi1_CGATGTA_S11_L003_R1_001.fastq.gz D2_M.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37136_C7TYGANXX_3_D_2_Luci_TTAGGCA_S12_L003_R1_001.fastq.gz D2_Luc.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37137_C7TYGANXX_3_D_3_E1_TGACCAA_S13_L003_R1_001.fastq.gz D3_E1.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37138_C7TYGANXX_3_D_3_E2_ACAGTGA_S14_L003_R1_001.fastq.gz D3_E2.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37139_C7TYGANXX_3_D_3_Msi1_GCCAATA_S15_L003_R1_001.fastq.gz D3_M.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37140_C7TYGANXX_4_D_3_Luci_CAGATCA_S20_L004_R1_001.fastq.gz D3_Luc.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37141_C7TYGANXX_4_D_4_E1_ACTTGAA_S17_L004_R1_001.fastq.gz D4_E1.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37142_C7TYGANXX_4_D_4_E2_GATCAGA_S19_L004_R1_001.fastq.gz D4_E2.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37143_C7TYGANXX_4_D_4_Msi1_TAGCTTA_S18_L004_R1_001.fastq.gz D4_M.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37144_C7TYGANXX_4_D_4_Luci_ATCACGA_S16_L004_R1_001.fastq.gz D4_Luc.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37145_C7TYGANXX_5_D_5_E1_CGATGTA_S25_L005_R1_001.fastq.gz D5_E1.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37146_C7TYGANXX_5_D_5_E2_TTAGGCA_S21_L005_R1_001.fastq.gz D5_E2.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37147_C7TYGANXX_5_D_5_Msi1_TGACCAA_S22_L005_R1_001.fastq.gz D5_M.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37148_C7TYGANXX_5_D_5_Luci_ACAGTGA_S23_L005_R1_001.fastq.gz D5_Luc.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37149_C7TYGANXX_5_D_0_NI_GCCAATA_S24_L005_R1_001.fastq.gz D0_NI.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37150_C7TYGANXX_6_D_1_NI_CAGATCA_S30_L006_R1_001.fastq.gz D1_NI.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37151_C7TYGANXX_6_D_2_NI_ACTTGAA_S28_L006_R1_001.fastq.gz D2_NI.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37152_C7TYGANXX_6_D_3_NI_GATCAGA_S27_L006_R1_001.fastq.gz D3_NI.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37153_C7TYGANXX_6_D_4_NI_TAGCTTA_S29_L006_R1_001.fastq.gz D4_NI.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37154_C7TYGANXX_6_D_5_NI_ATCACGA_S26_L006_R1_001.fastq.gz D5_NI.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37155_C7TYGANXX_7_D_15_E1_CGATGTA_S32_L007_R1_001.fastq.gz D15_E1.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37156_C7TYGANXX_7_D_15_E2_TTAGGCA_S31_L007_R1_001.fastq.gz D15_E2.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37157_C7TYGANXX_7_D_15_Msi1_TGACCAA_S33_L007_R1_001.fastq.gz D15_M.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37158_C7TYGANXX_7_D_15_Luci_ACAGTGA_S34_L007_R1_001.fastq.gz D15_Luc.fastq.gz "$rawDataDir"/*
rename BSSE_QGF_37159_C7TYGANXX_7_D_15_NI_GCCAATA_S35_L007_R1_001.fastq.gz D15_NI.fastq.gz "$rawDataDir"/*

# Create md5 hash sum file
# TODO TO BE REPLACED WITH MD5SUM CHECK
rawDataSuffix=${rawDataDir#$root/}
cd "$root"
md5sum "${rawDataSuffix}/D"*".fastq.gz" >> "${sampleInfoDir}/md5_sums.fastq.tab"
cd -
