Automatron
==============

[![Build Status](https://travis-ci.com/knightdave/automatron.svg?branch=master)](https://travis-ci.com/knightdave/automatron)

Easy way to create automation ready Python installer with [miniconda][conda] and [makeself][makeself].
- [ansible][ansible]
- [docker][docker]
- [awscli][awscli]
- [fabric][fabric]
- [robotframework][robotframework]
- [molecule][molecule]

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

### Parameters

The syntacs of automatron is following  

`./create_package.sh [args]`
- args are optional:
    - `-t` : temporary dir (default is current dir)
    - `-r` : path to requirements.txt file
    - `-k` : keep files for future (default if to not keep)
    - `-p` : force use python version (2 or 3)

`./automatron.sh [args]`
- args are optional:
    - `-f` : force installation
    - `-p` : installation path (default: ~/miniconda)


[conda]: https://conda.io/miniconda.html
[makeself]: https://makeself.io
[ansible]: https://github.com/ansible/ansible
[docker]: https://github.com/docker/docker-py
[awscli]: https://github.com/aws/aws-cli
[fabric]: https://github.com/fabric/fabric
[robotframework]: https://github.com/robotframework/robotframework
[molecule]: https://github.com/ansible/molecule