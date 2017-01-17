#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 21-SEP-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Generates Anduril run commands and optionally executes them.

####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"

# Set other parameters
bundleDir="${root}/frameworksAuxiliary/anduril/bundle"
execRootDir="${root}/.tmp/analyzedData/align_and_quantify/sra_data"
logRootDir="${root}/logFiles/analyzedData/align_and_quantify/sra_data/anduril"
threads=2
workflowDir="${root}/.tmp/frameworksAuxiliary/anduril/align_and_quantify/sra_data/workflows"
workflowPrefix="workflow."
workflowSuffix=".and"
commandFile="${root}/.tmp/frameworksAuxiliary/anduril/align_and_quantify/sra_data/commands"
timeout=0    # timeout (in sec) between workflow executions; no execution if set to 0
logDir="${root}/logFiles/analyzedData/align_and_quantify/sra_data"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile"; touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

# Delete and re-create command file
rm -f "$commandFile"; touch "$commandFile"

# Write log
echo "Writing Anduril run commands to file '$commandFile'..." >> "$logFile"

# Iterate over workflows
for workflow in "${workflowDir}/${workflowPrefix}"*"${workflowSuffix}"; do

    # Get ID
    id=$(sed -r "s~${workflowDir}/${workflowPrefix}(.*)${workflowSuffix}~\1~" <(echo "$workflow"))

    # Write Anduril run command
    cat >> "$commandFile" <<- EOF
# Workflow ID: $id
nohup anduril run "$workflow" \\
    --bundle "$bundleDir" \\
    --execution-dir "${execRootDir}/${id}" \\
    --log "${logRootDir}/${id}" \\
    --threads $threads \\
    &> /dev/null &

EOF

    # Unless execution is not desired...
    if [ "$timeout" -ne "0" ]; then

        # Write log message
        echo "Executing workflow '$workflow'..." >> "$logFile"

        # Execute workflow
        nohup anduril run "$workflow" \
            --bundle "$bundleDir" \
            --execution-dir "${execRootDir}/${id}" \
            --log "${logRootDir}/${id}" \
            --threads $threads \
            &> /dev/null &

        # Sleep for specified time
        sleep $timeout

    fi

done


#############
###  END  ###
#############

echo "Processed workflows in: $workflowDir" >> "$logFile"
echo "Commands written to: $commandFile" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
