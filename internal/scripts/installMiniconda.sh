#!/usr/bin/env bash
# Install miniconda and apply patches
# ejb 19/9/17
#
# Remember to check out the required release in Pycharm, or manually with git in each repository.
#
# download and install the miniconda package and create the required environment for project
#
# to make a patch
# reinstall pyqtgraph first: conda install -f pyqtgraph
# copy the required file to a new file, make alterations
# generate difference
#   diff -u <newfile> <oldfile>
# automatic culling of whitespace must be disabled in editor (Atom specifically) if viewing these files
# copy/paste into patch file below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# import settings
source ./common.sh
SCRIPT_EXTENSION=".sh"
WINDOWS_EXTENSION=".exe"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# start of code

detect_os
get_machine
get_machine_append
get_bit_count
echo "current machine: ${MACHINE}, ${BIT_COUNT}"

# check whether using a Mac and set environment paths

check_darwin

# download the latest version of miniconda

CONDA_SITE="http://repo.continuum.io"
CONDA_VER="Miniconda3-latest-${MACHINE}${MACOS_APPEND}-${BIT_COUNT}"
if is_windows; then
    CONDA_DEFAULT="${HOME}/${WINDOWS_DEFAULT_CONDA}"
else
    CONDA_DEFAULT="${HOME}/${LINUX_DEFAULT_CONDA}"
fi

if is_windows; then
    echo "Please install Miniconda manually - miniconda causes many problems for this installer :)"
    echo "and select 'n' to installing a new version of miniconda"
    continue_prompt "If you have already installed Miniconda, would you like to continue?"
fi

while true; do
    read -rp "Please enter Miniconda installation path [${CONDA_DEFAULT}]: " CONDA_PATH
    CONDA_PATH="${CONDA_PATH:-$CONDA_DEFAULT}"
    if [[ -d "${CONDA_PATH}" ]]; then
        break
    fi
    echo "path not found or not a directory"
done

CONDA_ENV_PATH=ccpnmr2.5/c
CONDA_CCPN_PATH="${CONDA_PATH}/envs/${CONDA_SOURCE}"

yesno_prompt "Do you want to download/install the latest Miniconda?"
if [[ ${ANS} == "yes" ]]; then

    # install a new version of miniconda

    # Windows needs to .exe extension, Mac/Linux uses .sh
    if is_windows; then
        CONDA_FILE="${CONDA_VER}${WINDOWS_EXTENSION}"
    else
        CONDA_FILE="${CONDA_VER}${SCRIPT_EXTENSION}"
    fi

    echo "checking website for file ${CONDA_FILE}"

    if ! curl --output /dev/null --silent --head --fail --connect-timeout 3 "${CONDA_SITE}"; then
        echo "miniconda download page is not responding, please try later"
        exit
    else
        continue_prompt "URL active, continue with download?"
    fi

    echo "downloading ${CONDA_FILE}"
    cd "${CCPNMR_TOP_DIR}/${CONDA_ENV_PATH}" || exit

    # download the file
    if command_exists wget; then
        wget -c --no-check-certificate "${CONDA_SITE}/miniconda/${CONDA_FILE}"
    elif command_exists curl; then
        curl -O -L "${CONDA_SITE}/miniconda/${CONDA_FILE}"
    else
        echo "ERROR: neither wget nor curl exist, please install one and run again."
        exit
    fi

    if [[ ! -f ${CONDA_FILE} ]]; then
        echo "ERROR - not downloaded"
        echo "if you have the file ${CONDA_FILE}, copy it to this directory and try again"
        exit
    fi
    # change permissions to executable
    chmod +x "${CONDA_FILE}"

    # preparing miniconda directory
    # miniconda install will exit if path exists
    # this assumes that you have already installed in the default location
    # any other directory will need to be manually deleted

    if [[ -d ${CONDA_PATH} ]]; then
        cd "${HOME}" || exit
        continue_prompt "${CONDA_PATH} already exists, do you want to continue (will delete)?"
        echo "deleting miniconda3"
        rm -rf miniconda3
    fi

    # installing miniconda

    echo "installing miniconda"
    #echo " - please select the default location, and choose 'yes' for prepending paths"
    cd "${CCPNMR_TOP_DIR}/${CONDA_ENV_PATH}" || exit
    ./"${CONDA_FILE}" -b -p "${CONDA_PATH}"

    BASH_RC=${HOME}/.bash_profile

    yesno_prompt "Do you wish the installer to prepend the Miniconda3 install
    location to PATH in your ${BASH_RC}?"

    if [[ ${ANS} == "yes" ]]; then
        if [[ -f ${BASH_RC} ]]; then
            echo "Prepending PATH=${CONDA_PATH}/bin to PATH in ${BASH_RC}
    A backup will be made to: ${BASH_RC}-miniconda3.bak"
            cp "${BASH_RC}" "${BASH_RC}-miniconda3.bak"
        else
            echo "Prepending PATH=${CONDA_PATH}/bin to PATH in newly created ${BASH_RC}"
        fi
        echo "For this change to become active, you have to open a new terminal."
        echo "
    # added by Miniconda3 installer, CcpNmr Installation
    export PATH=\"${CONDA_PATH}/bin:\${PATH}\"" >> "${BASH_RC}"
    fi
