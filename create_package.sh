#!/bin/bash
#
# create_package.sh
#  by Dawid Rycerz <kontakt@dawidrycerz.pl>
#
# Utility to create python Conda distribution with automation modules.
# The resulting archive is a auto decompressing archive wit
# minicoda bundled and python automation modules that can be
# easly installed and used without root access.

function print_error(){
	echo "[$(date)] [ERROR] ${@}"
	exit 1
}

function usage() {
	echo "./create_package.sh [args]"
	echo "-t	temporary dir (default current dir)"
	echo "-r	path to requirements.txt file"
	echo "-k	keep files for future (default not keep)"
	echo "-p    force use python version (2 or 3)"
	exit 1
}

function process_parameters() {
	while getopts r:t:k:p: Option
	do
		case "${Option}" in
			r) REQUIREMENTS_FILE="${OPTARG}"
			;;
			t) TMPDIR="${OPTARG}"
			;;
			k) KEEP=true
			;;
			p) PYTHON_VERSION="${OPTARG}"
			;;
			*) usage
			;;
		esac
	done

  return 0
}

function check_python_version() {
	if [[ $PYTHON_VERSION = 2 ]]; then
		DOWNLOAD=$MINICONDA2
	elif [[ $PYTHON_VERSION = 3 ]]; then
		DOWNLOAD=$MINICONDA3
	else
		print_error "Cannot check python version. Check is python exists in your PATH"
	fi
}

function my_pip() {
	if [[ ${PYTHON_VERSION} = 2 ]]; then
		python -m pip "${@}"
	elif [[ ${PYTHON_VERSION} = 3 ]]; then
		python3 -m pip "${@}"
	else
		print_error "Wrong Python version: $PYTHON_VERSION"
	fi
}

function check_pip_version() {
	PIP_VERSION=$(my_pip --version | awk -F'[" ".]' '{print $2}')
	if [[ ${PIP_VERSION} -lt ${MIN_PIP_VERSION} ]]; then
		print_error "Your pip version is lower then minimal ${MIN_PIP_VERSION}. Please upgrade pip."
	fi
}

function prepare_environment() {
	[[ ! -d "${TMP_PATH}" ]] && mkdir "${TMP_PATH}"
    [[ ! -d "${TMP_PATH}/automatron" ]] && mkdir "${TMP_PATH}/automatron"
    [[ ! -d "${TMP_PATH}/automatron/packages" ]] && mkdir "${TMP_PATH}/automatron/packages"
    wget -O "${TMP_PATH}/automatron/Miniconda.sh" "${DOWNLOAD}"

    if [[ ! -d "${TMP_PATH}/makeself" ]]; then
        git clone https://github.com/megastep/makeself.git "${TMP_PATH}/makeself"
    else
        cd "${TMP_PATH}/makeself"
        git init
        git remote add origin https://github.com/megastep/makeself.git 2>/dev/null
        git pull
		cd "${MAIN_DIRECTORY}"
    fi
	sh "${TMP_PATH}/automatron/Miniconda.sh" -f -b -p "${TMP_PATH}/miniconda"
	export PATH="${TMPDIR}/automatron/miniconda/bin:${PATH}"

}

function cleanup() {
    [[ -d "${TMP_PATH}" ]] && rm -rf "${TMP_PATH}"
}

function main() {
	process_parameters "${@}"
	check_python_version
	prepare_environment
	check_pip_version
	

	if [[ "${REQUIREMENTS_FILE}x" = "x" ]]; then
		my_pip download -d "${TMP_PATH}/automatron/packages" ${DEFAULT_PKGS}
	else
		my_pip download -d "${TMP_PATH}/automatron/packages" -r ${REQUIREMENTS_FILE}
		cp ${REQUIREMENTS_FILE} ${TMP_PATH}/automatron
	fi
	cp "${MAIN_DIRECTORY}/.install.sh" "${TMP_PATH}/automatron/install.sh"


	"${TMP_PATH}/makeself/makeself.sh" "${TMP_PATH}/automatron" automatron.sh "Conda distribution with automation tools" ./install.sh

	[[ ! ${KEEP} = true ]] && cleanup
}


##########################
#GLOBAL VARIABLES
##########################
MAIN_DIRECTORY=$(dirname $0)
PYTHON_VERSION="2"
REQUIREMENTS_FILE=""
MINICONDA2="https://repo.anaconda.com/miniconda/Miniconda2-latest-Linux-x86_64.sh"
MINICONDA3="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
DOWNLOAD="${MINICONDA2}"
TMPDIR=/tmp
TMP_PATH="${TMPDIR}/automatron"

KEEP=false
MIN_PIP_VERSION=10
DEFAULT_PKGS="ansible awscli docker molecule fabric patchwork robotframework robotframework-requests"



main "${@}"