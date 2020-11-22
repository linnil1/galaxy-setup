#!/usr/bin/env bash
set -euo pipefail

# Basic
sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential python3-dev

# folder
# sudo apt install -y zfsutils-linux
# sudo zpool create datahdd /dev/sdb
sudo mkdir -p /data
sudo mkdir -p /datahdd
sudo chown $USER:$(id -u) /data
sudo chown $USER:$(id -g) /datahdd

# change timezone
sudo ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime
sudo dpkg-reconfigure -f noninteractive tzdata

# install cvmfs
wget https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest_all.deb
sudo dpkg -i cvmfs-release-latest_all.deb
rm -f cvmfs-release-latest_all.deb
sudo apt-get update
sudo apt-get install -y cvmfs

# conda env
GALAXY_CONDA_PREFIX=/data/conda
curl -s -L "https://repo.anaconda.com/miniconda/Miniconda2-latest-Linux-x86_64.sh" > ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p $GALAXY_CONDA_PREFIX && \
    export PATH=$GALAXY_CONDA_PREFIX/bin/:$PATH && \
    echo "export PATH=$PATH" >> ~/.bashrc && \
    echo ". $GALAXY_CONDA_PREFIX/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda install -y virtualenv pip ephemeris && \
    rm miniconda.sh

# certification
# mkdir certs
# openssl genrsa 4096 > certs/privkey.pem
# chmod 400 certs/privkey.pem
# openssl req -new -x509 -nodes -sha1 -days 365 -key certs/privkey.pem -out certs/fullchain.pem

# clone galaxy
git clone -b release_20.05 https://github.com/galaxyproject/galaxy.git
cp galaxy.yml galaxy/config/
cp shed_tool_conf.xml galaxy/config/
cp job_conf.xml galaxy/config/
cp galaxy/config/tool_data_table_conf.xml.sample galaxy/config/tool_data_table_conf.xml

# git clone https://github.com/bgruening/docker-galaxy-stable.git
# j2 --undefined --customize docker-galaxy-stable/compose/galaxy-configurator/customize.py docker-galaxy-stable/compose/galaxy-configurator/templates/nginx/nginx.conf.j2 -o export/nginx.conf
# cp docker-galaxy-stable/compose/docker-compose.yml .

# docker compose
sudo apt install -y docker.io
conda install -y docker-compose
sudo usermod -aG docker $USER

# ftp
sudo docker build -t linnil1/proftpd . -f Docker_proftpd

# cvmfs
sudo cp cvmfs/default.local /etc/cvmfs/default.local
sudo cp cvmfs/cvmfs-config.galaxyproject.org.conf /etc/cvmfs/config.d/cvmfs-config.galaxyproject.org.conf
sudo cp cvmfs/80-galaxyproject-cvmfs.conf /etc/cvmfs/default.d/80-galaxyproject-cvmfs.conf
sudo mkdir -p /etc/cvmfs/keys/galaxyproject.org/
sudo cp cvmfs/cvmfs-config.galaxyproject.org.pub /etc/cvmfs/keys/galaxyproject.org/cvmfs-config.galaxyproject.org.pub
sudo systemctl restart autofs
sudo cvmfs_config setup

# remove
# sudo rm -fr galaxy/.venv /data/* /datahdd/*
# conda env remove -n _galaxy_
