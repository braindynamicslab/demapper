% Setup base path
clear;
basefolder  = split(pwd, 'mappertoolbox-matlab');
basefolder  = [basefolder{1}, 'mappertoolbox-matlab'];
codefolder  = [basefolder,'/code'];
toolsfolder  = [basefolder,'/tests/tools'];
addpath(genpath(codefolder));
addpath(genpath(toolsfolder));

% Load Data
data_path = [basefolder, '/tests/fixtures/chan-60_-1000to1499ms.txt'];

data = read_1d(data_path);
data = data';
% baseline zscore:
baseline = data(1:1000, :);
[~, miu, sigma] = zscore(baseline);
data = (data - miu) ./ sigma;

% Setup default mapper
opts = NeuMapperOpts(16, 200, 50);

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
