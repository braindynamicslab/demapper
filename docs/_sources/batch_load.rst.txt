Loading step
=============

The batch algorithm loads the data from multiple files that are set in a cohort file. 

The cohort file is a comma-separated file with two main types of columns: ids and the path. The ids are used to identify the items from each other. One could use any ids that are deemed relevant for identification of items. The path is the location of the data for each item. The path can be relative to another folder or an absolute path (the whole path from root).

The cohort file should have the following columns:

- `id0`: the highest level ID for the item
- `id1`: the medium level ID for the item (could be empty or '' if not needed)
- `id2`: the lowest level ID for the item (could be empty or '' if not needed)
- `path`: the relative or absolute path to the data for the item. Format's allowed are described below.
- `TR`: (optional) the Repetition Time (TR) for the item. If not provided, then TR analysis is not going to be performed. This is useful for fMRI data analysis. 
- `task_path_<tag>`: (optional) the relative or absolute path to the task data for the item. The task data describes how each individual datapoint within the item is related to the task. The format is usually a CSV where it has one column `task_name` and one value for each datapoint. For a dataset of N datapoints, this file should have N rows as each datapoint will be associated with one task item. The `tag` is a string that is used to identify the task. For example, if the tag is `task1`, then the cohort_file column should be named `task_path_task1`. 

Data formats
------------

The cohort_file could point to files of different formats. The following formats are supported:

.. autofunction:: code.analysis.read_data()
