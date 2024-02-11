% Setup base path
clear;
basefolder  = split(pwd, 'mappertoolbox-matlab');
basefolder  = [basefolder{1}, 'mappertoolbox-matlab'];
codefolder  = [basefolder,'/code'];
toolsfolder  = [basefolder,'/tests/tools'];
addpath(genpath(codefolder));
addpath(genpath(toolsfolder));

% Load Data
data_path = [basefolder, '/tests/fixtures/sub-1_rest1_schaefer400x7_ts.1D'];

data = read_1d(data_path);
data = zscore(data);
opts = BDLMapperOpts(32, 20, 70);
res = mapper(data, opts);

% Output dir folder
out_resdir = [basefolder, '/tests/results/test_compute_temp'];
if ~exist(out_resdir, 'dir')
    mkdir(out_resdir);
end

% run the `compute_temp`
compute_temp(res, out_resdir);

% check if it created all the files
listing = dir(out_resdir);
assert(any(strcmp('compute_temp-TCM.png', {listing.name})));
assert(any(strcmp('compute_temp-TCM_inv.png', {listing.name})));

TCM = read_1d([out_resdir, '/compute_temp-TCM-mat.1D']);
assert(all(size(TCM) == [1166, 1166]))
TCM = read_1d([out_resdir, '/compute_temp-TCM_inv-mat.1D']);
assert(all(size(TCM) == [1166, 1166]))
