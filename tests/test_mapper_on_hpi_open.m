% Setup base path
clear;
basefolder  = split(pwd, 'mappertoolbox-matlab');
basefolder  = [basefolder{1}, 'mappertoolbox-matlab'];
codefolder  = [basefolder,'/code'];
toolsfolder  = [basefolder,'/tests/tools'];
addpath(genpath(codefolder));
addpath(genpath(toolsfolder));

% Load Data
% data_path = '/Users/dh/workspace/BDL/creativity/data/processed/sub-9999/sub-9999_combined_gordon333_ts.1D';
data_path = '/Users/dh/workspace/BDL/creativity/data/processed/sub-8888/sub-8888_combined_gordon333_ts.1D';

data = read_1d(data_path);
data = zscore(data);

% Setup default mapper
% opts = BDLMapperOpts(36, 25, 50);
opts = BDLMapperOpts(16, 30, 60);
% opts = NeuMapperOpts(8, 100, 30);

% opts.dist_type = 'euclidean';
% opts = KeplerMapperOpts(20, 70, 'euclidean');
opts.low_mem = false;

% Run mapper
res = mapper(data, opts);

figure
scatter(res.embed_X(:, 1), res.embed_X(:, 2));

figure
nodeSize = cell2mat(cellfun(@(x) size(x, 2), res.nodeMembers, 'UniformOutput', false));
nodeSize = normalize(nodeSize, 'range', [2, 10]);
avgNode = cellfun(@mean, res.nodeMembers);

g = graph(res.adjacencyMat);

plot(g, 'Layout', 'force', 'Usegravity', true, 'WeightEffect', 'inverse', ...
    'MarkerSize', nodeSize, 'NodeCData', avgNode);
colorbar
colormap parula

