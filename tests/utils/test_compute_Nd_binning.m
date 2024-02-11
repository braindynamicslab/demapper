% Setup base path
clear;
basefolder  = split(pwd, 'demapper');
basefolder  = [basefolder{1}, 'demapper'];
codefolder  = [basefolder,'/code'];
toolsfolder  = [basefolder,'/tests/tools'];
addpath(genpath(codefolder));
addpath(genpath(toolsfolder));

% Load Data
data_path = [basefolder, '/tests/fixtures/w3c/SBJ99_bold.npy'];
data = readNPY(data_path);
data = zscore(data);

opts = BDLMapperOpts(24, 20, 60); % DimReducMapper_euclidean_PCA_4_24_20_60
opts.dist_type = 'euclidean';
opts.embed_type = 'PCA';
opts.embed_dim = 4;
opts.embed_kparam = 32;
opts.low_mem = false;

% Run mapper
res = mapper(data, opts);

[~, bigBin_Nd_indices] = compute_Nd_binning(res.embed_X, ...
            opts.binning_resolution, opts.binning_gain, opts.binning_nsides);

% test that the indices are correct
resum = power(20, 0:3); % [1, 20, 400, 8000];
for i = 1:size(bigBin_Nd_indices, 1)
    assert(sum((bigBin_Nd_indices(i, :) - 1) .* resum) == i - 1)
end

nodeSize = cell2mat(cellfun(@(x) size(x, 2), res.nodeMembers, 'UniformOutput', false));
nodeSize = normalize(nodeSize, 'range', [2, 10]);
avgNode = cellfun(@mean, res.nodeMembers);

g = graph(res.adjacencyMat);

figure;

plot(g, 'Layout', 'force', 'Usegravity', true, 'WeightEffect', 'inverse', ...
    'MarkerSize', nodeSize, 'NodeCData', avgNode);
colorbar
colormap parula

