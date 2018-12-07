#!/bin/bash


function print_error(){
	echo "[$(date)] [ERROR] ${@}"
	exit 1
}

function usage() {
	echo "-t	temporary dir (default current dir)"
	echo "-r	path to requirements.txt file"
	echo "-k	keep files for future (default not keep)"
	exit 1
}

function process_parameters() {
	while getopts r:t:k: Option
	do
		case "${Option}" in
			r) REQUIREMENTS_FILE="${OPTARG}"
			;;
			t) TMPDIR="${OPTARG}"
			;;
			k) KEEP=true
			;;
			*) usage
			;;
		esac
	done

  return 0
}

function check_pip_version() {
	PIP_VERSION=$(pip --version | awk -F'[" ".]' '{print $2}')
	if [[ $PIP_VERSION -lt $MIN_PIP_VERSION ]]; then
		print_error "Your pip version is lower then minimal $MIN_PIP_VERSION. Please upgrade pip."
	fi
}

function check_python_version() {
	PYTHON_VERSION=$(python --version 2>&1 | awk -F'[" ".]' '{print $2}')
	if [[ $PYTHON_VERSION = 2 ]]; then
		DOWNLOAD=$MINICONDA2
	elif [[ $PYTHON_VERSION = 3 ]]; then
		DOWNLOAD=$MINICONDA3
	else
		print_error "Cannot check python version. Check is python exists in your PATH"
	fi
}

function prepare_environment() {

    [[ ! -d "${TMPDIR}"/automatr ]] && mkdir "${TMPDIR}"/automatr
    [[ ! -d "${TMPDIR}"/automatr/packages ]] && mkdir "${TMPDIR}"/automatr/packages
    wget -O "${TMPDIR}"/automatr/Miniconda.sh $DOWNLOAD

    if [[ ! -d "${TMPDIR}"/makeself ]]; then
        git clone https://github.com/megastep/makeself.git "${TMPDIR}"/makeself
    else
        cd "${TMPDIR}"/makeself
        git init
        git remote add origin https://github.com/megastep/makeself.git 2>/dev/null
        git pull
    fi

}

function cleanup() {
    rm -rf "${TMPDIR}"/automatr
    rm -rf "${TMPDIR}"/makeself
}

function main() {
	process_parameters "${@}"
	check_pip_version
	check_python_version
	prepare_environment

	if [[ "${REQUIREMENTS_FILE}x" = "x" ]]; then
		pip download -d "${TMPDIR}"/automatr/packages $DEFAULT_PKGS
	else
		pip download -d "${TMPDIR}"/automatr/packages -r ${REQUIREMENTS_FILE}
	fi
	cp ${DIRECTORY}/.install.sh "${TMPDIR}"/automatr/install.sh


	"${TMPDIR}"/makeself/makeself.sh "${TMPDIR}"/automatr automatron.sh "Conda distribution with automation tools" ./install.sh

	[[ ! ${KEEP} = true ]] && cleanup
}


##########################
#GLOBAL VARIABLES
##########################
DIRECTORY=$(dirname $0)
PYTHON_VERSION=2
REQUIREMENTS_FILE=""
MINICONDA2="https://repo.anaconda.com/miniconda/Miniconda2-latest-Linux-x86_64.sh"
MINICONDA3="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
DOWNLOAD="${MINICONDA2}"
TMPDIR=$(pwd)
KEEP=false
MIN_PIP_VERSION=10
DEFAULT_PKGS="ansible awscli docker molecule fabric patchwork robotframework robotframework-requests robotframework-sudslibrary"



main "${@}"