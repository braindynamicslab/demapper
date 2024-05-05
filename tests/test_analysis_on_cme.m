%% Test for CME data on run_main.m

% Setup base path
clear;
basefolder = fileparts(fileparts(mfilename('fullpath')));
codefolder  = [basefolder,'/code'];
toolsfolder  = [basefolder,'/tests/tools'];
addpath(genpath(codefolder));
addpath(genpath(toolsfolder));

% Load Data
data_root = [basefolder, '/tests/fixtures/cme'];
cohort_csv = [data_root, '/cohort_mapper.csv'];
config_path = [data_root, '/config.json'];
output_dir = [basefolder, '/tests/results/cme'];

if strcmp(pwd,basefolder)
    % If this test is being run from root, then use a special config file
    % in order to fix the relative path for plot_task analysis.
    config_path = [data_root, '/config_root.json'];
end

if exist(output_dir, "dir")
    rmdir(output_dir, 's');
end

% RUN MAIN
run_main

% Extract Results
resdir = [output_dir, '/SBJ99/BDLMapper_32_20_60'];
res = load([resdir, '/res.mat']).res;

% Display the results
nodeSize = cell2mat(cellfun(@(x) size(x, 2), res.nodeMembers, 'UniformOutput', false));
nodeSize = normalize(nodeSize, 'range', [2, 10]);
avgNode = cellfun(@mean, res.nodeMembers);

g = graph(res.adjacencyMat);

plot(g, 'Layout', 'force', 'Usegravity', true, 'WeightEffect', 'inverse', ...
    'MarkerSize', nodeSize, 'NodeCData', avgNode);
colorbar
colormap parula
