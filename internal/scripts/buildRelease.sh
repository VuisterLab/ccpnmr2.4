#!/usr/bin/env bash
# build a project release distribution
# ejb 11/9/17
#
# Remember to check out the required release in Pycharm, or manually with git in each repository.
#
# Take the existing RELEASE_VERSION version of project from ./version.sh
# and create a HOME/release<Name>/RELEASE_VERSION directory as a stand-alone without
# development directories
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# import settings
source ./common.sh
source ./projectSettings.sh

BUILD_ZIP=True

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# start of code

# check whether using a Mac

check_darwin

# Check if all the git repositories are correct

echo "Checking git repositories:"
for ((repNum = 0; repNum < ${#REPOSITORY_NAMES[@]}; repNum++)); do

    # concatenate paths to give the correct install path
    thisRep=${REPOSITORY_NAMES[${repNum}]}
    thisPath=${REPOSITORY_PATHS[${repNum}]}

    cd "${thisPath}" || exit
    if [[ ! ${SKIP_REPOSITORIES[*]} =~ ${thisRep} ]]; then
        # whatever you want to do when arr contains value
        check_git_repository
    fi
done

# Get the machine type to label the path

detect_os
get_machine

# setup correct folders for the Windows and others
if is_windows; then
    INCLUDE_DIRS="bat ${VERSION_PATH} doc"
else
    INCLUDE_DIRS="bin ${VERSION_PATH} doc"
fi

# set the new pathname

RELEASE_DEFAULT=""
read -rp "Enter name for release [${RELEASE_DEFAULT}] (suggest adding linux flavour): " RELEASE_NAME
RELEASE_NAME="${RELEASE_NAME:-$RELEASE_DEFAULT}"

# remove all quotes and spaces - not needed here as an appended name
RELEASE_NAME="$(echo "${RELEASE_NAME}" | tr -d " \'\"\`")"

INCLUDE_MACHINE_NAME=$(execute_codeblock "do you want to append the machine name (suggest n if adding release name for linux)?")

# make the required pathnames
RELEASE="release${RELEASE_VERSION}${RELEASE_NAME}"
CCPNMR_PATH="ccpnmr${RELEASE_VERSION}"
if [[ "${INCLUDE_MACHINE_NAME}" == "True" ]]; then
    CCPNMR_FILE="ccpnmr${RELEASE_VERSION}${RELEASE_NAME}${MACHINE}"
else
    if [[ ${RELEASE_NAME} ]]; then
        CCPNMR_FILE="ccpnmr${RELEASE_VERSION}${RELEASE_NAME}"
    else
        echo "Error - release name must be defined"
        exit
    fi
fi

# echo current settings

echo "Home:         ${HOME}"
echo "Release path: ${RELEASE}"
echo "CcpnNmrPath:  ${CCPNMR_PATH}"
echo "File:         ${CCPNMR_FILE}"

## get the required LicenceKey file
#
#read -rp "Enter LicenceKey file: " LICENCEKEY_FILE
#
## remove all quotes - not needed here as a single filename - must keep spaces though
#LICENCEKEY_FILE="$(echo "${LICENCEKEY_FILE}" | tr -d "\'\"\`")"
#echo "${LICENCEKEY_FILE}"
#
#if [[ ! -f "${LICENCEKEY_FILE}" ]]; then
#  echo "Error reading LicenceKey file"
#  exit
#else
#  cp "${LICENCEKEY_FILE}" "${CCPNMR_TOP_DIR}/config/licenceKey.txt"
#  error_check
#fi
#
## get the required Licensing Document LICENSE.txt file
#
#read -rp "Enter Licence Document (LICENSE.txt): " LICENCE_DOCUMENT
#
## remove all quotes - not needed here as a single filename - must keep spaces though
#LICENCE_DOCUMENT="$(echo "${LICENCE_DOCUMENT}" | tr -d "\'\"\`")"
#echo "${LICENCE_DOCUMENT}"
#
#if [[ ! -f "${LICENCE_DOCUMENT}" ]]; then
#  echo "Error reading Licence Document"
#  exit
#else
#  cp "${LICENCE_DOCUMENT}" "${CCPNMR_TOP_DIR}/LICENSE.txt"
#  error_check
#fi

# Create new directory for the release

echo "creating new directory ${HOME}/${RELEASE}"
if [[ ! -d "${HOME}/${RELEASE}" ]]; then
    # create the new release directory
    mkdir -p "${HOME}/${RELEASE}" || exit
else
    continue_prompt "directory already exists, do you want to move it and continue?"
    dateTime=$(date '+%d-%m-%Y_%H:%M:%S')
    # take ownership in windows to stop permission denied
    if is_windows; then
        chown -R "${USERNAME}" "${HOME}/${RELEASE}"
        chmod -R 755 "${HOME}/${RELEASE}"
    fi
    mv "${HOME}/${RELEASE}" "${HOME}/${RELEASE}_${dateTime}" || exit
    # create the new release directory
    mkdir -p "${HOME}/${RELEASE}" || exit
fi

# Make current build in release directory

echo "creating new directory ${HOME}/${RELEASE}/${CCPNMR_PATH}"
if [[ ! -d "${HOME}/${RELEASE}/${CCPNMR_PATH}" ]]; then
    # create the new release directory
    mkdir -p "${HOME}/${RELEASE}/${CCPNMR_PATH}" || exit
else
    continue_prompt "directory already exists, do you want to move it and continue?"
    dateTime=$(date '+%d-%m-%Y_%H:%M:%S')
    mv "${HOME}/${RELEASE}/${CCPNMR_PATH}" "${HOME}/${RELEASE}/${CCPNMR_PATH}_${dateTime}" || exit
fi

# Check if miniconda directory already exists

if [[ -d "${HOME}/${RELEASE}/${CCPNMR_PATH}/miniconda" ]]; then
    continue_prompt "miniconda already exists, do you want to continue?"
    dateTime=$(date '+%d-%m-%Y_%H:%M:%S')
    mv "${HOME}/${RELEASE}/${CCPNMR_PATH}/miniconda" "${HOME}/${RELEASE}/${CCPNMR_PATH}/miniconda_${dateTime}" || exit
fi

# Tar up the directories (skipping internal)

echo "compressing main directory"
cd "${CCPNMR_TOP_DIR}" || exit
echo "${HOME}/${RELEASE}/repository${RELEASE_VERSION}.tgz"

if command_exists pigz; then
    echo "using pigz"
    tar --use-compress-program=pigz -cf "${HOME}/${RELEASE}/repository${RELEASE_VERSION}.tgz" ${INCLUDE_FILES} ${INCLUDE_DIRS} ${DATA_DIR}
else
    tar czf "${HOME}/${RELEASE}/repository${RELEASE_VERSION}.tgz" ${INCLUDE_FILES} ${INCLUDE_DIRS} ${DATA_DIR}
fi

# Unpack the tgz in ${HOME}/${RELEASE}/${CCPNMR_PATH}

echo "unpacking main directory"
cd "${HOME}/${RELEASE}/${CCPNMR_PATH}" || exit
tar xzf "../repository${RELEASE_VERSION}.tgz"
error_check

echo "removing temporary file: repository${RELEASE_VERSION}.tgz"
rm -rf "../repository${RELEASE_VERSION}.tgz"
error_check

# Remove unneeded bin/bat scripts:

echo "removing unneeded scripts"
if [[ -d "${HOME}/${RELEASE}/${CCPNMR_PATH}/bin" ]]; then
    cd "${HOME}/${RELEASE}/${CCPNMR_PATH}/bin" || exit
    if [[ ${SKIP_SCRIPTS} ]]; then
        rm -rf ${SKIP_SCRIPTS}
    fi
fi
if [[ -d "${HOME}/${RELEASE}/${CCPNMR_PATH}/bat" ]]; then
    cd "${HOME}/${RELEASE}/${CCPNMR_PATH}/bat" || exit
    if [[ ${SKIP_WINSCRIPTS} ]]; then
        rm -rf ${SKIP_WINSCRIPTS}
    fi
fi

# Remove unneeded code

echo "removing unneeded code"
if [[ -d "${HOME}/${RELEASE}/${CCPNMR_PATH}/${VERSION_PATH}/python/ccpn" ]]; then
    cd "${HOME}/${RELEASE}/${CCPNMR_PATH}/${VERSION_PATH}/python/ccpn" || exit
    if [[ ${SKIP_CODES} ]]; then
        rm -rf ${SKIP_CODES}
    fi
fi
# Remove unnecessary files

echo "removing unneeded python/c/replace files"
if [[ -d "${HOME}/${RELEASE}/${CCPNMR_PATH}" ]]; then
    find "${HOME}/${RELEASE}/${CCPNMR_PATH}" -type f -name '*__old' -exec rm "{}" \;
fi
if [[ -d "${HOME}/${RELEASE}/${CCPNMR_PATH}/${VERSION_PATH}/python" ]]; then
    find "${HOME}/${RELEASE}/${CCPNMR_PATH}/${VERSION_PATH}/python" -type f -name '*.pyo' -exec rm "{}" \;
    find "${HOME}/${RELEASE}/${CCPNMR_PATH}/${VERSION_PATH}/python" -type f -name '*.pyc' -exec rm "{}" \;
fi
if [[ -d "${HOME}/${RELEASE}/${CCPNMR_PATH}/${VERSION_PATH}/c" ]]; then
    find "${HOME}/${RELEASE}/${CCPNMR_PATH}/${VERSION_PATH}/c" -type f -name '*.o' -exec rm "{}" \;
fi

# Copy miniconda code over:

echo "copying miniconda folder"
if is_windows; then
    cd "${HOME}/Anaconda3/envs" || exit
else
    cd "${HOME}/miniconda3/envs" || exit
fi

# need to be on the correct conda source

echo "compressing ${CONDA_SOURCE}"
if command_exists pigz; then
    echo "using pigz"
    tar --use-compress-program=pigz -cf "${CONDA_SOURCE}.tgz" "${CONDA_SOURCE}"
else
    tar czf "${CONDA_SOURCE}.tgz" "${CONDA_SOURCE}"
fi
error_check

mv "${CONDA_SOURCE}.tgz" "${HOME}/${RELEASE}/" || exit

# move directory check for ${HOME}/${RELEASE}/${CCPNMR_PATH}/miniconda to the top

echo "moving to ${RELEASE} directory"
cd "${HOME}/${RELEASE}/${CCPNMR_PATH}" || exit
tar xzf "../${CONDA_SOURCE}.tgz"
error_check
# take ownership in windows to stop permission denied
if is_windows; then
    chown -R "${USERNAME}" "${CONDA_SOURCE}"
    chmod -R 755 "${CONDA_SOURCE}"
fi
rm -rf miniconda
rename_directory "${CONDA_SOURCE}" miniconda

echo "removing ${CONDA_SOURCE}.tgz"
rm -rf "../${CONDA_SOURCE}.tgz"

# compress the remaining folder

echo "creating final tgz/zip"
cd "${HOME}/${RELEASE}" || exit
if is_windows; then
    # build .tgz files on non-Windows
    if command_exists pigz; then
        echo "using pigz"
        tar cf - "${CCPNMR_PATH}" | pigz -8 > "${HOME}/${RELEASE}/${CCPNMR_FILE}.tgz"
    else
        tar czf "${HOME}/${RELEASE}/${CCPNMR_FILE}.tgz" "${CCPNMR_PATH}"
    fi
fi

if command_exists 7za && [[ "$BUILD_ZIP" == "True" ]] && is_windows; then
    # Only build zips on Windows
    echo "using 7za"
    7za a -tzip -bd -mx=7 "${HOME}/${RELEASE}/${CCPNMR_FILE}.zip" "${CCPNMR_PATH}" > /dev/null
fi
echo "done"
