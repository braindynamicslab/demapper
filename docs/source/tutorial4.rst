Tutorial 4: Analyze Mapper parameters
======================================

Now that you are an expert with the DeMapper toolbox, you can now analyze the Mapper algorithm itself by testing all the parameter combinations and see how they affect the output. 

You can follow the analysis done in the paper *"Deconstructing the Mapper algorithm to extract richer topological and temporal features from functional neuroimaging data"* by Hasegan et al., 2024.

If you went through the previous tutorials, you should easily understand the different file types and scripts used to generate the figures in the paper.

The simulated dataset
---------------------

For the simulated dataset used in the paper, you can see the data at the folder: `hasegan_et_al_netneuro_2024/data/w3c`. The cohort file is at the `hasegan_et_al_netneuro_2024/data/w3c/cohort.csv` path and is defined as follows:

.. literalinclude:: ../../hasegan_et_al_netneuro_2024/data/w3c/cohort.csv

All the Mapper configuration files are presented at: `hasegan_et_al_netneuro_2024/code/configs`.

The script to run the Mapper configuration files on the cohort dataset is presented at the `hasegan_et_al_netneuro_2024/code/utils/run_mapper.sh` path.

A step-by-step guide for each figure is provided as follows:

- **Figure 3**: This figure shows the effect of the **distance type** on the Mapper output. To generate this figure, you need to follow the python notebook `Figure dists simulated-dataset.ipynb <https://github.com/braindynamicslab/demapper/blob/master/hasegan_et_al_netneuro_2024/notebooks/Figure%20dists%20simulated-dataset.ipynb>`_. 

- **Figure 5**: This figure shows the effect of the **filtering functions** on the Mapper output. To generate this figure, you need to follow the python notebook `Figure embeddings simulated-dataset.ipynb <https://github.com/braindynamicslab/demapper/blob/master/hasegan_et_al_netneuro_2024/notebooks/Figure%20embeddings%20simulated-dataset.ipynb>`_. 

- **Figure 6**: This figure shows the effect of the **binning parameters** on the Mapper output. To generate this figure, you need to follow the python notebook `Figure binning simulated-dataset.ipynb <https://github.com/braindynamicslab/demapper/blob/master/hasegan_et_al_netneuro_2024/notebooks/Figure%20binning%20simulated-dataset.ipynb>`_. 

- **Figure 8**: This figure shows the effect of the **clustering algorithm** on the Mapper output. To generate this figure, you need to follow the python notebook `Figure clustering simulated-dataset.ipynb <https://github.com/braindynamicslab/demapper/blob/master/hasegan_et_al_netneuro_2024/notebooks/Figure%20clustering%20simulated-dataset.ipynb>`_. 