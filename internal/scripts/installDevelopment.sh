#!/usr/bin/env bash
# install for development environment
# ejb 19/9/17
# updated 17/2/21
#
# Download all repositories for Project.
#
#    Usage:
#
#        -cC   clone repositories
#        -eE   include existing repositories
#        -gG   checkout the release branch defined in version.sh
#        -p <path>    specify download path
#        -P    use default path PROJECT_DEFAULT
#        -kK   generate ssh-keygen for git/bitbucket, this will open the bitbucket website
#        -h    display help
#        -r <remote>  specify name for remote
#        -R    use default remote [origin]
#        -F    force create project path
#
#    Use uppercase to set True, lowercase to set to False where the option is available. Unset will request input.
#
#    To clone all repositories without user input:
#
#    ./installDevelopment.sh -CEGPkRF

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# import settings
source ./common.sh
source ./projectSettings.sh

REMOTE_DEFAULT=origin
BITBUCKET_WEBSITE=bitbucket.org

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# start of code

# make a heading
title="${PROJECT_TITLE} installation"
chars=${#title}
divider=$(head -c ${chars} < /dev/zero | tr "\0" "~")

echo ${divider}
echo ${title}
echo ${divider}

# process arguments

while getopts ":eEcClLgGp:PkKhr:RF" OPT; do
    case ${OPT} in
        e)
            [[ "${EXISTING_ARG}" != "" ]] && die_getopts "-eE already specified"
            EXISTING_ARG=False
            ;;
        c)
            [[ "${CLONE_ARG}" != "" ]] && die_getopts "-cC already specified"
            CLONE_ARG=False
            ;;
        g)
            [[ "${GIT_CHECKOUT_ARG}" != "" ]] && die_getopts "-gG already specified"
            GIT_CHECKOUT_ARG=False
            ;;
        p)
            [[ "${PATH_ARG}" != "" ]] && die_getopts "-pP already specified"
            PATH_ARG=${OPTARG}
            ;;
        r)
            [[ "${REMOTE_ARG}" != "" ]] && die_getopts "-rR already specified"
            REMOTE_ARG=${OPTARG}
            ;;
        k)
            [[ "${KEYGEN_ARG}" != "" ]] && die_getopts "-kK already specified"
            KEYGEN_ARG=False
            ;;
        E)
            [[ "${EXISTING_ARG}" != "" ]] && die_getopts "-eE already specified"
            EXISTING_ARG=True
            ;;
        C)
            [[ "${CLONE_ARG}" != "" ]] && die_getopts "-cC already specified"
            CLONE_ARG=True
            ;;
        G)
            [[ "${GIT_CHECKOUT_ARG}" != "" ]] && die_getopts "-gG already specified"
            GIT_CHECKOUT_ARG=True
            ;;
        P)
            [[ "${PATH_ARG}" != "" ]] && die_getopts "-pP already specified"
            PATH_ARG=${PROJECT_DEFAULT}
            ;;
        R)
            [[ "${REMOTE_ARG}" != "" ]] && die_getopts "-rR already specified"
            REMOTE_ARG=${REMOTE_DEFAULT}
            ;;
        K)
            [[ "${KEYGEN_ARG}" != "" ]] && die_getopts "-kK already specified"
            KEYGEN_ARG=True
            ;;
        F)
            [[ "${FORCE_ARG}" != "" ]] && die_getopts "-F already specified"
            FORCE_ARG=True
            ;;
        h)
            echo "Usage: $0 [-cC] [-eE] [-gG] [-p <path] -P [-kK] -h [-r <remote>] -R -F"
            echo "-cC   clone repositories"
            echo "-eE   include existing repositories"
            echo "-gG   checkout the release branch defined in version.sh"
            echo "-p <path>    specify download path"
            echo "-P    use default path <${PROJECT_DEFAULT}>"
            echo "-kK   generate ssh-key for git/bitbucket, this will open the bitbucket website"
            echo "-h    display help"
            echo "-r <remote>   specify name for remote"
            echo "-R    use default remote [${REMOTE_DEFAULT}]"
            echo "-F    force create project path"
            echo "Use uppercase to set True, lowercase to set to False where the option is available. Unset will request input."
            echo "To clone all repositories without user input:"
            echo "$0 -CEGPkRF"
            exit
            ;;
        *)
            echo $"Usage: $0 -h for options"
            exit
            ;;
    esac
done
shift $((OPTIND - 1))

# initialise parent path

if [[ "${PATH_ARG}" == "" ]]; then
    read -rp "Please download path [${PROJECT_DEFAULT}]: " PROJECT_PATH
else
    PROJECT_PATH=${PATH_ARG}
fi
PROJECT_PATH="${PROJECT_PATH:-$PROJECT_DEFAULT}"
echo "Use project path: ${PROJECT_PATH}"

if [[ -d ${PROJECT_PATH} ]]; then
    if [[ "${FORCE_ARG}" != "True" ]]; then
        continue_prompt "Directory ${PROJECT_PATH} exists, do you want to continue?"
    else
        echo "${PROJECT_PATH} already exists"
    fi
fi

# set remote

if [[ "${REMOTE_ARG}" == "" ]]; then
    read -rp "Please enter name for remote [${REMOTE_DEFAULT}]: " REMOTE_SOURCE
else
    REMOTE_SOURCE=${REMOTE_ARG}
fi
REMOTE_SOURCE="${REMOTE_SOURCE:-$REMOTE_DEFAULT}"
echo "Use remote: ${REMOTE_SOURCE}"

