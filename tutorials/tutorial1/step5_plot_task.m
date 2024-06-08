% Set the path of the resulting plot
save_path = 'figure_5_1.png';

% Load the "timing" data, coloring each node as one of 3 colors
fn_timing = [datafolder, 'data_treefoil_task.csv'];
timing_table = readtable(fn_timing, 'FileType', 'text', 'Delimiter', ',');
timing_table.task_name = string(timing_table.task_name);

% Define the colormap, so that each node is colored according to the task
cmap = [0 0 1; 0 1 0; 1 0 0]; % Blue, Green, Red

% Simply plot the task by calling `plot_task`
plot_task(res, timing_table, save_path, false, cmap);
