DeMapper: A **De**constructed **Mapper** (TDA) Toolbox for MATLAB
==============

DeMapper is a simple toolbox to run Mapper techniques (from Topological Data Analysis) in MATLAB.

There are many examples on how to use the tool, as tests:
     https://github.com/braindynamicslab/demapper/tree/master/tests

Similarly, the code is documented with the main entrypoints:

- `code.mapper.mapper`: run one mapper on one matrix
- `code.analysis:run_main`: run many mappers and many analyses on "many" matrices in parallel
- `code.analysis:run_preprocess`: run one preprocessing step on one matrix
- `code.analysis:run_analysis`: run one analysis on one matrix

# Cite

This toolbox was published as Hasegan et al., Network Neuroscience, 2024. If you use this toolbox, please cite the paper.

```bibtex
@article{hasegan2024demapper,
  title={Deconstructing the Mapper algorithm to extract richer topological and temporal features from functional neuroimaging data},
  author={Hasegan, Daniel and Geniesse, Caleb and Chowdhury, Samir and Saggar, Manish},
  journal={Network Neuroscience},
  year={2024},
}
```

The code of the analysis that was presented in the paper, can be found within the folder `hasegan_et_al_netneuro_2024/`.

# Tests

Once we make the repository public, activate the workflow to run the tests automatically.
For now, run in MATLAB within the main folder:
  
    addpath(genpath('code'))
    addpath(genpath('tests'))
    tests

# Generating Documentation

Install sphinx

    pip install -r docs/requirements.txt

Then build the sphinx documentation

    sphinx-build -b html docs/source docs/build

To generate for the website, please run the following instead:

    git co website                                  # Check out the website branch
    git merge master                                # Merge the master branch            
                                                    # Resolve any issues with the merge
    sphinx-build -b html docs/source docs           # Build the documentation
    git add docs                                    # Add the documentation to the staging area
    git ci -m "Update documentation"                # Commit the changes
    git push                                        # Push the changes to the website branch

# Authors

Created and maintained by the [Brain Dynamics Lab](https://braindynamicslab.github.io/)

Authors:
- Daniel Hasegan
- Caleb Geniesse
- Samir Chowdhury
- Manish Saggar
