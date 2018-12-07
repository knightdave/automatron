#!/bin/bash
. ../create_package.sh

function print_info(){
	echo "[$(date)] [INFO] ${@}"
}

function print_testcase(){
    echo ""
    echo "#################### TEST CASE ${@} ####################"
    echo ""
}

function testcase_fail(){
	echo "TEST CASE ${@} FAILURE"
	exit 1
}

function testcase_success(){
    echo "TEST CASE ${@} SUCCESS"
}

function print_environment(){
    print_info $(uname -a)
	print_info $(python --version)
    print_info $(pip --version)
}

function cleanup() {
    print_info "Cleaning environment"
    [[ -d ../miniconda ]] && rm -rf miniconda
    [[ -d ../makeself ]] && rm -rf makeself
    [[ -d ../automatr ]] && rm -rf automatr
    [[ -f ../automatron.sh ]] && rm -f automatron.sh
    [[ -d $PREFIX ]] && rm -rf $PREFIX
}

function upgrade_pip(){
    pip install --upgrade pip
}

#--------- Test Cases ---------#

function pip_checking_too_low(){
    print_testcase ${0}
    check_pip_version || testcase_success ${0}
}

function pip_checking_enough(){
    print_testcase ${0}
    check_pip_version && testcase_success ${0}
}

function create_package_auto(){
    print_testcase ${0}
    print_info "Creating package..."
    ./create_package.sh
    print_info "Checking is created..."
    [[ -f automatron.sh ]] && testcase_success ${0} || testcase_fail ${0}
}

function install_package_auto(){
    print_testcase ${0}
    ./automatron.sh
    [[ -d ~/miniconda ]] || testcase_fail ${0}
    export PATH="${HOME}/miniconda/bin:$PATH"
    python -c "import ansible" || testcase_fail ${0}
    testcase_success ${0} 
}


function main(){
    cleanup
    print_environment
    pip_checking_too_low
    upgrade_pip
    pip_checking_enough
    create_package_auto
    install_package_auto
    cleanup
}

PREFIX=$(pwd)/testprefix/somelocation

main