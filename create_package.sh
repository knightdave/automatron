#!/bin/bash


function usage() {
	echo "-t	temporary dir (default current dir)"
	echo "-r	path to requirements.txt file"
	echo "-k	keep files for future (default not keep)"
	exit 1
}

function process_parameters() {
	[[ ${#@} -eq 0 ]] && usage
	while getopts d:w:l:s:a:h:t:f:u:p:c: Option
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

function prepare_environment() {

    [[ ! -d "${TMPDIR}"/automatron ]] && mkdir "${TMPDIR}"/automatron
    [[ ! -d "${TMPDIR}"/automatron/packages ]] && mkdir "${TMPDIR}"/automatron/packages
    wget -O "${TMPDIR}"/automatron/Miniconda.sh https://repo.anaconda.com/miniconda/Miniconda2-latest-Linux-x86_64.sh

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
    rm -rf "${TMPDIR}"/automatron
    rm -rf "${TMPDIR}"/makeself
}

function main() {

process_parameters "${@}"
prepare_environment

if [[ "${REQUIREMENTS_FILE}x" = "x" ]]; then
    pip download -d "${TMPDIR}"/automatron/packages $DEFAULT_PKGS
else
    pip download -d "${TMPDIR}"/automatron/packages -r ${REQUIREMENTS_FILE}
fi
cp ${DIRECTORY}/.install.sh "${TMPDIR}"/automatron/install.sh


"${TMPDIR}"/makeself/makeself.sh "${TMPDIR}"/automatron automatron.sh "Conda distribution with automation tools" ./install.sh

[[ ! ${KEEP} = true ]] && cleanup

}


##########################
#GLOBAL VARIABLES
##########################
DIRECTORY=$(dirname $0)
REQUIREMENTS_FILE=""
TMPDIR=$(pwd)
KEEP=false
DEFAULT_PKGS="ansible awscli docker molecule fabric invocations patchwork robotframework robotframework-requests robotframework-sudslibrary"



main "${@}"