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

% Setup default mapper
% opts = BDLMapperOpts(32, 20, 70);
opts = NeuMapperOpts(32, 200, 35);
% opts = KeplerMapperOpts(20, 70, 'euclidean');
opts.low_mem = false;

% Run mapper
res = mapper(data, opts);

nodeSize = cell2mat(cellfun(@(x) size(x, 2), res.nodeMembers, 'UniformOutput', false));
nodeSize = normalize(nodeSize, 'range', [2, 10]);
avgNode = cellfun(@mean, res.nodeMembers);

g = graph(res.adjacencyMat);

plot(g, 'Layout', 'force', 'Usegravity', true, 'WeightEffect', 'inverse', ...
    'MarkerSize', nodeSize, 'NodeCData', avgNode);
colorbar
colormap parula

