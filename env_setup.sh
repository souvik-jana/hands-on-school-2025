#!/usr/bin/bash

# Stop execution as soon as any error is raised.
set -e

PWD=$(pwd)

# The following getopt example obtained from:
# https://stackoverflow.com/a/14203146
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Parsing user options
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

# Step 1. Create the Conda environment
echo "Creating the Conda environment"
# conda create -n gw-school-2025 -c conda-forge --solver=libmamba ${CONDA_FLAGS} python=3.11 numpy matplotlib astropy lalsimulation lalinspiral h5py pesummary 
# conda activate gw-school-2025

# Step 2. Download LIGO skymaps
GWTC2p1_file="GWTC2p1_skymaps.tar.gz"
skymaps_GWTC2p1="https://zenodo.org/records/6513631/files/IGWN-GWTC2p1-v2-PESkyMaps.tar.gz"
GWTC3p0_file="GWTC3p0_skymaps.tar.gz"
skymaps_GWTC3p0="https://zenodo.org/records/5546663/files/skymaps.tar.gz"
GWTC4p0_file="GWTC4p0_skymaps.tar.gz"
skymaps_GWTC4p0="https://zenodo.org/records/16053484/files/IGWN-GWTC4p0-0f954158d_720-Archived_Skymaps.tar.gz"

echo "Downloading skymap data"
cd ./lvk_skyloc_samples
which wget
if command -v wget > /dev/null 2>&1
then
    mkdir -p GWTC2p1_skymaps
    wget -O ${GWTC2p1_file} ${skymaps_GWTC2p1}
    tar -xvzf ${GWTC2p1_file} -C GWTC2p1_skymaps
    mkdir -p GWTC3p0_skymaps
    wget -O ${GWTC3p0_file} ${skymaps_GWTC3p0}
    tar -xvzf ${GWTC3p0_file} -C GWTC3p0_skymaps
    mkdir -p GWTC4p0_skymaps
    wget -O ${GWTC4p0_file} ${skymaps_GWTC4p0}
    tar -xvzf ${GWTC4p0_file} -C GWTC4p0_skymaps
else
    echo "wget not found, try using cURL instead."
fi
