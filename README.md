Mapper Toolbox
==============

MapperToolbox-Matlab is a simple toolbox to run Mapper techniques (Topological Data Analysis) in MATLAB.

There are many examples on how to use the tool, as tests:
     https://github.com/braindynamicslab/mappertoolbox-matlab/tree/master/tests

Similarly, the code is documented with the main entrypoints:

- `code.mapper.mapper`: run one mapper one data
- `code.analysis:run_main`: run many mappers and many analyses on "many" data in parallel
- `code.analysis:run_preprocess`: run one preprocessing step on one data
- `code.analysis:run_analysis`: run one analysis on one data

# Tests

Once we make the repository public, activate the workflow to run the tests automatically.
For now, run in MATLAB within the main folder:
  
    tests

# Generating Documentation

Install sphinx

    pip install -r docs/requirements.txt

Then build the sphinx documentation

    sphinx-build -b html docs/source docs/build

# Authors

Created and maintained by the [Brain Dynamics Lab](https://braindynamicslab.github.io/)

Authors:
- Daniel Hasegan
- Caleb Geniesse
- Manish Saggar
- Samir Chowdhury
