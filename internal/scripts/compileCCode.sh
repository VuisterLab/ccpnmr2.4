#!/usr/bin/env bash
# Compile C Code for the current environment, should be executed from the end of installMiniconda
# ejb 19/9/17
#
# Remember to check out the required release in Pycharm, or manually with git in each repository.
#
# recompile the c code.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# import settings
source ./common.sh

WINDOWS_COMPILE="${CCPNMR_TOP_DIR}/internal/scripts/callNMake.bat"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# start of code

detect_os
get_machine
get_machine_append
get_bit_count
echo "current machine: ${MACHINE}, ${BIT_COUNT}"

# check whether using a Mac

check_darwin

# make a symbolic link for the miniconda path (if it does not exists)

echo "copying miniconda folder"
if is_windows; then
    CONDA_DEFAULT="${HOME}/${WINDOWS_DEFAULT_CONDA}"
else
    CONDA_DEFAULT="${HOME}/${LINUX_DEFAULT_CONDA}"
fi

while true; do
    read -rp "Please enter miniconda installation path [${CONDA_DEFAULT}]: " CONDA_PATH
    CONDA_PATH="${CONDA_PATH:-$CONDA_DEFAULT}"
    if [[ -d "${CONDA_PATH}" ]]; then
        break
    fi
    echo "path not found or not a directory"
done

CONDA_CCPN_PATH="${CONDA_PATH}/envs/${CONDA_SOURCE}"
cd "${CCPNMR_TOP_DIR}" || exit
if [[ ! -d "${CONDA_CCPN_PATH}" ]]; then
    echo "Error compiling - conda environment ${CONDA_SOURCE} does not exist"
    exit
fi
if [[ ! -d miniconda ]]; then
    echo "Creating miniconda symbolic link"
    make_link "${CONDA_CCPN_PATH}" miniconda
fi

# copy the correct environment file

echo "compiling C Code"
cd "${CCPNMR_TOP_DIR}/${VERSION_PATH}/c" || exit

echo "using environment_${MACHINE}.txt"
if [[ ! -f environment_${MACHINE}.txt ]]; then
    echo "environment doesn't exists with this name, please copy closest and re-run compileCCode"
    exit
fi

# run 'make'

echo "setting up environment file"

# copy the required environment for the makefile
if is_windows; then
    # change Windows path
    CONDA=$(windows_path "${CONDA}")
fi

CONDA_HEADER="PYTHON_DIR = ${CONDA}"
CONDA_HEADER_ENV="CONDA_ENV = ${CONDA_SOURCE}"

# insert the PYTHON_DIR and CONDA_ENV into the first line of the environment file (CONDA_ENV not strictly required)
(
    echo "${CONDA_HEADER}"
    echo "${CONDA_HEADER_ENV}"
    tail -n +3 environment_${MACHINE}.txt
) >environment.txt
error_check

echo "making path ${CCPNMR_TOP_DIR}/${VERSION_PATH}/c"
if is_windows; then
    # call Windows nmake, opens a windows shell with the x64 native vs2019 .bat file
    nmakePath=$(windows_path "${WINDOWS_COMPILE}")
    "${nmakePath}"
else
    make -B $*
    make links
fi

# testing code - keep for now
#    CONDA="$(echo "${CONDA}" | sed -e 's/^\///' -e 's/\//\\/g' -e 's/^./\0:/')"
#    cmd <<< "call \"${nmakePath}\""
#    windowsCmdPath=$(windows_path "${windowsCmd}")
#    windowsPath=$(windows_path "${CCPNMR_TOP_DIR}/${VERSION_PATH}/c")
#    # this works but has a nested windows x64 native shell
#    cmd <<< "call \"${windowsCmdPath}\" && nmake"
#    cmd <<< "call \"${windowsCmdPath}\" && cd \"${windowsPath}\" && cd .. && dir"
