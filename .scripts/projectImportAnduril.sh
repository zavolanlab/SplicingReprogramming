#!/bin/sh

# Alexander Kanitz, Biozentrum, University of Basel
# alexander.kanitz@alumni.ethz.ch
# 19-AUG-2015

projectPath=${1:-"frameworksAuxiliary/Anduril"}
repository=${2:-"ssh://git@git.scicore.unibas.ch:2222/AnnotationPipelines/Anduril.git"}

gitPath=`which "git" 2> /dev/null`

if [ "$gitPath" = "" ]; then
    echo -e "[ERROR] git is required but appears not to be installed. Obtain git from 'https://git-scm.com/downloads' and/or make sure it is available in your \$PATH.\nExecution aborted!"
    exit 1
else
    git clone --quiet "$repository" "$projectPath"
    rm -rf "${projectPath}/.git"
    find "$projectPath" -type f | xargs sed -i "s~<<ANDURIL_ROOT_DIRECTORY>>~$PWD/$projectPath~"
fi
