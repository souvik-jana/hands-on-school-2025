#!/usr/bin/env python3
__author__ = 'Samson Leong'
__date__ = '2025/11/26'
__email__ = 'samson.leong@ligo.org'

from pathlib import Path
from h5py import File

import argparse

parser = argparse.ArgumentParser(description='Extract sky location sapmles from GWTC catalogue posteriors.')
parser.add_argument('--catalogue', type=str, default='All',
                    help='The catalogue to look at.')
parser.add_argument('--cosmo', action='store_true', default=False,
                    help='Whether samples are reweighted by cosmological prior.')

root_dir = Path('/home/cbc/CatalogDraftReleases')
gwtc2p1_path = root_dir / 'gwtc2p1/6513631_4/parameter_estimation'
gwtc3p0_path = root_dir / 'gwtc3/8177023_4/parameter_estimation'
# Release-7 corresponds to Zenodo v2
gwtc4p0_path = root_dir / 'gwtc4/GWTC4-Stable_Release-7/parameter_estimation'

all_desired_keys = {'ra','dec','redshift','luminosity_distance','comoving_distance','network_optimal_snr'}

def loop_and_extract(file_generator, output_filename):
    output_file = File(output_filename, "w")
    for path in file_generator:
        print(path.name)
        with File(path, 'r') as hf:
            for key in hf.keys():
                if ('C01' not in key) and ('C00' not in key):
                    continue
                print(f"  {key}")
                if 'GWTC4' in path.name:
                    event_name = path.name.split('-')[3]
                else:
                    event_name = path.name.split('_PEDataRelease')[0].split('-')[-1]
                samples = hf[f'{key}/posterior_samples']
                int_keys = all_desired_keys.intersection(samples.dtype.names)
                print(int_keys)
                subset = samples[*int_keys]
                print(subset.shape)
                grp = output_file.create_group(f'{event_name}/{key}')
                grp.create_dataset('skyloc_samples', data=subset)
    output_file.close()

scenario_dict = {
    ('GWTC2.1', True): (
        gwtc2p1_path.glob("*_cosmo.h5"),
        "GWTC2p1_cosmo_skyloc_samples.h5"
    ),
    ('GWTC2.1', False): (
        gwtc2p1_path.glob("*_nocosmo.h5"),
        "GWTC2p1_nocosmo_skyloc_samples.h5"
    ),
    ('GWTC3.0', True): (
        gwtc3p0_path.glob("*_cosmo.h5"),
        "GWTC3p0_cosmo_skyloc_samples.h5"
    ),
    ('GWTC3.0', False): (
        gwtc3p0_path.glob("*_nocosmo.h5"),
        "GWTC3p0_nocosmo_skyloc_samples.h5"
    ),
    ('GWTC4.0', False): (
        gwtc4p0_path.glob("*.hdf5"),
        "GWTC4p0_skyloc_samples.h5"
    )
}

if __name__ == '__main__':
    args = parser.parse_args()
    catalog = args.catalogue
    reweight = args.cosmo
    ALL = args.catalogue == 'All'

    if ALL:
        for (catalogue, cosmo), arg_pair in scenario_dict.items():
            wo = 'with' if cosmo else 'without'
            print(f"Processing {catalogue} {wo} cosmological reweighted prior...")
            loop_and_extract(*arg_pair)

    else:
        key = (catalog, reweight)
        if key not in scenario_dict:
            raise ValueError(f"Invalid combination of catalogue {catalog} and cosmological reweighting {reweight}.")
        wo = 'with' if reweight else 'without'
        print(f"Processing {catalog} {wo} cosmological reweighted prior...")
        loop_and_extract(*scenario_dict[key])
