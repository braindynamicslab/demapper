%% Test for run_main.m

% Setup 
clear;
basefolder  = split(pwd, 'demapper');
basefolder  = [basefolder{1}, 'demapper'];
codefolder  = [basefolder,'/code'];
toolsfolder  = [basefolder,'/tests/tools'];
addpath(genpath(codefolder));
addpath(genpath(toolsfolder));


% Setup needed variables and test if it fails without them
testError(@() rmain(),"DeMapper:IncorrectSetup");
cohort_csv = [basefolder, '/tests/fixtures/cohort_mapper.csv'];
testError(@() rmain(),"DeMapper:IncorrectSetup");
config_path = [basefolder, '/tests/fixtures/config.json'];
testError(@() rmain(),"DeMapper:IncorrectSetup");
data_root = [basefolder, '/tests/fixtures'];
testError(@() rmain(),"DeMapper:IncorrectSetup");
output_dir = [basefolder, '/tests/results'];

if exist(output_dir, "dir")
    rmdir(output_dir, 's');
end

run_main

status_results = readtable([output_dir, '/status.csv']);
% csv has the correct rows
assert(strcmp(cell2mat(status_results.id0(1)), 'sub-1'));
assert(strcmp(cell2mat(status_results.id1(1)), 'rest1'));
assert(strcmp(cell2mat(status_results.id2(1)), 'schaefer400x7'));

assert(any(strcmp(status_results.mapper, 'BDLMapper_32_20_60')));
assert(any(strcmp(status_results.mapper, 'NeuMapper_16_100_90')));

% results are correct
assert(size(status_results, 1) == 2);
assert(all(status_results.result == 1));
assert(all(status_results.plot_graph == 1));
assert(all(status_results.compute_stats == 1));

% Rerun the analysis of 'plot_graph` only
rerun_analysis = 'plot_graph';

run_main

status_results = readtable([output_dir, '/status.csv']);

assert(size(status_results, 1) == 4);
assert(all(status_results.plot_graph == 1));
assert(sum(status_results.result) == 0); % 4x(+1 -1) == 0
assert(sum(status_results.compute_stats) == 0); % 4x(+1 -1) = 0

% Rerun the analysis on new config only (could also be new cohort)
new_config_path = [output_dir, '/new_config.json'];
replaceInFile(config_path, new_config_path, ...
    '"resolution": 20,', '"resolution": [20,30],');
config_path = new_config_path;
rerun_uncomputed = true;
clear rerun_analysis

run_main

status_results = readtable([output_dir, '/status.csv']);

assert(size(status_results, 1) == 5);
assert(strcmp(cell2mat(status_results{5, 4}), 'BDLMapper_32_30_60'))
assert(all(status_results{5, 5:end}))

function rmain()
% Run main helper to avoid the MATLAB static setup error
run_main
end

function replaceInFile(inFile, outFile, strIn, strOut)
fid  = fopen(inFile,'r');
f=fread(fid,'*char')';
fclose(fid);
f = strrep(f,strIn,strOut);
fid  = fopen(outFile,'w');
fprintf(fid,'%s',f);
fclose(fid);
end