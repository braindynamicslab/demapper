%% Test that multiple plot_task analyses run correctly and dont interfere

% Setup base path
clear;
basefolder = fileparts(fileparts(fileparts(mfilename('fullpath'))));
codefolder  = [basefolder,'/code'];
toolsfolder  = [basefolder,'/tests/tools'];
addpath(genpath(codefolder));
addpath(genpath(toolsfolder));

% Load Data
data_root = [basefolder, '/tests/fixtures/cme'];
cohort_csv = [data_root, '/cohort_mapper.csv'];
config_path = [data_root, '/configMulti.json'];
output_dir = [basefolder, '/tests/results/cme_multi'];

if strcmp(pwd,basefolder)
    % If this test is being run from root, then use a special config file
    % in order to fix the relative path for plot_task analysis.
    config_path = [data_root, '/configMulti_root.json'];
end

if exist(output_dir, "dir")
    rmdir(output_dir, 's');
end

% RUN MAIN
run_main

% Extract Results
resdir = [output_dir, '/SBJ99/BDLMapper_8_5_50'];
res = load([resdir, '/res.mat']).res;

statuses = readtable([output_dir, '/status.csv'], ...
    'PreserveVariableNames', true);

% Verify correct header
assert(any(strcmp(statuses.Properties.VariableNames, 'plot_task-CMEX1')))
assert(any(strcmp(statuses.Properties.VariableNames, 'plot_task-CMEX2')))
assert(all(~strcmp(statuses.Properties.VariableNames, 'plot_task')))

% Verify successful run
assert(statuses.('plot_task-CMEX1'))
assert(statuses.('plot_task-CMEX2'))


rerun_analysis = 'plot_task-CMEX2';
run_main

% Reverify that it reran
statuses = readtable([output_dir, '/status.csv'], ...
    'PreserveVariableNames', true);

% Verify successful rerun and skip
assert(all(statuses.('plot_task-CMEX2')))
assert(sum(statuses.('plot_task-CMEX1')) == 0)


% Now test with tmask
cohort_csv = [data_root, '/cohort_mapper_masked.csv'];
output_dir = [basefolder, '/tests/results/cme_multi_masked'];
clear rerun_analysis
run_main

% Reverify that it reran
statuses = readtable([output_dir, '/status.csv'], ...
    'PreserveVariableNames', true);

% Verify successful run with tmask
assert(statuses.('plot_task-CMEX1'))
assert(statuses.('plot_task-CMEX2'))
