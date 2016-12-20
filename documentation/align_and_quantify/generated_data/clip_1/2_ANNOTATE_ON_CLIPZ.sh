#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 07-JUN-2015                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Upload to and annotate sequencing libraries with CLIPZ.
# IMPORTANT: Execute as user 'clipz' on 'login-12'.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"
script="$HOME/newClipz6/progs/annotation/annotateSample.py"
rawDataDir="${root}/rawData/clip_1"
sampleInfoDir="${root}/documentation/clip_1"
clipzIDs="$sampleInfoDir/clipz_job_ids"


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

# First run with 1 mismatch barcode separation
$script -description "CLIP protocol from Georges Martin" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47193_C9DH5ANXX_5_SMI_CLIP_CTTGTAA_S1_L005_R1_001_MM_1.fastq.gz" "Esrp1_eCLIP_size_matched_control_run_2" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47193_C9DH5ANXX_5_SMI_CLIP_CTTGTAA_S1_L005_R1_001_MM_1.fastq.gz" >> "$clipzIDs"
$script -description "CLIP protocol from Georges Martin" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47194_C9DH5ANXX_5_Esrp1_CLIP_CAGATCA_S2_L005_R1_001_MM_1.fastq.gz" "Esrp1_eCLIP_run_2" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47194_C9DH5ANXX_5_Esrp1_CLIP_CAGATCA_S2_L005_R1_001_MM_1.fastq.gz" >> "$clipzIDs"
$script -description "CLIP protocol from Dominik Jedlinski" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47832_C9DH5ANXX_5_Esrp1_CGATGTA_S3_L005_R1_001_MM_1.fastq.gz" "Esrp1_CLIP_run_1" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47832_C9DH5ANXX_5_Esrp1_CGATGTA_S3_L005_R1_001_MM_1.fastq.gz" >> "$clipzIDs"
$script -description "CLIP protocol from Dominik Jedlinski" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47833_C9DH5ANXX_5_SM_Esrp1_TGACCAA_S4_L005_R1_001_MM_1.fastq.gz" "Esrp1_CLIP_size_matched_control_run_1" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47833_C9DH5ANXX_5_SM_Esrp1_TGACCAA_S4_L005_R1_001_MM_1.fastq.gz" >> "$clipzIDs"
$script -description "CLIP protocol from Dominik Jedlinski" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47834_C9DH5ANXX_5_Esrp2_ACAGTGA_S5_L005_R1_001_MM_1.fastq.gz" "Esrp2_CLIP_run_1" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47834_C9DH5ANXX_5_Esrp2_ACAGTGA_S5_L005_R1_001_MM_1.fastq.gz" >> "$clipzIDs"
$script -description "CLIP protocol from Dominik Jedlinski" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47835_C9DH5ANXX_5_SM_Esrp2_GCCAATA_S6_L005_R1_001_MM_1.fastq.gz" "Esrp2_CLIP_size_matched_control_run_1" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47835_C9DH5ANXX_5_SM_Esrp2_GCCAATA_S6_L005_R1_001_MM_1.fastq.gz" >> "$clipzIDs"

# Second run with 1 mismatch barcode separation
$script -description "CLIP protocol from Georges Martin" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47193_C9DEWANXX_1_SMI_CLIP_CTTGTAA_S1_L001_R1_001_MM_1.fastq.gz" "Esrp1_eCLIP_size_matched_control_run_3" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47193_C9DEWANXX_1_SMI_CLIP_CTTGTAA_S1_L001_R1_001_MM_1.fastq.gz" >> "$clipzIDs"
$script -description "CLIP protocol from Georges Martin" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47194_C9DEWANXX_1_Esrp1_CLIP_CAGATCA_S2_L001_R1_001_MM_1.fastq.gz" "Esrp1_eCLIP_run_3" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47194_C9DEWANXX_1_Esrp1_CLIP_CAGATCA_S2_L001_R1_001_MM_1.fastq.gz" >> "$clipzIDs"
$script -description "CLIP protocol from Dominik Jedlinski" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47832_C9DEWANXX_1_Esrp1_CGATGTA_S3_L001_R1_001_MM_1.fastq.gz" "Esrp1_CLIP_run_2" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47832_C9DEWANXX_1_Esrp1_CGATGTA_S3_L001_R1_001_MM_1.fastq.gz" >> "$clipzIDs"
$script -description "CLIP protocol from Dominik Jedlinski" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47833_C9DEWANXX_1_SM_Esrp1_TGACCAA_S4_L001_R1_001_MM_1.fastq.gz" "Esrp1_CLIP_size_matched_control_run_2" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47833_C9DEWANXX_1_SM_Esrp1_TGACCAA_S4_L001_R1_001_MM_1.fastq.gz" >> "$clipzIDs"
$script -description "CLIP protocol from Dominik Jedlinski" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47834_C9DEWANXX_1_Esrp2_ACAGTGA_S5_L001_R1_001_MM_1.fastq.gz" "Esrp2_CLIP_run_2" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47834_C9DEWANXX_1_Esrp2_ACAGTGA_S5_L001_R1_001_MM_1.fastq.gz" >> "$clipzIDs"
$script -description "CLIP protocol from Dominik Jedlinski" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47835_C9DEWANXX_1_SM_Esrp2_GCCAATA_S6_L001_R1_001_MM_1.fastq.gz" "Esrp2_CLIP_size_matched_control_run_2" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47835_C9DEWANXX_1_SM_Esrp2_GCCAATA_S6_L001_R1_001_MM_1.fastq.gz" >> "$clipzIDs"

# Concatenation of first and second runs with 1 mismatch barcode separation
$script -description "CLIP protocol from Georges Martin" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47193_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz" "Esrp1_eCLIP_size_matched_control_runs_2_3" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47193_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz" >> "$clipzIDs"
$script -description "CLIP protocol from Georges Martin" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47194_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz" "Esrp1_eCLIP_runs_2_3" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47194_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz" >> "$clipzIDs"
$script -description "CLIP protocol from Dominik Jedlinski" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47832_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz" "Esrp1_CLIP_runs_1_2" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47832_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz" >> "$clipzIDs"
$script -description "CLIP protocol from Dominik Jedlinski" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47833_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz" "Esrp1_CLIP_size_matched_control_runs_1_2" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47833_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz" >> "$clipzIDs"
$script -description "CLIP protocol from Dominik Jedlinski" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47834_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz" "Esrp2_CLIP_runs_1_2" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47834_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz" >> "$clipzIDs"
$script -description "CLIP protocol from Dominik Jedlinski" -seq_tech "Illumina HiSeq 2500" -alias "BSSE_QGF_47835_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz" "Esrp2_CLIP_size_matched_control_runs_1_2" 2 15 "TGGAATTCTCGGGTGCCAAGG" 388 111 "hitsClip" "${rawDataDir}/BSSE_QGF_47835_CAT_C9DH5ANXX_5_C9DEWANXX_1_MM_1.fastq.gz" >> "$clipzIDs"
