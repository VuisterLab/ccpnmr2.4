#!/usr/bin/env bash

source ./paths.sh

# build paths
SKIP_SCRIPTS=""
SKIP_CODES=""
DATA_DIR=""
INCLUDE_FILES=""
SKIP_REPOSITORIES=(nefio)

# repositories contained in the project
REPOSITORY_NAMES=(ccpnmr2.4
    nefio)

REPOSITORY_PATHS=(${CCPNMR_TOP_DIR}
    ${CCPNMR_TOP_DIR}/${VERSION_PATH}/python/ccpnmr/nef)

REPOSITORY_RELATIVE_PATHS=(""
    /${VERSION_PATH}/python/ccpnmr/nef)

REPOSITORY_SOURCE=(https://github.com/VuisterLab
    git@bitbucket.org:ccpnmr)
