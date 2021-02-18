#!/usr/bin/env bash

# get the paths for project root from the current path
CCPNMR_TOP_DIR="$(
    cd "$(dirname "$0")/../.." || exit
    pwd
)"
export CCPNMR_TOP_DIR
export VERSION_PATH=ccpnmr2.5
export CONDA="${CCPNMR_TOP_DIR}"/miniconda

# leave PYTHONPATH without underscore
export PYTHONPATH="${CCPNMR_TOP_DIR}/${VERSION_PATH}/python"
