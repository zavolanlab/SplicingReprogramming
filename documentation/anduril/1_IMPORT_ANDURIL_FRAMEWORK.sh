#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@unibas.ch                        ###
### 27-APR-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Imports components and custom libraries for the Anduril workflow engine.


####################
###  PARAMETERS  ###
####################

root="$(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail


########################
###  IMPORT ANDURIL  ###
########################

# Import Anduril framework
"${root}/scriptsSoftware/anduril/projectImportAnduril.sh"
