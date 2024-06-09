Analysis steps
======================

====================
Usage
====================

.. autofunction:: code.analysis.run_analysis()

Below, we have a few examples of analysis objects (in JSON format)
with an associated item:

====================
Analysis Examples
====================

.. code-block::
  :caption: Example 1: Plot simple shape graph figure

  Analysis:
  { "type": "plot_graph" }
  Explanation: 
  Running this analysis will create the file: `plot_graph.png`


.. code-block::
  :caption: Example 2: Compute basic stats

  Analysis:
  { "type": "compute_stats" }
  Explanation:
  Running this analysis will multiple files with the prefix stats:
  `stats.json`: is a json file with basic stats of the mapper shape graph
  `stats_degrees_TRs.1D: is a 1D file with each line representing the node
                         degree of each TR in the shape graph
  `stats_core_periphery.1D`: is a 1D file representing the core-periphery
                             value for each node of the mapper shape graph
  `stats_core_periphery_TRs_avg.1D`: is a 1D file representing the
                                     core-periphery value for each TRs
                                     computed as an average from each node
  `stats_betweenness_centrality.1D`: the betweenness centrality of each node
                                     of the mapper shape graph
  `stats_*`: other stats computed


.. code-block::
  :caption: Example 3: Compute basic stats with HRF measure

  Analysis:
  { "type": "compute_stats", "args": { "HRF_threshold": 11 } }
  Example cohort table (CSV file):
  id0,id1,id2,path,TR
  SBJ01,REST_LR_1,gordon333,/path/to/SBJ01/REST_LR_1/gordon333.npy,0.72
  SBJ02,REST_LR_1,gordon333,/path/to/SBJ02/REST_LR_1/gordon333.npy,0.72
  Explanation:
  Running this analysis will produce similar results as the previous
  `compute_stats` example, with the additional stats related to HRF stats:
  Now, `stats.json` will include a `hrfdur_stat` statistic of the percentage
  of nodes of the shape graph that have TRs with a time difference higher
  than the `HRF_threshold` in seconds. For this, the RepetitionTime of each
  scan is needed, and provided as part of the cohort file. In our example, we
  will have nodes that have TRs separated by 11s, or 11s / 0.72 (TR) = 15
  steps. 


.. code-block::
  :caption: Example 4: Compute temporal connectivity/similarity matrices (TCM)

  Analysis:
  { "type": "compute_temp", "args": { "skip_mat": true } }
  Explanation:
  Running this analysis will produce 2 files representing the similarity
  matrix and its inverse, in PNG format only. Changing the "skip_mat" value
  to false, will print two 1D files with the TCM matrix and it's inverse.


.. code-block::
  :caption: Example 5: Plot task

  Analysis:
  { "type": "plot_task", "args": { "name": "CME", "path": "/path/to/timing.csv" } }
  Explanation:
  Running this analysis will create the file: `plot_task-CME.png` that will
  color each node as a pie chart with the distribution of each label of TRs.
  The label of each TR is extracted from the column `task_name` from the CSV
  linked.
  Important Requirement: the CSV containing the task_name column, should have
  the same number of rows as number of TRs in all inputs from the cohort
  file. If you have a varying number of rows (nr of TRs) for different
  inputs, then you have to set a separate task file for each of those item in
  the cohort file. Check the example below for such a setup.


.. code-block::
  :caption: Example 6: Plot task with varying number of TRs

  Analysis:
  { "type": "plot_task", "args": { "name": "CME" }
  Example cohort table (CSV file):
  id0,id1,id2,path,TR,task_path_CME
  SBJ01,REST,gordon333,/path/to/bold1.npy,0.72,/path/to/task_labels_for_item1.csv
  SBJ02,REST,gordon333,/path/to/bold2.npy,0.72,/path/to/task_labels_for_item2.csv
  Explanation:
  Running this analysis is similar to the `plot_task` example above but each
  individual item from the cohort file has it's own separate task labels.
  This is a useful setting in case your bold files have a varying number of
  TRs per scan. 


.. code-block::
  :caption: Example 7: Plot task on task labels with a temporal filtering mask

  Analysis:
  { "type": "plot_task", "args": { "name": "CME" }
  Example cohort table (CSV file):
  id0,id1,id2,path,TR,task_path_CME,tmask
  SBJ01,REST,g333,/path/to/bold1.npy,0.72,/path/to/lbls_item1.csv,/path/to/confound2/scrubbed_item1.1D
  SBJ02,REST,g333,/path/to/bold2.npy,0.72,/path/to/lbls_item2.csv,/path/to/confound2/scrubbed_item2.1D
  Explanation:
  Running this analysis is similar to the `plot_task` example above but in
  this case the CSV is filtered by the tmask. This setup is useful when
  running after a task that removes certain TRs of the scan. In that case,
  the labels need to be filtered as well.

================
Analysis Types
================

.. autofunction:: code.analysis.plot_graph()

.. autofunction:: code.analysis.plot_task()

.. autofunction:: code.analysis.compute_stats()

.. autofunction:: code.analysis.compute_temp()