# check whether using a Mac

check_darwin

# ask for inputs at the beginning of script

if [[ "${CLONE_ARG}" == "" ]]; then
    CLONE=$(execute_codeblock "Do you want to clone repositories?")
else
    CLONE=${CLONE_ARG}
    echo "Clone repositories: ${CLONE}"
fi
if [[ "${EXISTING_ARG}" == "" ]]; then
    EXISTING=$(execute_codeblock "Do you want to include existing repositories?")
else
    EXISTING=${EXISTING_ARG}
    echo "Include existing repositories: ${EXISTING}"
fi
if [[ "${GIT_CHECKOUT_ARG}" == "" ]]; then
    GIT_CHECKOUT=$(execute_codeblock "Do you want to checkout ${GIT_RELEASE}?")
else
    GIT_CHECKOUT=${GIT_CHECKOUT_ARG}
    echo "Check out ${GIT_RELEASE}: ${GIT_CHECKOUT}"
fi
if [[ "${KEYGEN_ARG}" == "" ]]; then
    KEYGEN=$(execute_codeblock "Do you want to create an SSH key?")
else
    KEYGEN=${KEYGEN_ARG}
    echo "Create ssh-key: ${KEYGEN}"
fi

# create an SSH key for git access

if [[ "${KEYGEN}" == "True" ]]; then
    echo "Generating ssh-key..."
    ssh-keygen

    echo "...a website should have opened to https://${BITBUCKET_WEBSITE}"
    echo "login; navigate to 'Your profile and settings'"
    echo "                     'Bitbucket settings'"
    echo "                       'Security: SSH Keys'"
    echo "and click 'Add Key'"
    echo "Paste the whole of the following line into the box labelled 'Key*':"
    cat "${HOME}/.ssh/id_rsa.pub"

    python -m webbrowser -t "https://${BITBUCKET_WEBSITE}"
    space_continue

    if [[ $(execute_codeblock "Do you want to test your ssh-key?") == "True" ]]; then
        echo "Testing ssh-key..."
        checkGit=$(ssh -T git@${BITBUCKET_WEBSITE})
        if [[ "${checkGit}" == *"logged in as"* ]]; then
            echo "ssh-key okay"
        else
            echo "ssh-key not working"
            exit
        fi
    fi
fi

# need to download/clone and set up repositories here

if [[ "${CLONE}" == "True" ]]; then
    echo "Clone repositories"

    echo ${REPOSITORY_PATHS}
    for ((repNum = 0; repNum < ${#REPOSITORY_NAMES[@]}; repNum++)); do

        # concatenate paths to give the correct install path
        # paths are defined in ./projectSettings.sh
        thisRep=${REPOSITORY_NAMES[${repNum}]}
        thisPath=${PROJECT_PATH}${REPOSITORY_RELATIVE_PATHS[${repNum}]}
        thisSource=${REPOSITORY_SOURCE[${repNum}]}

        if [[ -d ${thisPath} ]]; then
            # cloning into an already existing path will cause fatal git error
            # if the path already exists, it will be moved to path with date/time extension
            # for nested repositories, the top-level may move everything

            if [[ "${EXISTING}" == "True" ]]; then
                dateTime=$(date '+%d-%m-%Y_%H:%M:%S')
                oldPath=${thisPath}_${dateTime}

                echo "Repository already exists, it will be moved to ${oldPath}"
                mv "${thisPath}" "${oldPath}" || exit

                # clone the repository
                echo "Cloning repository into ${thisPath}"
                git clone "${thisSource}/${thisRep}".git "${thisPath}"
            else
                echo "Skipping repository ${thisPath}"
            fi
        else
            # clone the repository
            echo "Cloning repository into ${thisPath}"
            git clone "${thisSource}/${thisRep}".git "${thisPath}"
        fi
    done
fi

# checkout the required release

if [[ "${GIT_CHECKOUT}" == "True" ]]; then
    echo "Switching repositories to branch ${GIT_RELEASE}"

    for ((repNum = 0; repNum < ${#REPOSITORY_NAMES[@]}; repNum++)); do

        # concatenate paths to give the correct install path
        thisRep=${REPOSITORY_NAMES[${repNum}]}
        thisPath=${PROJECT_PATH}${REPOSITORY_RELATIVE_PATHS[${repNum}]}
        thisSource=${REPOSITORY_SOURCE[${repNum}]}

        if [[ -d ${thisPath} ]]; then
            cd "${thisPath}" || exit
            echo ${divider}
            echo "Fetching branch ${thisPath}"
            git fetch --all

            # only checkout if the branch exists
            if [[ "$(git ls-remote --heads "${thisSource}/${thisRep}".git "${GIT_RELEASE}" | wc -l)" -eq "1" ]]; then
                echo "Checkout path ${thisPath} to branch ${GIT_RELEASE} - using ${REMOTE_SOURCE} as tracked remote"
                git checkout -B "${GIT_RELEASE}" --track "${REMOTE_SOURCE}/${GIT_RELEASE}"
                echo "Resetting branch ${thisPath} to ${REMOTE_SOURCE}/${GIT_RELEASE}"
                git reset --hard "${REMOTE_SOURCE}/${GIT_RELEASE}"
            else
                echo "Branch doesn't exists: ${thisSource}/${thisRep}.git ${GIT_RELEASE}"
            fi
        fi
    done
fi

echo "Done"
