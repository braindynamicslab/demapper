function run_analysis(res, analysis, item, resdir)
% RUN_ANALYSIS runs an analysis step on an item and saves the results to
% the output `resdir`
%
% :param res: the Mapper output result as struct for the item
% :type res: 2D matrix
%
% :param analysis: the config definition of a specific analysis. Minimally, it
%               needs a field `type` as string. It might also have other
%               arguments that are needed for the analysis.
% :type analysis: struct
% 
% :param item: individual item details that are further needed for specifc analysis. 
% :type item: table item
% 
% :param resdir: the path of where to save the analysis results.
% :type resdir: string
%
%
% Possible `analysis` structs types:
%   - ``plot_graph``: plots the mapper shape graph and saved the plot at
%     the path: '../plot_graph.png'.
%   - ``compute_stats``: compute the basis graph statistics (coverage,
%     distances, assortativity, core_periphery) which are
%     saved at the path 'stats.json'. It also produces
%     detailed results (1D files) for the basic graph
%     measures (betweenness_centrality, core_periphery).
%     If the `HRF_threshold` value is provided as an
%     argument within the analysis struct, then the item
%     needs a `TR` value, and the HRF_DURATION_STAT will be
%     computed. The TR value is expected as either another
%     argument or as a column part of the `item`.
%   - ``compute_temp``: creates the temporal connectivity matrices (TCM and
%     TCM_inverted) which are saved as plots and as matrices
%     (as 1D files). If skip_mat is set, it will avoid saving
%     the matrix.
%   - ``plot_task``: plots the mapper shape graph with each node labelled based
%     on a task file. This analysis requires extra arguments.
%     First, "name" is required and can be any string. Second, a
%     path to a CSV file is needed. The path can be set as an
%     argument in the analysis as "task_path" argument, or
%     alternatively, as a table column part of the `item`
%     analyzed, with the column name as: "task_path_<name>",
%     where <name> represents the name defined as an argument.
% 
%

switch analysis.type
    case 'plot_graph'
        plot_graph(res, [resdir, '/plot_graph.png'])
    case 'plot_task'
        if isfield(analysis, 'args') && isfield(analysis.args, 'name')
            % plot_task needs a name
            name = analysis.args.name;

            % extract the path of the CSV file for plot_task
            if isfield(analysis.args, 'path')
                task_path = analysis.args.path;
            end
            task_field = ['task_path_', name];
            if any(strcmp(fieldnames(item), task_field))
                task_path = item.(task_field);
                if iscell(task_path)
                    task_path = cell2mat(task_path);
                end
            end
            if ~exist('task_path', 'var')
                error('MapperToolbox:IncorrectAnalysisArguments', ...
                    'Cannot process plot_task %s because of missing task path', name);
            end

            % Read the task labels CSV file
            timing_table = read_task_file(task_path);
            if any(strcmp(fieldnames(item), 'tmask'))
                % if tmask is available, filter the task labels by it
                tmask_path = item.tmask;
                if iscell(tmask_path)
                    tmask_path = cell2mat(tmask_path);
                end
                tmask = read_1d(tmask_path);
                timing_table = timing_table(tmask == 1, 1:end);
            end

            % if analysis.args.no_legend is true, then skip plotting a legend
            no_legend = false;
            if isfield(analysis.args, 'no_legend')
                no_legend = analysis.args.no_legend;
            end

            % if analysis.args.cmap is set, use it for plotting
            has_cmap = false;
            if isfield(analysis.args, 'cmap')
                cmap = analysis.args.cmap;
                has_cmap = true;
            end

            % Finally, call the plot_task function
            if has_cmap
                % TODO: Would love to learn how to do this in one line instead of the if
                % Please let me know if you have a solution
                plot_task(res, timing_table, ...
                    [resdir, '/plot_task-', name, '.png'], no_legend, cmap)
            else
                plot_task(res, timing_table, ...
                    [resdir, '/plot_task-', name, '.png'], no_legend)
            end
        else
            error('MapperToolbox:IncorrectAnalysisArguments', ...
                'Cannot process analysis of type: %s because of missing arguments', analysis.type);
        end
    case 'compute_stats'
        args = struct;
        if isfield(analysis, 'args')
            % If there are args, use them
            args = analysis.args;
            if isfield(args, 'HRF_threshold')
                % if HRF_threshold is required for the
                % analysis, expect having the TR in the
                % cohort file
                assert(any(strcmp('TR', item.Properties.VariableNames)), ...
                    'Need to have TR as part of cohort file')
                args.TR = str2double(cell2mat(item.TR));
            end
        end
        compute_stats(res, args, resdir);
    case 'compute_temp'
        % if analysis.args.skip_mat is true, then skip printing out the
        % matrices of TCM and TCM-inv
        skip_mat = false;
        if isfield(analysis, 'args') && isfield(analysis.args, 'skip_mat')
            skip_mat = analysis.args.skip_mat;
        end
        compute_temp(res, resdir, skip_mat);
end
end

%% Helper functions
function timing_table = read_task_file(task_path)
timing_table = readtable(task_path, 'FileType', 'text', 'Delimiter', ',');
timing_table.task_name = string(timing_table.task_name);
end