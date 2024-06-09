Tutorial 3: Running Mappers on fMRI data
=========================================

In this tutorial, we will run the Mapper algorithm on fMRI data. We expect that you have gone through the previous tutorials and have a basic understanding of the Mapper algorithm.

Let's say that you have a dataset of fMRI data of 1 participant performing a task over two MRI sessions. You analyzed your data with `fmriprep <https://fmriprep.org/en/stable/>`_ and `xcpengine <https://xcpengine.readthedocs.io/>`_.  Now, your xcpengine process generated a `cohort.csv` file with the following columns, using the schaefer400x7 parcelation atlas. The file looks like this:

.. code-block::

    id0,id1,id2,path,TR
    sub-1,task1,schaefer400x7,sub-1_task1_schaefer400x7_ts.1D,0.72
    sub-1,task2,schaefer400x7,sub-1_task1_schaefer400x7_ts.1D,0.72

The `path` column contains the path to the timeseries data, and the `TR` column contains the repetition time of the fMRI data.

In this tutorial, we will run the Mapper algorithm on the fMRI data of the participant for both sessions.

===============================
Step 1. Mappers configuration
===============================

Let's say we want to analyze the Mapper graphs for the fMRI data of the participant. We do not know which parameters to use for the Mapper algorithm, so we have to run the DeMapper toolbox to generate all of the Mapper graphs for different parameters.

We will generate the following configuration:

