Run Mapper as a library
========================

============================
Mapper Definition
============================

There is one class for Mapper that runs all types of configurations. 
The library is applied on a 2-dimensional matrix and the configuration
option is determined by the options `struct` class passed in. Check the
documentation below to see all possible options for calling the Mapper
function. 

For simpler usage, you can use one of the preset configuration options.

.. autofunction:: code.mapper.mapper()


============================
Preset configurations
============================

You can use preset configurations to easily set all
required Mapper parameters into default configurations.
This is the easiest way to use the library. 

For example, to run a simple mapper algorithm, once you have a 2-dimensional matrix `data`.

.. code-block::

  opts = BDLMapperOpts(32, 20, 70);
  res = mapper(data, opts);


-----------
BDLMapper
-----------

.. literalinclude:: ../../code/mapper/BDLMapperOpts.m


-----------
NeuMapper
-----------

.. literalinclude:: ../../code/mapper/NeuMapperOpts.m

-------------
KeplerMapper
-------------

.. literalinclude:: ../../code/mapper/KeplerMapperOpts.m

