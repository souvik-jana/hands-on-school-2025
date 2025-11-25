#!/usr/bin/bash

set -ex

PWD=$(pwd)

echo "Creating the Conda environment"
conda create -n gw-school-2025 -c conda-forge python=3.11 numpy matplotlib astropy lalsimulation lalinspiral h5py pesummary 
conda activate gw-school-2025

echo "Downloading skymap data"
cd ./lvk_skyloc_samples
if wget -v > /dev/null 2>&1
then
    wget https://zenodo.org/records/5546663/files/skymaps.tar.gz
    tar -xvzf skymaps.tar.gz
else
    echo I will do something with cURL
fi
