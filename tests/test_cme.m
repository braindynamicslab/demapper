% Setup base path
% clear;
basefolder  = split(pwd, 'mappertoolbox-matlab');
basefolder  = [basefolder{1}, 'mappertoolbox-matlab'];
codefolder  = [basefolder,'/code'];
toolsfolder  = [basefolder,'/tests/tools'];
addpath(genpath(codefolder));
addpath(genpath(toolsfolder));

% Load Data
% data_path = [basefolder, '/tests/fixtures/sub-1_rest1_schaefer400x7_ts.1D'];
% data_path = [basefolder, '/tests/fixtures/sub-1_rest1_schaefer400x7_ts.1D'];
data_path = '/Users/dh/workspace/BDL/bdl-mapper/data-cme-gordon/SBJ01_Gordon333.npy';

% data = read_1d(data_path);
data = readNPY(data_path);
% data = zscore(data);

% Setup default mapper
opts = BDLMapperOpts(6, 20, 70);
% opts = NeuMapperOpts(32, 200, 35);
% opts = KeplerMapperOpts(20, 70, 'euclidean');
opts.low_mem = false;
opts.verbose = false;

% Run mapper
res = mapper(data, opts);

nodeSize = cell2mat(cellfun(@(x) size(x, 2), res.nodeMembers, 'UniformOutput', false));
nodeSize = normalize(nodeSize, 'range', [2, 10]);
avgNode = cellfun(@mean, res.nodeMembers);

g = graph(res.adjacencyMat);
% 
% figure
% 
% plot(g, 'Layout', 'force', 'Usegravity', true, 'WeightEffect', 'inverse', ...
%     'MarkerSize', nodeSize, 'NodeCData', avgNode);
% colorbar
% colormap parula

figure 
A = res.adjacencyMat;
A(A> 0) = 1;
NNAdj = res.adjacencyMat;
g = graph(A);
plot(g,'Layout','force','UseGravity','on','NodeCData',[1:size(NNAdj,1)],'MarkerSize',10);
% plot(g,'Layout','force','UseGravity','on','NodeCData',inds,'MarkerSize',10);

