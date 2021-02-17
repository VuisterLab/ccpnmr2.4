#!/usr/bin/env bash
# install for development environment
# ejb 19/9/17
# updated 17/2/21
#
# Download all repositories for CcpNmr v2.5.
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
source ./ccpnInternal.sh

PROJECT_DEFAULT=${HOME}/Projects/ccpnmr2.5
REMOTE_DEFAULT=origin
BITBUCKET_WEBSITE=bitbucket.org

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# start of code

echo "~~~~~~~~~~~~~~~~~~~~~~~~"
echo "CcpNmr V2.5 installation"
echo "~~~~~~~~~~~~~~~~~~~~~~~~"

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
            echo "Usage: $0"
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

if [[ ! -d ${PROJECT_PATH} ]]; then
    if [[ "${FORCE_ARG}" != "True" ]]; then
        continue_prompt "Create new directory ${PROJECT_PATH} and continue?"
    else
        echo "Force create project path: True"
    fi
    echo "Creating directory"
    mkdir -p "${PROJECT_PATH}"
else
    if [[ "${FORCE_ARG}" != "True" ]]; then
        continue_prompt "Directory ${PROJECT_PATH} exists, do you want to continue?"
    else
        echo "Force create project path: True"
    fi
    echo "overwriting ${PROJECT_PATH}"
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
        CHECK_GIT=$(ssh -T git@${BITBUCKET_WEBSITE})
        if [[ "${CHECK_GIT}" == *"logged in as"* ]]; then
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

    for ((REP = 0; REP < ${#REPOSITORY_NAMES[@]}; REP++)); do

        # concatenate paths to give the correct install path
        # paths are defined in ./ccpnInternal.sh
        THIS_REP=${REPOSITORY_NAMES[$REP]}
        THIS_PATH=${PROJECT_PATH}${REPOSITORY_RELATIVE_PATHS[$REP]}
        THIS_SOURCE=${REPOSITORY_SOURCE[$REP]}

        error_check

        #PARENT=$(echo ${THIS_PATH} | rev | cut -d'/' -f2- | rev)
        if [[ -d ${THIS_PATH} ]]; then
            # cloning into an already existing path will cause fatal git error
            # if the path already exists, it will be moved to path with date/time extension
            # for nested repositories, the top-level may move everything

            if [[ "${EXISTING}" == "True" ]]; then
                DT=$(date '+%d-%m-%Y_%H:%M:%S')
                OLD_PATH=${THIS_PATH}_${DT}

                echo "Repository already exists, it will be moved to ${OLD_PATH}"
                mv "${THIS_PATH}" "${OLD_PATH}"

                # clone the repository
                error_check
                echo "Cloning repository into ${THIS_PATH}"
                git clone "${THIS_SOURCE}/${THIS_REP}".git "${THIS_PATH}"
            else
                echo "Skipping repository ${THIS_PATH}"
            fi
        else
            # clone the repository
            error_check
            echo "Cloning repository into ${THIS_PATH}"
            git clone "${THIS_SOURCE}/${THIS_REP}".git "${THIS_PATH}"
        fi
    done
fi

# checkout the required release

if [[ "${GIT_CHECKOUT}" == "True" ]]; then
    echo "Switching repositories to branch ${GIT_RELEASE}"

    for ((REP = 0; REP < ${#REPOSITORY_NAMES[@]}; REP++)); do

        # concatenate paths to give the correct install path
        THIS_REP=${REPOSITORY_NAMES[${REP}]}
        THIS_PATH=${PROJECT_PATH}${REPOSITORY_RELATIVE_PATHS[$REP]}
        THIS_SOURCE=${REPOSITORY_SOURCE[$REP]}

        if [[ -d ${THIS_PATH} ]]; then
            cd "${THIS_PATH}" || exit
            echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
            echo "Fetching branch ${THIS_PATH}"
            git fetch --all

            # only checkout if the branch exists
            if [[ "$(git ls-remote --heads "${THIS_SOURCE}/${THIS_REP}".git "${GIT_RELEASE}" | wc -l)" -eq "1" ]]; then
                echo "Checkout path ${THIS_PATH} to branch ${GIT_RELEASE} - using ${REMOTE_SOURCE} as tracked remote"
                git checkout -B "${GIT_RELEASE}" --track "${REMOTE_SOURCE}/${GIT_RELEASE}"
                echo "Resetting branch ${THIS_PATH} to ${REMOTE_SOURCE}/${GIT_RELEASE}"
                git reset --hard "${REMOTE_SOURCE}/${GIT_RELEASE}"
            else
                echo "Branch doesn't exists: ${THIS_SOURCE}/${THIS_REP}.git ${GIT_RELEASE}"
            fi
        fi
    done
fi

echo "Done"
