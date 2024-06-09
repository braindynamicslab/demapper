load('results/tutorial2_mappers/trefoil/BDLMapper_6_5_30/res.mat');

%% Simple visualization. Check Tutorial 1, Step 4 for more details
avgNode = cellfun(@mean, res.nodeMembers);

% and by sizing the nodes based on the number of node members
nodeSize = cell2mat(cellfun(@(x) size(x, 2), res.nodeMembers, 'UniformOutput', false));
nodeSize = normalize(nodeSize, 'range', [3, 10]);

figure;
g = graph(res.adjacencyMat);
plot(g, 'Layout', 'force', 'Usegravity', true, 'WeightEffect', 'inverse', ...
    'MarkerSize', nodeSize, 'NodeCData', avgNode);
colorbar
colormap parula
