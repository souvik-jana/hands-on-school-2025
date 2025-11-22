#!/usr/bin/bash

set -ex

echo "Creating the Conda environment"
conda create -n gw-school-2025 python=3.11 numpy matplotlib astropy lalsimulation lalinspiral pesummary 
conda activate gw-school-2025

echo "Downloading data"
mkdir data
wget https://zenodo.org/records/5546663/files/skymaps.tar.gz
tar -xvzf skymaps.tar.gz