fi

yesno_prompt "Do you want to install a new environment?"
if [[ ${ANS} == "yes" ]]; then

    # create CcpNmr environment

    echo "creating environment from environment_${MACHINE}.yml"
    cd "${CCPNMR_TOP_DIR}/${CONDA_ENV_PATH}" || exit

    # copy required environment and insert correct source into 4th line to keep comments

    CONDA_HEADER="name: ${CONDA_SOURCE}"
    (
        head -n 3 "environment_${MACHINE}.yml"
        echo "${CONDA_HEADER}"
        tail -n +5 "environment_${MACHINE}.yml"
    ) > environment.yml

    # execute that shell script to make sure the paths are set

    if [[ -f "${HOME}/.bash_profile" ]]; then
        echo "executing ~/.bash_profile"
        source "${HOME}/.bash_profile"
        error_check
    fi
    if [[ -f "${HOME}/.bashrc" ]]; then
        echo "executing ~/.bashrc"
        source "${HOME}/.bashrc"
        error_check
    fi

    # # just for certain
    #if [[ "${PATH}" != *"${CONDA_PATH}/bin"* ]]; then
    #  export PATH="${CONDA_PATH}/bin:${PATH}"
    #fi

    conda init bash
    conda update conda
    conda activate
    if [[ -d "${CONDA_CCPN_PATH}" ]]; then
        conda env remove -n "${CONDA_SOURCE}"
    fi
    error_check
    conda config --set ssl_verify false
    conda env create -f "environment.yml"
    error_check
    if [[ ! -d "${CONDA_CCPN_PATH}" ]]; then
        echo "Error installing ${CONDA_SOURCE} from environment_${MACHINE}.yml"
        exit
    fi
    conda config --set ssl_verify true

    cd "${CCPNMR_TOP_DIR}/${CONDA_ENV_PATH}" || exit

    # activate env which sets path to <condainstallpath/envs/current environment> then strip off 'python'
    conda activate "${CONDA_SOURCE}"
fi

yesno_prompt "Do you want to create symbolic link?"
if [[ ${ANS} == "yes" ]]; then

    # remove old link and make new link

    echo "path to miniconda: ${CONDA_CCPN_PATH}"
    cd "${CCPNMR_TOP_DIR}" || exit
    if [[ ! -d "${CONDA_CCPN_PATH}" ]]; then
        echo "Error compiling - conda environment ${CONDA_SOURCE} does not exist"
        exit
    fi
    if [[ -d miniconda ]]; then
        # remove the old link
        remove_link miniconda
    fi
    make_link "${CONDA_CCPN_PATH}" miniconda
fi

# clean up directory

echo "cleaning up"
cd "${CCPNMR_TOP_DIR}/${CONDA_ENV_PATH}" || exit
if is_windows; then
    # sometimes causes problems with Anaconda install
    /usr/bin/rm -rf "${CONDA_FILE}"
else
    rm -rf "${CONDA_FILE}"
fi

# compile C Code

cd "${CCPNMR_TOP_DIR}/internal/scripts" || exit

echo "done - please run internal/scripts/compileCCode.sh to finish"
