#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

. ./helpers.sh --source-only
WORKING_DIRECTORY=`pwd`
DEFAULT_WORKING_BRANCH="master"
# Suppor for Github's switch to use main as a default branch vs master 
OTHER_DEFAULT_WORKING_BRANCH="main"
LOGFILE="${WORKING_DIRECTORY}/gitupdateallrepos.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

if [ "$#" -eq  "0" ]; then
    PROJECT_DIR=~/Projects
    log_error "${TIMESTAMP} No project directory was given, defaulting to ${PROJECT_DIR}."
else
    PROJECT_DIR="$1"
fi

get_branch() {
    git symbolic-ref --short -q HEAD || echo "default_value";
}

has_changes() {
    [[ -n "$(git status --porcelain)" ]]
}

update_all_repos() {
    for REPO in "${PROJECT_DIR}"/*/ ; do
        cd "${REPO}"
        if [ -d "${REPO}/.git" ]; then
            BRANCH=`get_branch`
            log_info "${TIMESTAMP} Branch: ${BRANCH}"
        fi;

        log_info "Checking project ${REPO}..."
        if [ -d "${REPO}/.git" ] && [[ "${BRANCH}" == "${DEFAULT_WORKING_BRANCH}" && "${BRANCH}" == "${OTHER_DEFAULT_WORKING_BRANCH}" ]]; then
            echo "${TIMESTAMP}" >> "${LOGFILE}"
            git pull --rebase -v origin "${BRANCH}" >> "${LOGFILE}" 2>&1
        elif [ -d "${REPO}/.git" ] && [[ "${BRANCH}" != "${DEFAULT_WORKING_BRANCH}" && "${BRANCH}" != "${OTHER_DEFAULT_WORKING_BRANCH}" ]]; then
            has_changes
            if [ ${NOCHANGES} -eq 0 ]; then
                git stash --include-untracked
                log_info "${TIMESTAMP} You have changes on ${BRANCH}, going to stash them while updating ${DEFAULT_WORKING_BRANCH}..."
            fi;
            git checkout "${DEFAULT_WORKING_BRANCH}"
            echo "${TIMESTAMP}" >> "${LOGFILE}"
            git pull --rebase -v >> "${LOGFILE}" 2>&1
            if [ ${NOCHANGES} -eq 0 ]; then
                git checkout "${BRANCH}"
                git stash pop
                log_info "${TIMESTAMP} Restoring changes on your branch: ${BRANCH}"
             fi;
        else
            log_warn "${TIMESTAMP} There was no git repo in ${REPO}"
        fi;
    done
}

main() {
    update_all_repos
}

main