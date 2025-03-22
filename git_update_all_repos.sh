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
    log_warn "${TIMESTAMP} No project directory was given, defaulting to ${PROJECT_DIR}."
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
    echo "PROJECT_DIR: ${PROJECT_DIR}"
    GIT_DIRS=$(find "${PROJECT_DIR}" -type d -name ".git")
    echo "GIT_DIRS: ${GIT_DIRS}"

    IFS=$'\n'
    for GIT_DIR in ${GIT_DIRS}; do
        REPO=$(dirname "${GIT_DIR}")
        cd "${REPO}" || continue

        if git rev-parse --is-bare-repository | grep -q "true"; then
            log_warn "${TIMESTAMP} Skipping bare repository: ${REPO}"
            continue
        fi

        log_info "Checking project ${REPO}..."

        BRANCH=$(get_branch)
        log_info "${TIMESTAMP} Branch: ${BRANCH}"

         if [[ "${BRANCH}" == "${DEFAULT_WORKING_BRANCH}" || "${BRANCH}" == "${OTHER_DEFAULT_WORKING_BRANCH}" ]]; then
            if has_changes; then
                git stash --include-untracked
                log_info "${TIMESTAMP} You have changes on ${BRANCH}, stashing them before pulling..."
                STASHED=true
            else
                STASHED=false
            fi

            echo "${TIMESTAMP}" >> "${LOGFILE}"
            git pull --rebase -v origin "${BRANCH}" >> "${LOGFILE}" 2>&1

            if [ "$STASHED" = true ]; then
                git stash pop
                log_info "${TIMESTAMP} Restored stashed changes after updating ${BRANCH}."
            fi
        else
            if has_changes; then
                git stash --include-untracked
                log_info "${TIMESTAMP} You have changes on ${BRANCH}, stashing them while updating ${DEFAULT_WORKING_BRANCH}..."
            fi

            git checkout "${DEFAULT_WORKING_BRANCH}" || continue
            echo "${TIMESTAMP}" >> "${LOGFILE}"
            git pull --rebase -v >> "${LOGFILE}" 2>&1

            if has_changes; then
                git checkout "${BRANCH}"
                git stash pop
                log_info "${TIMESTAMP} Restored changes on branch: ${BRANCH}"
            fi
        fi
    done
    unset IFS
}

main() {
    update_all_repos
}

main