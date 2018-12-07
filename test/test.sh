#!/bin/bash

function print_info(){
	echo "[$(date)] [INFO] ${@}"
}

function print_error(){
	echo "[$(date)] [ERROR] ${@}"
	exit 1
}

function print_testcase(){
    echo ""
    echo "#################### TEST CASE ${@} ####################"
    echo ""
}


#--------- Test Cases ---------#

function create_package_auto(){
    print_testcase ${0}
    print_info "Creating package..."
    ./create_package.sh
    print_info "Checking is created..."
    [[ -f automatron.sh ]] || print_error "Package not created"
}

fuction install_package_auto(){
    print_testcase ${0}
    ./automatron.sh
    [[ -d ~/miniconda ]] || print_error "miniconda not installed"
    export PATH="${HOME}/miniconda/bin:$PATH"
    python -c "import ansible" || print_error "ansible package not installed"
}



function main(){
    create_package_auto
    install_package_auto
}

main