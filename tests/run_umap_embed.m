
% Setup 
clear;
basefolder  = split(pwd, 'demapper');
basefolder  = [basefolder{1}, 'demapper'];
codefolder  = [basefolder,'/code'];
addpath(genpath(codefolder));


% Setup needed variables and test if it fails without them
cohort_csv = '/Users/dh/workspace/BDL/demapper/data/w3c_hightr3/cohort-1sbj.csv';
config_path = '/Users/dh/workspace/BDL/demapper/code/configs/mappers_w3cv8embed_disp.json';
data_root = '/Users/dh/workspace/BDL/demapper/data/w3c_hightr3/';
output_dir = '/Users/dh/workspace/BDL/demapper/results/w3c_hightr3/mappers_w3cv8embed_disp/';

rerun_uncomputed = 1;
% rerun_analysis = 'plot_task';

run_main
