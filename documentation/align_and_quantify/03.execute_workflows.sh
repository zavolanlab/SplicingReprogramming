#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 21-SEP-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Builds and (optionally) executes Anduril commands.

####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(cd "$(dirname "$0" )" && pwd)))"

# Set other parameters
bundleDir="${root}/frameworksAuxiliary/anduril/bundle"
execRootDir="${root}/.tmp/align_and_quantify"
logRootDir="${root}/logFiles/align_and_quantify/anduril"
logDir="${root}/logFiles/align_and_quantify"
threads=2
workflowDir="${root}/.tmp/anduril/align_and_quantify/workflows"
workflowPrefix="workflow."
workflowSuffix=".and"
commandFile="${root}/.tmp/anduril/align_and_quantify/commands"
timeout=0    # timeout (in sec) between executing different Anduril instances
             # if set to 0, only commands written to $commandFile (no execution!)


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

echo "Workflows in: $workflowDir" >> "$logFile"
echo "Commands written to: $commandFile" >> "$logFile"
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
