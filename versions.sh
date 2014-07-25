#!/bin/bash
# This script outputs version details of the Dashboards for Autotask and CakePHP.

# Used to store the GIT repo clone URL in.
GIT_REPO_CLONE_URL=""
# Used to store the only the name of the GIT repo. Only supports GitHub.
GIT_REPO_NAME=""
# Used to store the active GIT branch in.
GIT_BRANCH=""
# Used to indicate where we can read the cakephp version from. Relative to
# /app/Plugin/Autotask
CAKEPHP_VERSION_FILE_PATH="../../../lib/Cake/VERSION.txt"
# Used to indicate the core configuration file.
CAKEPHP_CORE_FILE_PATH="../../Config/core.php"


# I've used relative paths in this script, so it supports sites in any directory
# (/var/www or /home/<username>). That makes it necessary to run it from the
# /app/Plugin/Autotask folder.
function checkIfInProperDirectory () {

    DIRECTORY=${PWD##*/}

    if [ "Autotask" != $DIRECTORY ];
    then
        echo "Please execute this script from the /app/Plugin/Autotask directory."
        exit 1;
    fi

}


# Fills up variables so you can use them for output later:
# - GIT_REPO_CLONE_URL
# - GIT_REPO_NAME
# - GIT_BRANCH
function parseGitInfo () {

    GIT_REPO_CLONE_URL="`git remote -v | cut -d$'\n' -f1 | awk '{print $2}'`"
    GIT_REPO_NAME="`echo $GIT_REPO_CLONE_URL | cut -d':' -f2`"
    GIT_BRANCH="`git branch | cut -d'*' -f2 | awk '{print $1}'`"

}

# Outputs details about the GIT repository.
function echoGitRepoInfo () {

    echo "GIT Information"
    echo -e "- Clone URL\t\t$GIT_REPO_CLONE_URL"

    OUTPUT_REPO_TYPE="- Repo type"
    if [ "coencoppens/dashboards-pro.git" == $GIT_REPO_NAME ];
    then
            OUTPUT_REPO_TYPE="$OUTPUT_REPO_TYPE\t\tPro - New repo"

    elif [ "coencoppens/autotask-dashboards.git" == $GIT_REPO_NAME ];
    then
            OUTPUT_REPO_TYPE="$OUTPUT_REPO_TYPE\t\tOpen-Source"

    elif [ "coencoppens/autotask-dashboards-pro.git" == $GIT_REPO_NAME ];
    then
            OUTPUT_REPO_TYPE="$OUTPUT_REPO_TYPE\t\tPro - Old repo"

    else
            OUTPUT_REPO_TYPE="$OUTPUT_REPO_TYPE\t\tCustom"

    fi

    echo -e $OUTPUT_REPO_TYPE
    echo -e "- Repo name\t\t$GIT_REPO_NAME"
    echo -e "- Branch\t\t$GIT_BRANCH"
    echo ""

}


# Outputs the timezone used by CakePHP.
function echoTimeZone () {

    while read LINE; do

        if [[ $LINE == *date_default_timezone_set* ]];
        then
            TIMEZONE=`echo $LINE | cut -d\' -f2`
        fi

    done < $CAKEPHP_CORE_FILE_PATH

    echo -e "- Timezone\t\t$TIMEZONE"

}


checkIfInProperDirectory
parseGitInfo
echo ""
echoGitRepoInfo

echo "Code Information"
echo -e "- CakePHP\t\t"`awk '/./{line=$0} END{print line}' $CAKEPHP_VERSION_FILE_PATH`
echoTimeZone

exit 0;