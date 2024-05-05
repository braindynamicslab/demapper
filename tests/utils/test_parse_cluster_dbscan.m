% Setup base path
clear;
basefolder = fileparts(fileparts(fileparts(mfilename('fullpath'))));
codefolder  = [basefolder,'/code'];
toolsfolder  = [basefolder,'/tests/tools'];
addpath(genpath(codefolder));
addpath(genpath(toolsfolder));

% Load Data
data_path = [basefolder, '/tests/fixtures/sub-1_rest1_schaefer400x7_ts.1D'];

data = read_1d(data_path);
data = zscore(data);

% Test Kepler Mapper
opts = KeplerMapperOpts(20, 70, 'euclidean');
opts.low_mem = false;

% Run mapper
res = mapper(data, opts);

distMat = res.distances_X;
kvalue = 32;

[smallBin1, ~, eps1] = part_cluster_dbscan(res.bigBin, distMat, 'fixed', 10, 2);
[smallBin2, ~, eps2] = part_cluster_dbscan(res.bigBin, distMat, 'elbow', kvalue, 2);
[smallBin3, ~, eps3] = part_cluster_dbscan(res.bigBin, distMat, 'median', kvalue, 2);

assert(length(smallBin1) > length(smallBin2));
assert(length(smallBin2) >= length(smallBin3));
assert(eps1 == 10)
assert(eps1 < eps2)
assert(eps2 < eps3)
