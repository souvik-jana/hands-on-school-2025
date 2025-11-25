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
INC_GWTC4=false
RESTART=false

USAGE=$(cat <<EOF
This script will setup the Conda environment for the workshop,
and download the necessary data.

Usage: ${0} [options]

  -h,
        Display this help message.
  -t,
        Test mode, not installing/downloading anything.
  -v,
        Verbose mode, run while printing every command being executing.
  -a,
        Include skymaps from GWTC4.0, which will take up an extra 250+MB of storage.
  -c,
        Clean all previous attempts, including Conda environment and downloaded data.
EOF
)

OPT_MSG=""

# Parsing user options
while getopts "tvach" opt; do
  case "$opt" in
    t)
        TEST=true
        CONDA_FLAGS+="-d "
        WGET_FLAGS+="--spider "
        OPT_MSG+=$'     -t: Running in test mode\n'
        ;;
    v)
        VERBOSE=true
        set -x
        OPT_MSG+=$'     -v: Running in verbose mode\n'
        ;;
    a)
        INC_GWTC4=true
        OPT_MSG+=$'     -a: Downloading all data, including GWTC-4\n'
        ;;
    c)
        RESTART=true
        echo "* Cleaning all previous attempts to restart"
        ;;
    h)
        echo "${USAGE}"
        exit 0
        ;;
    \?)
        echo "* Received an illegal option, exiting..."
        echo -e "* Here are the usages of this script: \n"
        echo "${USAGE}"
        exit 1
        ;;
  esac
done

shift $((OPTIND-1))

# Cleaning mode
if ${RESTART}
then
    echo "Removing last creation and download attempts"
    echo "Will begin in 5s"
    # Buffer time for regret...
    sleep 5
    # Will proceed on removing even if some of them failed
    # Turn on verbose mode regardless
    set +e -x
    echo "Removing Conda environment"
    conda remove --name gw-school-2025 --all

    echo "Removing previously downloaded data"
    cd ./lvk_skyloc_samples
    rm GWTC???_skymaps.tar.gz
    # Here, we remove dir by names in case there are other files with similar names.
    rm -r GWTC2p1_skymaps
    rm -r GWTC3p0_skymaps
    rm -r GWTC4p0_skymaps
    exit 0
fi

if [ -z "${OPT_MSG}" ];
then
    MSG="Running with default settings."
else
    MSG=$(cat <<EOF
Here are your specified options:
${OPT_MSG}
EOF
)
fi

cat <<EOF
##############################################################
###         Welcome to the 2025 GW Hands-On School         ###
##############################################################
    
    This setup may take awhile...
    
    While you are waiting, perhaps you may want to go over 
    the program of the school:
    -> https://gw.phy.cuhk.edu.hk/gw-hands-on-school-2025/

    If you would like to stop at any point, press:
          Ctrl+z 
    to suspend it, then run:
          kill %1
    to kill this job in background.

    ${MSG}

--------------------------------------------------------------
  
EOF
sleep 2

# Step 1. Create the Conda environment
echo "Creating the Conda environment"
conda create -n gw-school-2025 -c conda-forge --solver=libmamba ${CONDA_FLAGS} python=3.11 numpy matplotlib astropy lalsimulation lalinspiral h5py pesummary
conda activate gw-school-2025

# Step 2. Download LIGO skymaps
GWTC2p1_file="GWTC2p1_skymaps.tar.gz"
skymaps_GWTC2p1="https://zenodo.org/records/6513631/files/IGWN-GWTC2p1-v2-PESkyMaps.tar.gz"
GWTC3p0_file="GWTC3p0_skymaps.tar.gz"
skymaps_GWTC3p0="https://zenodo.org/records/5546663/files/skymaps.tar.gz"
GWTC4p0_file="GWTC4p0_skymaps.tar.gz"
skymaps_GWTC4p0="https://zenodo.org/records/16053484/files/IGWN-GWTC4p0-0f954158d_720-Archived_Skymaps.tar.gz"

command -v wget > /dev/null 2>&1
HAS_WGET=$?
command -v curl > /dev/null 2>&1
HAS_CURL=$?

echo "Downloading skymap data"
cd ./lvk_skyloc_samples
if [ ${HAS_WGET} = 0 ]
then
    download="wget ${WGET_FLAGS} -O"
elif ! ${TEST} && [ ${HAS_CURL} = 0 ]
then
    echo "wget not found, will try to use cURL instead."
    download="curl -o"
else
    echo "Neither wget nor cURL is found. Exiting..."
    exit 1
fi

${download} ${GWTC2p1_file} ${skymaps_GWTC2p1} &
pid1=$!
sleep 1
${download} ${GWTC3p0_file} ${skymaps_GWTC3p0} &
pid2=$!
sleep 1
if ${INC_GWTC4}
then
    ${download} ${GWTC4p0_file} ${skymaps_GWTC4p0} &
    pid3=$!
    echo "The PIDs of the downloads are:"
    echo $pid1 $pid2 $pid3
    wait $pid1 $pid2 $pid3
else
    echo "The PIDs of the downloads are:"
    echo $pid1 $pid2
    wait $pid1 $pid2
fi

if ${TEST}
then
    echo "Running in test mode, skip file processing"
else
    echo "Skymap downloads completes, uncompressing them."
    mkdir -p GWTC2p1_skymaps
    tar -xvzf ${GWTC2p1_file} -C GWTC2p1_skymaps
    # No need to relocate files
    mkdir -p GWTC3p0_skymaps
    tar -xvzf ${GWTC3p0_file} -C GWTC3p0_skymaps
    mv GWTC3p0_skymaps/skymaps/* GWTC3p0_skymaps
    rmdir GWTC3p0_skymaps/skymaps/

    if ${INC_GWTC4}
    then
        mkdir -p GWTC4p0_skymaps
        tar -xvzf ${GWTC4p0_file} -C GWTC4p0_skymaps
        mv GWTC4p0_skymaps/parameter_estimation/skymaps/* GWTC4p0_skymaps
        rm -r GWTC4p0_skymaps/parameter_estimation
    fi

    echo "Removing intermediate tar.gz files"
    rm *tar.gz

    echo "The total size of the downloaded data:"
    du -sh --total GWTC*
fi

echo "All done, leaving..."
exit 0
