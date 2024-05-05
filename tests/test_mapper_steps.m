%% Test of code/mapper/mapper.m
% Setup base path
clear;
basefolder = fileparts(fileparts(mfilename('fullpath')));
codefolder  = [basefolder,'/code'];
toolsfolder  = [basefolder,'/tests/tools'];
addpath(genpath(codefolder));
addpath(genpath(toolsfolder));

% Load Data
data = readNPY([basefolder, '/tests/fixtures/example-data.npy']);

% [1] Test BDL Mapper
options = struct;
options.verbose=true;
options.preprocess_type = 'PCA';
options.preprocess_varexpl = 99.99;
options.dist_type = 'euclidean';
options.prelens_type = 'wtd-pen';
options.prelens_rknnparam = 16;
options.embed_type = 'CMDS';
options.embed_dim = 2;
options.binning_type = 'Nd';
options.binning_resolution = 20;
options.binning_gain = 75;
options.binning_nsides = 4;
options.clustering_type = 'linkage_histo';
options.clustering_histo_bins = 10;
options.finalgraph_type = 'full';

options.low_mem = true;
res = mapper(data, options);

% [2] Test NeuMapper
options = struct;
options.verbose=true;
options.preprocess_type = 'none';
options.dist_type = 'cityblock';
options.prelens_type = 'wtd-pen';
options.prelens_rknnparam = 16;
options.embed_type = 'none';
options.binning_type = 'cball';
options.binning_resolution = 200;
options.binning_gain = 50;
options.clustering_type = 'linkage_histo';
options.clustering_histo_bins = 10;
options.finalgraph_type = 'full';

options.low_mem = true;
res = mapper(data, options);

% [3] Test Kepler Mapper
options = struct;
options.verbose=true;
options.preprocess_type = 'PCA';
options.preprocess_varexpl = 99.99;
options.dist_type = 'euclidean';
options.prelens_type = 'dist';
options.embed_type = 'tSNE';
options.embed_dim = 2;
options.embed_perplexity = 50;
options.binning_type = 'Nd';
options.binning_resolution = 20;
options.binning_gain = 75;
options.binning_nsides = 4;
options.clustering_type = 'DBSCAN';
options.clustering_eps_type = 'median';
options.clustering_eps_arg = 32;
options.clustering_minpts = 2;
options.finalgraph_type = 'neighbors';

options.low_mem = true;
res = mapper(data, options);
