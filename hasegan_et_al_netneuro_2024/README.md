# demapper repository

This code is the associated analysis done within the paper:

```bibtex
@article{hasegan2024demapper,
  title={Deconstructing the Mapper algorithm to extract richer topological and temporal features from functional neuroimaging data},
  author={Hasegan, Daniel and Geniesse, Caleb and Chowdhury, Samir and Saggar, Manish},
  journal={Network Neuroscience},
  year={2024},
}
```

## install

This repository runs code in MATLAB and Python. Make sure you have those installed and at a newer version (Python >= 3.9).

Once you downloaded the repository, install the required python packages

    pip install -r requirements.txt

By running the following snippet in the terminal, create a file in this folder named: `.env` with the following environmental parameters:

    # Make sure you are in the correct folder:
    cd hasegan_et_al_netneuro_2024/

    echo "WORKSPACE=`pwd`\nDEMAPPER=$(dirname "`pwd`")" > .env

## data

The synthetic (w3c) dataset is included in the repository at the following path:

    data/w3c/

**Downloading the real (cme) datasets**

As similar as for w3c, for the real dataset, we need 3 file types:

1. The preprocessed data in either `.mat` or `.npy` format. This will be a file for each subject. For example: `data/cme/SBJ02_Shine_375.npy`

2. The `cohort.csv` file describing the dataset properties. 
An example file is as follows:

        id0,id1,id2,path,TR
        SBJ01,,,SBJ01_Shine_375.npy,1.5
        SBJ02,,,SBJ02_Shine_375.npy,1.5
        ...
    
3. The task info file, which is a `.csv` file with the following format: it needs a column `task_name` that describes the task for each time point in the input dataset. In the cme real dataset, this file will need 1017 rows and 1 column. The value for each row will be the task name: `instruction`, `rest`, `memory`, `math`, or `video`. Additionally, you could have the columns: `run_name`, `task`, which describe the run number (always 1) or the task id code (1 to 5). 
Example file: 

        run_name,task,task_name
        1,1,instruction
        1,2,rest
        1,2,rest
        1,2,rest
        ...
