#!/usr/bin/bash

# Stop execution as soon as any error is raised.
set -e

REPO_DIR=$(pwd)

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
  -p,
        Download all posterior samples from all catalogues as well, highly not recommended.
  -c,
        Clean all previous attempts, including Conda environment and downloaded data.
EOF
)

# The following getopt example obtained from:
# https://stackoverflow.com/a/14203146
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

TEST=false
VERBOSE=false
CONDA_FLAGS=""
INC_GWTC4=false
POSTERIOR=false
CLEAN=false
OPT_MSG=""

# Parsing user options
while getopts "tvapch" opt; do
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
    p)
        POSTERIOR=true
        OPT_MSG+=$'     -p: Download all posterior samples from Zenodo as well\n'
        OPT_MSG+=$'         (Highly not recommended!)\n'
        ;;
    c)
        CLEAN=true
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
if ${CLEAN}
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

# Check whether git-lfs has been installed
if git lfs version > /dev/null 2>&1
then
    echo "    You have installed git-lfs:"
    echo "    -> $(git lfs version)"
else
    echo "    git-lfs has not been installed yet!"
    echo "    Please consider install it here: https://git-lfs.com"
fi

sleep 1

# Step 1. Create the Conda environment
echo "Creating the Conda environment"
# First source conda to initialise it
source $(conda info --base)/etc/profile.d/conda.sh
conda create -n gw-school-2025 -c conda-forge --solver=libmamba --yes ${CONDA_FLAGS} python=3.11 \
    "numpy<=1.24" matplotlib ipython h5py zenodo_get astropy \
    lalsimulation lalinspiral pycbc ligo.skymap "pesummary>=1.3.2"
conda activate gw-school-2025

# Step 2. Download LIGO skymaps
GWTC2p1_Zenodo="https://zenodo.org/records/6513631"
GWTC3p0_Zenodo="https://zenodo.org/records/8177023"
GWTC4p0_Zenodo="https://zenodo.org/records/17014085"
skymaps_GWTC2p1="${GWTC2p1_Zenodo}/files/IGWN-GWTC2p1-v2-PESkyMaps.tar.gz"
skymaps_GWTC3p0="${GWTC3p0_Zenodo}/files/IGWN-GWTC3p0-v2-PESkyLocalizations.tar.gz"
skymaps_GWTC4p0="${GWTC4p0_Zenodo}/files/IGWN-GWTC4p0-0f954158d_720-Archived_Skymaps.tar.gz"
GWTC2p1_file="GWTC2p1_skymaps.tar.gz"
GWTC4p0_file="GWTC4p0_skymaps.tar.gz"
GWTC3p0_file="GWTC3p0_skymaps.tar.gz"

command -v wget > /dev/null 2>&1
HAS_WGET=$?
command -v curl > /dev/null 2>&1
HAS_CURL=$?

echo "Downloading skymap data"
cd ${REPO_DIR}/LVK_skyloc_samples
if [ ${HAS_WGET} = 0 ]
then
    download="wget ${WGET_FLAGS} -O"
elif [ ${HAS_CURL} = 0 ] && ! ${TEST}
then
    echo "wget not found, will try to use cURL instead."
    download="curl -o"
else
    echo "Neither wget nor cURL is found. Exiting..."
    exit 1
fi

eval "${download} ${GWTC2p1_file} ${skymaps_GWTC2p1} &"
pid1=$!
sleep 1
eval "${download} ${GWTC3p0_file} ${skymaps_GWTC3p0} &"
pid2=$!
sleep 1
if ${INC_GWTC4}
then
    eval "${download} ${GWTC4p0_file} ${skymaps_GWTC4p0} &"
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
    mv GWTC3p0_skymaps/IGWN-GWTC3p0-v2-PESkyLocalizations/* GWTC3p0_skymaps
    rmdir GWTC3p0_skymaps/IGWN-GWTC3p0-v2-PESkyLocalizations/

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
    cd ${REPO_DIR}
fi

if ${POSTERIOR} && ! ${TEST}
then
    cd ${REPO_DIR}/LVK_PE_samples
    echo "Downloading posterior samples of all catalogues from Zenodo."

    # GWTC2.1
    mkdir GWTC2p1_samples && cd GWTC2p1_samples
    zenodo_get ${GWTC2p1_Zenodo} -g "*_cosmo.h5" &
    pid1=$!
    cd ..

    # GWTC3.0
    mkdir GWTC3p0_samples && cd GWTC3p0_samples
    zenodo_get ${GWTC3p0_Zenodo} -g "*_cosmo.h5" &
    pid2=$!
    cd ..

    if ${INC_GWTC4}
    then
        # GWTC4.0
        mkdir GWTC4p0_samples && cd GWTC4p0_samples
        zenodo_get ${GWTC4p0_Zenodo} -g "*.hdf5" &
        pid3=$!
        cd ..
        wait $pid3
    fi
    wait $pid1 $pid2
fi

echo "All done, leaving..."
cd ${REPO_DIR}
exit 0
