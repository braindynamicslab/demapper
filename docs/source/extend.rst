Building an extension to MapperToolbox
========================================

========================================
Adding a new Mapper step
========================================

Mapper options and code is defined in :func:`code.mapper.mapper`

To add a new functionality for a step, you can easily make the switch-case to include your new Mapper. Make sure your code is well-tested and documented at the beginning of the file.

========================================
Adding a new Analysis type
========================================

Let's take adding a new analysis type: `"compute_modularity"` as an example on how to add a new analysis type:

1. Create a new matlab function (as a file) that will be the entrypoint to your new analysis. In our example, create `code/analysis/compute_modularity.m` with the associated inputs, comments, and code:

    .. code-block::

        function compute modularity(res)
        % COMPUTE_MODULARITY Compute the modularity of the mapper shape graph
        % <detailed comments>
        ...
        <code>
        ...
        end

2. Make sure you test the functionality before you add it to the library. You can use one of the data fixtures in `tests` to verify your code. While in the process, create a test file. In our example, create `tests/analysis/test_compute_modularity.m`. Follow the similar test files in the same folder and make sure you use `assert(..)` to verify that a variable is correct.

3. Now that you are confident your code works, you can add it to the :func:`code.analysis.run_analysis` switch-case by adding a new case with your analysis type. For example:

    .. code-block::
        
        switch analysis.type
            case 'compute_modularity'
                ...
        end

4. Note: if you want to use information from the cohort file (TR value or task_path), check different examples in the `run_analysis.m` file and implement them within your case.

5. Test running from a json file by addind your new type as another analysis to be run in `"analyses"`. For example, add the line in the json file:

    .. code-block::

        { "type": "compute_modularity" }

    or 

    .. code-block::
        
        { "type": "compute_modularity", "args": { ... } }

6. Run on your dataset and fine-tune as bugs might appear. Submit your code as a Pull-Request to the github repository and let other people know about your awesome analysis.
