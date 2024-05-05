clear;
basefolder = fileparts(fileparts(fileparts(mfilename('fullpath'))));
codefolder  = [basefolder,'/code'];
toolsfolder  = [basefolder,'/tests/tools'];
addpath(genpath(codefolder));
addpath(genpath(toolsfolder));

res = load([basefolder, '/tests/fixtures/cme/mapper/res.mat']).res;
task_path = [basefolder, '/tests/fixtures/cme/mapper/timing.csv'];

resdir = [basefolder, '/tests/results/cme/SBJ99/TestPlotTaskMapper/'];
if ~exist(resdir, 'dir')
    mkdir(resdir);
end

% Test plot_task
analysis = struct;
analysis.type = 'plot_task';
item = table;
item.Name = ["SBJ99"];

testError(@() run_analysis(res, analysis, item, resdir), ...
    'DeMapper:IncorrectAnalysisArguments');

analysis.args = struct;
testError(@() run_analysis(res, analysis, item, resdir), ...
    'DeMapper:IncorrectAnalysisArguments');

analysis.args.name = 'BA';
testError(@() run_analysis(res, analysis, item, resdir), ...
    'DeMapper:IncorrectAnalysisArguments');

analysis.args.path = task_path;
run_analysis(res, analysis, item, resdir);

listing = dir(resdir);
assert(any(strcmp('plot_task-BA.png', {listing.name})));

% Test that individual item task works as well
analysis.args = rmfield(analysis.args, 'path');
item.task_path_BA = task_path;
run_analysis(res, analysis, item, resdir);

% Test compute_temp with skip_mat
config3_path = [basefolder, '/tests/fixtures/config3.json'];
c3 = read_json(config3_path);
analysis = cell2mat(c3.analyses(3));

run_analysis(res, analysis, item, resdir);

listing = dir(resdir);
assert(any(strcmp('compute_temp-TCM.png', {listing.name})));
assert(any(strcmp('compute_temp-TCM_inv.png', {listing.name})));
assert(~any(strcmp('compute_temp-TCM-mat.1D', {listing.name})));
