# GW Hands-On School 2025

## How to work with this repository

Every group should have a person to fork this main repository.
Then work on it as a group.

If fork does not work, try to first clone it and push it to GitHub.
```bash
git clone git@git.ligo.org:pauljl.martens/hands-on-school-2025.git
cd hands-on-school-2025.git
git remote add github <YOUR-GITHUB-REPO-URL>
git push -u github main
```

## Instructions
What is inside, how to work with them, etc

1. Please run the environment setup file:
```bash
bash env_setup.sh
# or
./env_setup.sh
```

The setup script has the following options:
* `-t`, test mode, perform a dry run without installing/downloading anything.
* `-v`, verbose mode, run while printing every command being executing.
* `-a`, include skymaps from GWTC4.0 in downloads, which will take up an extra 250+MB of storage. By default, only skymaps from GWTC2.1 and GWTC3.0 will be downloaded.
They can be used in conjunction, <it>e.g.</it>
```
./env_setup.sh -av
```

In addition, there are two other special modes:
* `-h`, simply display the help message with the list of options and exits.
* `-c`, this will clean up all previous attempts, including Conda environment and downloaded data. This is useful for a fresh start.

***


## Authors 
Paul Martens, Laura Uronen, Charmaine Wong, Samson Leong

## License
Think about this.
