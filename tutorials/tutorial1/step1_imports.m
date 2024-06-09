clear;

% from this file location, go up two levels to find the base folder
basefolder = fileparts(fileparts(fileparts(mfilename('fullpath'))));
codefolder  = [basefolder,'/code']; 
addpath(genpath(codefolder)); % add the code folder to the path

% locate the data folder
datafolder = [basefolder, '/hasegan_et_al_netneuro_2024/data/trefoil_knot/'];
