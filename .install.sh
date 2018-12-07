#!/bin/bash

function usage() {
	echo "-f	force installation + silentmode"
	echo "-p	installation path (default: ~/miniconda)"
	exit 1
}

function process_parameters() {
	while getopts f:p: Option
	do
		case "${Option}" in
    		f) FORCE=true
			;;
			p) PREFIX="${OPTARG}"
			;;
			*) usage
			;;
		esac
	done

  return 0
}


function main() {

    process_parameters "${@}"

    if [[ $FORCE = true ]]; then
        bash Miniconda.sh -f -b -p "${PREFIX}"
    else
        bash Miniconda.sh -b -p "${PREFIX}"
    fi

    export PATH="${PREFIX}/bin:$PATH"

    if [[ -f requirements.txt ]]; then
        pip install --no-index --find-links="./packages/" -r requirements.txt
    else
        pip install --no-index --find-links="./packages/" $DEFAULT_PKGS
    fi

}

##########################
#GLOBAL VARIABLES
##########################
FORCE=false
REQUIREMENTS_FILE=None
PREFIX="${HOME}/miniconda"
DEFAULT_PKGS="ansible awscli docker molecule fabric patchwork robotframework robotframework-requests robotframework-sudslibrary"

main "${@}"
