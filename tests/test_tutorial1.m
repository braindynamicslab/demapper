clear;

% from this file location, go up two levels to find the base folder
basefolder = fileparts(fileparts(mfilename('fullpath')));
tutfolder  = [basefolder,'/tutorials/tutorial1/']; 
addpath(genpath(tutfolder)); % add the code folder to the path

step1_imports
step2_loaddata
step3_mapper_simple
step4_visualize_mapper
step5_plot_task
step6_utils
