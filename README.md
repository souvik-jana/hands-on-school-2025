# GW Hands-On School 2025

## Getting Started

To obtain this repository on your laptop, simply do 
```bash
git clone git@git.ligo.org:pauljl.martens/hands-on-school-2025.git
# or
git clone https://git.ligo.org/pauljl.martens/hands-on-school-2025.git
```
then everything should be in:
```bash
cd hands-on-school-2025.git
```

### Git-LFS
This repository contains some large binary files, which are stored using `git-lfs`. 

#### Setting up Git-LFS
> *For those who have git-lfs installed and setup, feel free to skip this*

If you have not installed `git-lfs`, please install it from here: [git-lfs.com](https://git-lfs.com).

After which, one may need to set it up by running `git lfs install`.

#### Downloading the large files
To obtain all the files stored in [`lvk_skymaps_samples`](./lvk_skymaps_samples), please do the following:
```bash
git lfs pull
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

These options can be used in conjunction, *e.g.*
```
./env_setup.sh -tv
```
this will be running in both test and verbose modes.

In addition, there are two other special modes:
* `-h`, simply display the help message with the list of options and exits.
* `-c`, this will clean up all previous attempts, including Conda environment and downloaded data. This is useful for a fresh start.

## Fork and GitHub
If you would like to work and collaborate on your own fork, here are two approaches:
1. Simply fork this GitLab repository, and clone the fork to your local machine instead.

2. If GitHub is easier to work with, one may first clone this repository first.
  * Then create a blank repository on GitHub, and obtain the URL to it.
  * Inside the local git repository, run the following:
    ```bash
    git remote add github <YOUR-GITHUB-REPO-URL>
    git push -u github main
    ```
  * Then a copy of this repository will be hosting in your own GitHub account.

***

## Authors 
Paul Martens, Laura Uronen, Charmaine Wong, Samson Leong

## License
Think about this.
