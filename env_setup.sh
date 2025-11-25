#!/usr/bin/bash

# Stop execution as soon as any error is raised.
set -e

PWD=$(pwd)

# The following getopt example obtained from:
# https://stackoverflow.com/a/14203146
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

TEST=false
VERBOSE=false
CONDA_FLAGS=""

help_msg=$(cat <<EOF
This script will setup the Conda environment for the workshop,
and download the necessary data.

Usage: ${0} [options]

  -h,   
        Display this help message.
  -t,   
        Test mode, not installing/downloading anything.
  -v,   
        Verbose mode, run while printing every command being executing.
EOF
)

while getopts "tvh" opt; do
  case "$opt" in
    t)  
        TEST=true
        CONDA_FLAGS+="-d "
        echo "Running in test mode"
        ;;
    v)  
        verbose=true
        set -x
        ;;
    h)  
        echo "${help_msg}"
        exit 0
        ;;
  esac
done

shift $((OPTIND-1))


echo "Creating the Conda environment"
conda create -n gw-school-2025 -c conda-forge --solver=libmamba ${CONDA_FLAGS} python=3.11 numpy matplotlib astropy lalsimulation lalinspiral h5py pesummary 
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
