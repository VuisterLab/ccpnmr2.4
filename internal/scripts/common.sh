#!/usr/bin/env bash

# import settings
source ./version.sh
source ./paths.sh

# Operating system list
OS_LIST=(Linux MacOS Windows Irix Solaris)
PYQT="PyQt5"
PYTHON_VERSION="3.8"

# available functions

git_repository() {
    # return the current git_repository
    GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    echo "${GIT_BRANCH}"
}

check_git_repository() {
    # check that the current path contains the correct branch
    GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    THIS_PATH="$(pwd)"

    if [[ ${GIT_BRANCH} == "${GIT_RELEASE}" ]]; then
        echo "correct git branch on path: $THIS_PATH"
    else
        echo "*** Not correct branch ***"
        exit
    fi
}

local_git_exists() {
    LOCAL_EXISTS="$(git branch --list ${1})"

    if [[ -z ${LOCAL_EXISTS} ]]; then
        echo 0
    else
        echo 1
    fi
}

continue_prompt() {
    # prompt for a yes/no answer
    # answering no will terminate

    # input $1 can still contain trailing question mark for clarity
    if [[ "$1" == *"?" ]]; then
        # remove the question mark from the end
        prompt=$(echo ${1:0:${#1}-1})
    else
        prompt=$1
    fi

    while true; do
        read -rp "${prompt} [Yy/Nn]?" yn
        case ${yn} in
            [Yy]*) break ;;
            [Nn]*) exit ;;
            *) echo "Please answer [Yy/Nn]" ;;
        esac
    done
}

yesno_prompt() {
    # prompt for a yes/no answer
    # program flow will continue

    # input $1 can still contain trailing question mark for clarity
    if [[ "$1" == *"?" ]]; then
        # remove the question mark from the end
        prompt=$(echo ${1:0:${#1}-1})
    else
        prompt=$1
    fi

    while true; do
        read -rp "${prompt} [Yy/Nn]?" yn
        case ${yn} in
            [Yy]*)
                ANS="yes"
                break
                ;;
            [Nn]*)
                ANS="no"
                break
                ;;
            *) echo "Please answer [Yy/Nn]" ;;
        esac
    done
}

detect_os() {
    # detect the current OS type
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*) MACHINE=Linux ;;
        Darwin*) MACHINE=MacOS ;;
        CYGWIN*) MACHINE=Windows ;;
        IRIX*) MACHINE=Irix ;;
        Sun*) MACHINE=Solaris ;;
        *) MACHINE="UNKNOWN:${unameOut}" ;;
    esac
}

show_choices() {
    # show OS choices in a table
    echo "OS types allowed"
    echo "~~~~~~~~~~~~~~~~"
    INDEX=1
    for thisOS in ${OS_LIST[*]}; do
        echo "  $INDEX. $thisOS"
        INDEX=$((INDEX + 1))
    done
    echo "  $INDEX. exit"
    EXIT_VAL=${INDEX}
}

get_digit() {
    # read a digit from the user, until between 1 and n
    while true; do
        read -rsn1 NUM
        case ${NUM} in
            [0123456789]*)
                echo "${NUM}"
                break
                ;;
            *) ;;
        esac
    done
}

read_choice() {
    # read a choice from the user
    CHOICE=0
    while true; do
        read -rp "$2" CHOICE
        if [[ $((CHOICE)) != "${CHOICE}" ]]; then
            echo "not a number"
        else
            if [[ ${CHOICE} == $(($1 + 1)) ]]; then
                exit
            fi
            if [[ ${CHOICE} -ge 1 && ${CHOICE} -le $1 ]]; then
                break
            fi
        fi
    done
    MACHINE=${OS_LIST[$((CHOICE - 1))]}
}

execute_codeblock() {
    # prompt for a yes/no answer, and return True or False
    # (may be to similar to yesno_prompt)

    # input $1 can still contain trailing question mark for clarity
    if [[ "$1" == *"?" ]]; then
        # remove the question mark from the end
        prompt=$(echo ${1:0:${#1}-1})
    else
        prompt=$1
    fi

    while true; do
        read -rp "${prompt} [Yy/Nn]?" yn
        case ${yn} in
            [Yy]*)
                echo 'True'
                break
                ;;
            [Nn]*)
                echo 'False'
                break
                ;;
            *) echo "Please answer [Yy/Nn]" ;;
        esac
    done
}

space_continue() {
    # wait for space bar
    read -n1 -rp "press space to continue..." KEY
    echo ""
}

