Process Mappers in batch
=========================

We always want to run Mapper with multiple configurations and see the final result. 
The tool implemented here is a helper tool to run a batch of Mappers on data. 

These are the main parts of processing one Mapper for one data item (subject):

1. Load data item from a cohort file into a matrix
2. Preprocess the matrix
3. Run a Mapper configuration on our matrix
4. Run all analysis steps

The ``run_main()`` script runs in parallel the steps above for all
data items (subjects) and for all mapper configurations.

====================
Usage Example
====================

Outside of tests and small experiments, the process is run from command line,
where the inputs are set as variables:

.. code-block::
 :caption: Example command line call to run_main 

 matlab -r "cohort_csv='...'; config_path='...'; run('/.../mappertoolbox-matlab/code/analysis/run_main.m'); "

Below, I present a more detailed example with all the required arguments set:

.. code-block::
  :caption: Example script (BASH / SBATCH)

  PROJECT_ROOT=/Users/daniel/project
  CONFNAME=mappers_v0.1.json

  MATLAB_ARGS=""
  MATLAB_ARGS="${MATLAB_ARGS} poolsize=8;"
  MATLAB_ARGS="${MATLAB_ARGS} cohort_csv='${PROJECT_ROOT}/cohort_mapper.csv';"
  MATLAB_ARGS="${MATLAB_ARGS} config_path='${PROJECT_ROOT}/${CONFNAME}';"
  MATLAB_ARGS="${MATLAB_ARGS} data_root='${PROJECT_ROOT}/data/';"
  MATLAB_ARGS="${MATLAB_ARGS} output_dir='${PROJET_ROOT}/results/${CONFNAME}';"

  MAPPERTOOLBOX_MAIN="${PROJECT_ROOT}/mappertoolbox-matlab/code/analysis/run_main.m"

  # write command, submit, wait
  CMD="matlab -r \"${MATLAB_ARGS} run('$MAPPERTOOLBOX_MAIN')\"";
  echo $CMD;
  eval $CMD;
  wait

where we have the following files:

.. code-block::
  :caption: cohort_mapper.csv

  id0,id1,id2,path,TR



.. code-block::
  :caption: mappers_v0.1.json

  {
    "preprocess": [
      { "type": "zscore" }
    ],
    "mappers": [{
      "type": "BDLMapper",
      "k": 32,
      "resolution": [20, 40],
      "gain": 60
    },
    {
      "type": "NeuMapper",
      "k": 16,
      "resolution": 100,
      "gain": [70, 80, 90]
    }],
    "analyses": [
      { "type": "plot_graph" },
      { "type": "compute_stats","args": { "HRF_threshold": 11 } },
      { "type": "compute_temp" }
    ]
  }


The JSON configuration above will generate five Mapper results for each
individual item in cohort file. Two BDLMapper results for 2 resolutions:
20 and 40, finally named: BDLMapper_32_20_60 and BDLMapper_32_40_60.
Three NeuMapper results for 3 gain parameters: 70, 80, and 90, similarly
named.

This configuration runs 1 preprocessing step (zscore) and 3 analysis
steps: `plot_graph`, `compute_stats`, and `compute_temp`.
Check the `run_preprocess` function and the `run_analysis` function for
detailed descriptions on possible preprocessing and analysis possible.


================
Usage
================

.. autofunction:: code.analysis.run_main()

==================
Individual Steps
==================

.. toctree::
  :glob:
  :maxdepth: 2

  preprocessing
  analysis
