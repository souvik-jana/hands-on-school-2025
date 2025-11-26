# GW sources sky localisations

In this directory, there are two types of files.

* The congregated `skyloc_samples`
  * These are sky location posterior samples extracted from the posterior files of each event, in GWTC2.1 and GWTC3.
  * These files are stored via `git-lfs`, they will only be downloaded after invoking `git lfs pull`, otherwise they will simply be file linkers.
* The `GWTC*_skymaps` FITS files
  * There should be 2/3 of these folders here after the [setup](../env_setup.sh).
  * These are the processed FITS files from each catalogue releases.

The LVK GW catalogues public posterior samples:
* GWTC2.1: https://zenodo.org/records/6513631
* GWTC3.0: https://zenodo.org/records/5546663
* GWTC4.0: https://zenodo.org/records/16053484
