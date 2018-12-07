Automatron
==============

[![Build Status](https://travis-ci.com/knightdave/automatron.svg?branch=master)](https://travis-ci.com/knightdave/automatron)

Package python Conda with automation libraries.
- ansible
- docker
- awscli
- fabric
- robotframework
- molecule

Usage
------
Create portable python installer with automation tools in tree simple steps:

1. Create package:
    ```sh
    ./create_package.sh
    ```
2. Copy automatron.sh to any place and run installation:
    ```sh
    ./automatron.sh
    ```
3. Add new installed python to **PATH**
    ```sh
    export PATH="$HOME/miniconda/bin:$PATH"
    ```
