Start here
============

After you install and load up the package in MATLAB (check :doc:`installation` if you havent),
you can start using the Mapper algorithm by running the following command:

.. code-block::

  opts = BDLMapperOpts(32, 20, 70);
  res = mapper(data, opts);

- This will set up a default Mapper algorithm with 20 bins, 70% overlap, and using a k-value of 32. 

- The `data` parameter should be a matrix of size `n x m` where `n` is the number of samples and `m` is the number of features. The Mapper will dimensionaly reduce on the *rows* dimension, compressing the data into a graph structure that represents the shape of the data. 

The `res` variable will contain the Mapper output, representing the graph structure of the data.
You can simply visualize it as follows:

.. code-block:: matlab

    figure;
    g = graph(res.adjacencyMat);
    plot(g, 'Layout', 'force', 'Usegravity', true, 'WeightEffect', 'inverse');

**Next steps**

For more information on the Mapper algorithm, check the :doc:`mapper` page.

Or you can follow the tutorials to get a step-by-step guide on how to use the Mapper algorithm
in different scenarios. :doc:`tutorial1` is a good place to start.
