#!/bin/bash

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
    [[ -d ./miniconda ]] && rm -rf miniconda
    [[ -d ./makeself ]] && rm -rf makeself
    [[ -d ./automatr ]] && rm -rf automatr
    [[ -f ./automatron.sh ]] && rm -f automatron.sh
    [[ -d $PREFIX ]] && rm -rf $PREFIX
}

function upgrade_pip(){
    pip install --upgrade pip
}

#--------- Test Cases ---------#

function create_package_auto(){
    print_testcase ${FUNCNAME[0]}
    print_info "Creating package..."
    ./create_package.sh
    print_info "Checking is created..."
    [[ -f automatron.sh ]] && testcase_success ${FUNCNAME[0]} || testcase_fail ${FUNCNAME[0]}
}

function install_package_auto(){
    print_testcase ${FUNCNAME[0]}
    sh automatron.sh
    [[ -d ~/miniconda ]] || testcase_fail ${FUNCNAME[0]}
    export PATH="${HOME}/miniconda/bin:$PATH"
    python -c "import ansible" || testcase_fail ${FUNCNAME[0]}
    testcase_success ${FUNCNAME[0]} 
}


function main(){
    cleanup
    print_environment
    pip install virtualenv
    virtualenv virtenv
    source virtenv/bin/activate
    upgrade_pip
    create_package_auto
    install_package_auto
    cleanup
}

PREFIX=$(pwd)/testprefix/somelocation

main