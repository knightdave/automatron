#!/bin/bash

[[ ! -d ./automatron ]] && mkdir automatron
[[ ! -d ./automatron/packages ]] && mkdir automatron
wget -O ./automatron/Miniconda.sh https://repo.anaconda.com/miniconda/Miniconda2-latest-Linux-x86_64.sh
pip download -d ./automatron/packages -r requirements.txt

cat << EOF >> ./automatron/install.sh
#!/bin/bash

bash Miniconda.sh -b -p $HOME/miniconda
pip install --no-index --find-links="./packages/" ansible

echo "Remmember to set PATH"
EOF

[[ ! -d ./makeself ]] && git clone https://github.com/megastep/makeself.git
./makeself/makeself.sh automatron automatron.sh "Conda distribution with automation tools" ./install.sh
rm -rf ./automatron