error_check() {
    # check whether any OS errors occurred after the last operation
    # exit on any error
    if [[ $? != 0 ]]; then
        exit
    fi
}

function relative_path() {
    # return the relative path to the current path using python script
    python -c "import os,sys; print(os.path.relpath(*(sys.argv[1:])))" "$@"
}

function windows_path() {
    # return the current path - translates to machine specific path
    python -c "import os,sys; print(os.path.abspath(*(sys.argv[1:])))" "$@"
}

command_exists() {
    # check whether the given command exists
    command -v "$1" >/dev/null 2>&1
}

check_darwin() {
    # check if using a Mac and set fallback environment variables
    if is_darwin; then
        export DYLD_FALLBACK_LIBRARY_PATH=/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ImageIO.framework/Versions/A/Resources:
        export DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH}${CONDA}/lib:
        export DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH}${CONDA}/lib/python${PYTHON_VERSION}/site-packages/${PYQT}:
        export DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH}${HOME}/lib:/usr/local/lib:/usr/lib
    fi
}

die_getopts() {
    # print in error string and quit
    echo "ERROR: $*." >&2
    exit 1
}

isDirInPath() {
    # check whether the PATH contains a given directory
    case ":${PATH}:" in
        *:"$1":*) return 0 ;;
        *) return 1 ;;
    esac
}

check_item_in_list() {
    # Check whether the first argument is contained in the following list
    local item
    local msg="$1"   # Save first argument in a variable
    shift            # Shift all arguments to the left (original $1 gets lost)
    local arr=("$@") # Get the remaining arguments as a set
    for item in "${arr[@]}"; do
        [[ "${item}" == "${msg}" ]] && echo "true"
        return
    done
}

is_windows() {
    # check whether windows
    [[ -n "${WINDIR}" ]];
    # UNAME="$(uname -s)"
    # [[ ${UNAME} == *"Win"* || ${UNAME} == *"MING"* ]]
}

is_darwin() {
    # check whether darwin (MacOS)
    UNAME="$(uname -s)"
    [[ ${UNAME} == "Darwin*" ]];
}

make_link() {
    # Cross-platform symlink function. With one parameter, it will check
    # whether the parameter is a symlink. With two parameters, it will create
    # a symlink to a file or directory.
    # Usage: make_link $target $link
    # target: file to link to - same ordering as linux
    # link: new link to be created
    target=$1
    link=$2
    if [[ -z "${link}" ]]; then
        # Link-checking mode; test the target
        if is_windows; then
            targetPath=$(windows_path "${target}")
            cmd <<< "fsutil reparsepoint query \"${targetPath}\"" > /dev/null
        else
            [[ -h "${target}" ]]
        fi
    else
        # Link-creation mode.
        if [[ ! -e "${link}" && -e "${target}" ]]; then
            if is_windows; then
                # Windows needs to be told if it's a directory or not. Infer that.
                targetPath=$(windows_path "${target}")
                linkPath=$(windows_path "${link}")
                # windows is reversed order
                if [[ -d "${target}" ]]; then
                    cmd <<< "mklink /D \"${linkPath}\" \"${targetPath}\"" > /dev/null
                else
                    cmd <<< "mklink \"${linkPath}\" \"${targetPath}\"" > /dev/null
                fi
            else
                # linux parameters the other way around
                ln -s "${target}" "${link}"
            fi
        fi
    fi
}

remove_link() {
    # Remove a link, cross-platform.
    # Usage: remove_link $target
    # target: link/file to remove
    target=$1
    if [[ -e "${target}" ]]; then
        if is_windows; then
            # Again, Windows needs to be told if it's a file or directory.
            # Use python Path function
            targetPath=$(windows_path "${target}")
            if [[ -d "${target}" ]]; then
                cmd <<< "rmdir \"${targetPath}\"" > /dev/null
            else
                cmd <<< "del /f \"${targetPath}\"" > /dev/null
            fi
        else
            rm -r "${target}"
        fi
    fi
}

# rename a directory, cross-platform
rename_directory() {
    # Usage: rename_directory $target $newName
    # target: directory to rename
    # newName: new name
    target=$1
    newName=$2
    if [[ -e "${target}" ]]; then
        if is_windows; then
            # Again, Windows needs to be told if it's a file or directory.
            # Use python Path function
            targetPath=$(windows_path "${target}")
            newNamePath=$(windows_path "${newName}")
            if [[ -d "${target}" ]]; then
                cmd <<< "rename \"${targetPath}\" \"${newNamePath}\"" > /dev/null
            fi
        else
            mv -v "${target}" "${newName}"
        fi
    fi
}
