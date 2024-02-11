function plot_task(res, timing_table, save_path, no_legend, cmap)
% PLOT_TASK Plot the Mapper Graph based on task data
%
% :param res: the results from running Mapper
% :type res: Mapper struct
%
% :param timing_table: describes the task performed as classifying
%                   each TR as a value described in 'task_name'.
%                   Optionally, one can add 'task' field as the ID of
%                   the task. The table must have the same amount of rows
%                   as there are TRs in the Mapper result.
% :type timing_table: table 
%
%
% :param save_path: where to save the resulting graph plot
% :type save_path: string
%
% :param no_legend: if set to True, it will not print the legend
% :type no_legend: bool
%
% :param cmap: if set, it is a matrix that has the same number of rows as
%           tasks in timing_table. Expected 3 columns for RGB for each task.
% :type cmap: (3xN) 2D Matrix
%
%

if nargin < 4
    no_legend = false;
end
if nargin < 5
    has_cmap = false;
else
    has_cmap = true;
end


n_nodes = size(res.nodeMembers, 1);
if n_nodes == 0
    return
end

% [1] Check for correct arguments
if ~table_isfield(timing_table, 'task_name')
    error('MapperToolbox:PlotTaskMissingTaskNames', ...
        'Cannot process plot_task without `task_name` as part of the CSV');
end
task_names = timing_table.task_name;
if length(task_names) ~= size(res.memberMat, 2)
    error('MapperToolbox:PlotTaskDimentionsFailure', ...
        'Contradicting dimensions: %d TRs vs %d task items', ...
        size(res.memberMat, 2), length(task_names));
end
if table_isfield(timing_table, 'task')
    task_arr = timing_table.task;
else
    task_arr = zeros(size(task_names));
    tasks = unique(task_names);
    for i=1:length(tasks)
        task_arr(task_names == tasks(i)) = i;
    end
end
assert(length(task_arr) == length(task_names)) % sanity check

% [2] Count the number of TRs of each task class for each node `nodeProbs`
tasks = unique(task_arr);
nodeProbs = zeros(size(res.memberMat, 1), length(tasks));
for i=1:length(tasks)
    nodeProbs(:, i) = res.memberMat * (task_arr == tasks(i));
end

% [3] Plot the pie graph
if ~has_cmap
    cmap = hsv(length(tasks));
end
f = plot_pie_graph(res.adjacencyMat, nodeProbs, cmap, 'off');
hold on

% [4] set legend
if ~no_legend
    h = zeros(length(tasks), 1);
    tasks_legend = [];
    for i=1:length(tasks)
        h(i) = plot(NaN, NaN, '.', 'Color', cmap(i, :));
        tasks_legend = vertcat(tasks_legend, task_names(find(task_arr == tasks(i), 1)));
    end
    legend(h, tasks_legend, 'Interpreter', 'none');
end

% [5] Save and close the figure
saveas(f, save_path);

close(f);
end

%% Helper functions
function b = table_isfield(tbl, f)
    b = sum(ismember(tbl.Properties.VariableNames, f));
end