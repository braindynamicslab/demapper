Installation
=============

To get DeMapper, download the repository from GitHub from following the link:
https://github.com/braindynamicslab/demapper.

Or by cloning the project using the following command if you have SSH keys set up:

.. code-block::

  git clone git@github.com:braindynamicslab/demapper.git

Or by cloning the project using the HTTPS link:

.. code-block::

  git clone https://github.com/braindynamicslab/demapper.git


MATLAB Setup
-------------

Once you have the repository, you can use it directly by adding the path
to the repository to your MATLAB path.

.. code-block::

  addpath(genpath('path_to_demapper'));

CLI Setup
----------

You don't have to open MATLAB to run the deMapper Toolbox. 
You can run the Mapper algorithm from the command line interface (CLI)
by running the following command:

.. code-block:: bash

  matlab -nodesktop -r "$ARGS run('path_to_demapper/code/analysis/run_main.m')"

.. note::
  
  You need MATLAB installed on your computer. Ideally it is linked to the `matlab` 
  command. Otherwise, you might have to change the way to call MATLAB in the command line.

Where `$ARGS` is the arguments you want to pass to the Mapper CLI.
Follow :doc:`batch` for more information on how to use the CLI.
Or check :doc:`tutorial2` for a step-by-step guide on how to use the CLI.

  