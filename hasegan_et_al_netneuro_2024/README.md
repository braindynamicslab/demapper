# demapper repository

This is the associated repository of the paper:

    TODO

## install

This repository runs code in MATLAB and Python. Make sure you have those installed and at a newer version (Python >= 3.9). 

Once you downloaded the repository, install the required python packages

    pip install -r requirements.txt

Make sure you download and install the DeMapper from https://github.com/braindynamicslab/demapper

Create a file in this folder named: `.env` with the following environmental parameters:

    echo "WORKSPACE=`pwd`\nDEMAPPER=<CHANGE_THIS_TO_PATH_TO_DEMAPPER>" > .env

## data

Downloading the synthetic (w3c) and real (cme) datasets.
