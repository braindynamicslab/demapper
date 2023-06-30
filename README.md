# demapper repository

This is the associated repository of the paper:

    TODO

## install

This repository runs code in MATLAB and Python. Make sure you have those installed and at a newer version (Python >= 3.9). 

Once you downloaded the repository, install the required python packages

    pip install -r requirements.txt

Make sure you download and install the MapperToolbox from https://github.com/braindynamicslab/mappertoolbox-matlab

Create a file in this folder named: `.env` with the following environmental parameters:

    echo "WORKSPACE=`pwd`\nMAPPERTOOLBOX=<CHANGE_THIS_TO_PATH_TO_MAPPERTOOLBOX>" > .env

## data

Downloading the synthetic (w3c) and real (cme) datasets.
