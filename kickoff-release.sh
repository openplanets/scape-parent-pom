#!/bin/bash

##
# Bash script to kick off the process of releasing 
#
# author Carl Wilson carl@openplanetsfoundation.org
# 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Globals to hold the checked param vals
paramReleaseScript=

# Globals for release details
releaseDate=
version=
##
# Functions defined first, control flow at the bottom of script
##

# Check the passed params to avoid disapointment
checkParams () {
# Ensure we have the correct number of params
        if [[ "$#" -ne 1 ]]
        then
                echo "$# One parameters expected"
                exit 1
        fi
        
        paramReleaseScript="$1"
        
	# Check that the release script exists
        if  [[ ! -e "$paramReleaseScript" ]]
        then
                echo "Release script not found: $paramReleaseScript"
                exit 1;
        fi
}


# Check we're on master 
checkMaster() {
        gitbranch=$(git branch 2>&1)
        currentBranchRegEx="^\* (.*)$"
	branchCheckRegEx="^master|release$"
        onMaster=0
        while IFS= read -r
        do
                if [[ $REPLY =~ $currentBranchRegEx ]]
                then
                        currentBranch="${BASH_REMATCH[1]}"
                fi
        done <<< "$gitbranch"
        if [[ $currentBranch =~ $masterRegEx ]]
        then
               onMaster=1;
        fi
        if (( $onMaster == 0 ))
        then
                echo "Master branch not checked out, please check out a tagged master commit."
		exit 1;
        fi
}

# Check that the current commit is tagged with a compliant version number
checkCommitTag() {
        gitTagCheck=$(git log --pretty=format:'%ad %h %d' --abbrev-commit --date=short -1)
        commitRegEx="^([0-9]{4}-[0-9]{2}-[0-9]{2}) [0-9a-f]{6,40}  \(.*tag: (.*),|\).*$"
        while IFS= read -r
        do 
                if [[ $REPLY =~ $commitRegEx ]]
                then
                        releaseDate="${BASH_REMATCH[1]}"
			version="${BASH_REMATCH[2]}"
		else
			echo "Current commit isn't tagged, please check out a commit tagged with a version number"
			exit 1;
                fi
        done <<< "$gitTagCheck"
        
        echo "$currentBranch IS OK, release date : $releaseDate, tag : $version"
}

checkParams "$@"
checkMaster
checkCommitTag
