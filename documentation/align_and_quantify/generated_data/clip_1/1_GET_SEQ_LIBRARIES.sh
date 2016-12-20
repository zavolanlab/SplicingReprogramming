#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 07-JUN-2015                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Obtains/copies sequencing libraries.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"
rawDataDir="${root}/rawData/clip_1"
sampleInfoDir="${root}/documentation/clip_1"


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
cp "${transferDir}/BSSE_QGF_47193_"*/* "${transferDir}/BSSE_QGF_47194_"*/* "${transferDir}/BSSE_QGF_47832_"*/* "${transferDir}/BSSE_QGF_47833_"*/* "${transferDir}/BSSE_QGF_47834_"*/* "${transferDir}/BSSE_QGF_47835_"*/* "${transferDir}/Undetermined_C9CHPANXX_8"/* "${transferDir}/Undetermined_C9DH5ANXX_5"/* "${transferDir}/Undetermined_C9DH5ANXX_5_MM_1"/* "${transferDir}/Undetermined_C9DEWANXX_1_MM_1"/* "$rawDataDir"
rm "${rawDataDir}/PARENT_"*

# List of library and metadata files
# TODO TO BE REMOVED
# ls "$rawDataDir"
# BSSE_QGF_47193_C9CHPANXX_8_SMI_CLIP_CTTGTAA_S1_L008_metadata.tsv
# BSSE_QGF_47193_C9CHPANXX_8_SMI_CLIP_CTTGTAA_S1_L008_R1_001.fastq.gz
# BSSE_QGF_47193_C9DEWANXX_1_SMI_CLIP_CTTGTAA_S1_L001_MM_1_metadata.tsv
# BSSE_QGF_47193_C9DEWANXX_1_SMI_CLIP_CTTGTAA_S1_L001_R1_001_MM_1.fastq.gz
# BSSE_QGF_47193_C9DH5ANXX_5_SMI_CLIP_CTTGTAA_S1_L005_metadata.tsv
# BSSE_QGF_47193_C9DH5ANXX_5_SMI_CLIP_CTTGTAA_S1_L005_MM_1_metadata.tsv
# BSSE_QGF_47193_C9DH5ANXX_5_SMI_CLIP_CTTGTAA_S1_L005_R1_001.fastq.gz
# BSSE_QGF_47193_C9DH5ANXX_5_SMI_CLIP_CTTGTAA_S1_L005_R1_001_MM_1.fastq.gz
# BSSE_QGF_47194_C9CHPANXX_8_Esrp1_CLIP_CAGATCA_S2_L008_metadata.tsv
# BSSE_QGF_47194_C9CHPANXX_8_Esrp1_CLIP_CAGATCA_S2_L008_R1_001.fastq.gz
# BSSE_QGF_47194_C9DEWANXX_1_Esrp1_CLIP_CAGATCA_S2_L001_MM_1_metadata.tsv
# BSSE_QGF_47194_C9DEWANXX_1_Esrp1_CLIP_CAGATCA_S2_L001_R1_001_MM_1.fastq.gz
# BSSE_QGF_47194_C9DH5ANXX_5_Esrp1_CLIP_CAGATCA_S2_L005_metadata.tsv
# BSSE_QGF_47194_C9DH5ANXX_5_Esrp1_CLIP_CAGATCA_S2_L005_MM_1_metadata.tsv
# BSSE_QGF_47194_C9DH5ANXX_5_Esrp1_CLIP_CAGATCA_S2_L005_R1_001.fastq.gz
# BSSE_QGF_47194_C9DH5ANXX_5_Esrp1_CLIP_CAGATCA_S2_L005_R1_001_MM_1.fastq.gz
# BSSE-QGF-47533_C9CHPANXX_Undetermined_S0_L008_R1_001_metadata.tsv
# BSSE_QGF_47832_C9DEWANXX_1_Esrp1_CGATGTA_S3_L001_MM_1_metadata.tsv
# BSSE_QGF_47832_C9DEWANXX_1_Esrp1_CGATGTA_S3_L001_R1_001_MM_1.fastq.gz
# BSSE_QGF_47832_C9DH5ANXX_5_Esrp1_CGATGTA_S3_L005_metadata.tsv
# BSSE_QGF_47832_C9DH5ANXX_5_Esrp1_CGATGTA_S3_L005_MM_1_metadata.tsv
# BSSE_QGF_47832_C9DH5ANXX_5_Esrp1_CGATGTA_S3_L005_R1_001.fastq.gz
# BSSE_QGF_47832_C9DH5ANXX_5_Esrp1_CGATGTA_S3_L005_R1_001_MM_1.fastq.gz
# BSSE_QGF_47833_C9DEWANXX_1_SM_Esrp1_TGACCAA_S4_L001_MM_1_metadata.tsv
# BSSE_QGF_47833_C9DEWANXX_1_SM_Esrp1_TGACCAA_S4_L001_R1_001_MM_1.fastq.gz
# BSSE_QGF_47833_C9DH5ANXX_5_SM_Esrp1_TGACCAA_S4_L005_metadata.tsv
# BSSE_QGF_47833_C9DH5ANXX_5_SM_Esrp1_TGACCAA_S4_L005_MM_1_metadata.tsv
# BSSE_QGF_47833_C9DH5ANXX_5_SM_Esrp1_TGACCAA_S4_L005_R1_001.fastq.gz
# BSSE_QGF_47833_C9DH5ANXX_5_SM_Esrp1_TGACCAA_S4_L005_R1_001_MM_1.fastq.gz
# BSSE_QGF_47834_C9DEWANXX_1_Esrp2_ACAGTGA_S5_L001_MM_1_metadata.tsv
# BSSE_QGF_47834_C9DEWANXX_1_Esrp2_ACAGTGA_S5_L001_R1_001_MM_1.fastq.gz
# BSSE_QGF_47834_C9DH5ANXX_5_Esrp2_ACAGTGA_S5_L005_metadata.tsv
# BSSE_QGF_47834_C9DH5ANXX_5_Esrp2_ACAGTGA_S5_L005_MM_1_metadata.tsv
# BSSE_QGF_47834_C9DH5ANXX_5_Esrp2_ACAGTGA_S5_L005_R1_001.fastq.gz
# BSSE_QGF_47834_C9DH5ANXX_5_Esrp2_ACAGTGA_S5_L005_R1_001_MM_1.fastq.gz
# BSSE_QGF_47835_C9DEWANXX_1_SM_Esrp2_GCCAATA_S6_L001_MM_1_metadata.tsv
# BSSE_QGF_47835_C9DEWANXX_1_SM_Esrp2_GCCAATA_S6_L001_R1_001_MM_1.fastq.gz
# BSSE_QGF_47835_C9DH5ANXX_5_SM_Esrp2_GCCAATA_S6_L005_metadata.tsv
# BSSE_QGF_47835_C9DH5ANXX_5_SM_Esrp2_GCCAATA_S6_L005_MM_1_metadata.tsv
# BSSE_QGF_47835_C9DH5ANXX_5_SM_Esrp2_GCCAATA_S6_L005_R1_001.fastq.gz
# BSSE_QGF_47835_C9DH5ANXX_5_SM_Esrp2_GCCAATA_S6_L005_R1_001_MM_1.fastq.gz
# BSSE-QGF-47842_C9DEWANXX_Undetermined_S0_L001_R1_001_MM_1_metadata.tsv
# BSSE-QGF-47842_C9DH5ANXX_Undetermined_S0_L005_R1_001_metadata.tsv
# BSSE-QGF-47842_C9DH5ANXX_Undetermined_S0_L005_R1_001_MM_1_metadata.tsv
# C9CHPANXX_Undetermined_S0_L008_R1_001.fastq.gz
# C9DEWANXX_Undetermined_S0_L001_R1_001_MM_1.fastq.gz
# C9DH5ANXX_Undetermined_S0_L005_R1_001.fastq.gz
# C9DH5ANXX_Undetermined_S0_L005_R1_001_MM_1.fastq.gz

# Concatenate files
# TODO TO BE REPLACED BY FORMAT CONVERSION, IF REQUIRED
zcat "${rawDataDir}/BSSE_QGF_47193_C9DH5ANXX_5_SMI_CLIP_CTTGTAA_S1_L005_R1_001_MM_1.fastq.gz" "${rawDataDir}/BSSE_QGF_47193_C9DEWANXX_1_SMI_CLIP_CTTGTAA_S1_L001_R1_001_MM_1.fastq.gz" | gzip > "${rawDataDir}/BSSE_QGF_47193_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz"
zcat "${rawDataDir}/BSSE_QGF_47194_C9DH5ANXX_5_Esrp1_CLIP_CAGATCA_S2_L005_R1_001_MM_1.fastq.gz" "${rawDataDir}/BSSE_QGF_47194_C9DEWANXX_1_Esrp1_CLIP_CAGATCA_S2_L001_R1_001_MM_1.fastq.gz" | gzip > "${rawDataDir}/BSSE_QGF_47194_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz"
zcat "${rawDataDir}/BSSE_QGF_47832_C9DH5ANXX_5_Esrp1_CGATGTA_S3_L005_R1_001_MM_1.fastq.gz" "${rawDataDir}/BSSE_QGF_47832_C9DEWANXX_1_Esrp1_CGATGTA_S3_L001_R1_001_MM_1.fastq.gz" | gzip > "${rawDataDir}/BSSE_QGF_47832_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz"
zcat "${rawDataDir}/BSSE_QGF_47833_C9DH5ANXX_5_SM_Esrp1_TGACCAA_S4_L005_R1_001_MM_1.fastq.gz" "${rawDataDir}/BSSE_QGF_47833_C9DEWANXX_1_SM_Esrp1_TGACCAA_S4_L001_R1_001_MM_1.fastq.gz" | gzip > "${rawDataDir}/BSSE_QGF_47833_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz"
zcat "${rawDataDir}/BSSE_QGF_47834_C9DH5ANXX_5_Esrp2_ACAGTGA_S5_L005_R1_001_MM_1.fastq.gz" "${rawDataDir}/BSSE_QGF_47834_C9DEWANXX_1_Esrp2_ACAGTGA_S5_L001_R1_001_MM_1.fastq.gz" | gzip > "${rawDataDir}/BSSE_QGF_47834_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz"
zcat "${rawDataDir}/BSSE_QGF_47835_C9DH5ANXX_5_SM_Esrp2_GCCAATA_S6_L005_R1_001_MM_1.fastq.gz" "${rawDataDir}/BSSE_QGF_47835_C9DEWANXX_1_SM_Esrp2_GCCAATA_S6_L001_R1_001_MM_1.fastq.gz" | gzip > "${rawDataDir}/BSSE_QGF_47835_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz"

# Create md5 hash sum file
# TODO TO BE REPLACED WITH MD5SUM CHECK
rawDataSuffix=${rawDataDir#$root/}
cd "$root"
md5sum "${rawDataSuffix}"*".fastq.gz" >> "${sampleInfoDir}/md5_sums.fastq.tab"
cd -
