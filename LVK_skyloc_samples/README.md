# GW sources sky localisations

In this directory, there are two types of files.

* The congregated `*skyloc_samples.h5`
  * These are sky location posterior samples extracted from the posterior files of each event, in GWTC2.1, GWTC3.0, and GWTC4.0.
  * These files are stored via `git-lfs`, they will only be downloaded after invoking `git lfs pull`, otherwise they will simply be file linkers.
* The `GWTC*_skymaps` FITS files
  * There should be 2/3 of these folders here after the [setup](../README.md#Instructions).
  * These are the processed FITS files from each catalogue releases.

The LVK GW catalogues public posterior samples:
* GWTC2.1: https://zenodo.org/records/6513631
* GWTC3.0: https://zenodo.org/records/8177023
* GWTC4.0: https://zenodo.org/records/17014085

## Structure of the sky location sample files
These are `hdf5` files, each of them has the following group structure:
```
<EVENT_NAME>/<WAVEFORM_MODEL>
```
each of them has one dataset named `skyloc_samples`, with the following keys:
```
'ra', 'dec', 'redshift', 'luminosity_distance', 'comoving_distance', 'network_optimal_snr'
```
*Note: the `network_optimal_snr` column may not be always present.*

An example snippet code to access the file content is as follows:
```python
from h5py import File

with File('GWTC2p1_cosmo_skyloc_samples.h5', 'r') as hf:
    print(hf.keys())
    samples = hf['GW150914_095045/C01:Mixed/posterior_samples'][:]
print(samples.shape, samples.dtype.names)
```
