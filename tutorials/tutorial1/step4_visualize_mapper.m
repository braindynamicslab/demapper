%% Figure 4.1
% Generate the simplest adjacency matrix
figure;
g = graph(res.adjacencyMat);
plot(g, 'Layout', 'force', 'Usegravity', true, 'WeightEffect', 'inverse');


%% Figure 2
% We can do better by coloring the nodes based on the average value of the node members
% averaging over nodeMembers cell array
avgNode = cellfun(@mean, res.nodeMembers);

% and by sizing the nodes based on the number of node members
nodeSize = cell2mat(cellfun(@(x) size(x, 2), res.nodeMembers, 'UniformOutput', false));
nodeSize = normalize(nodeSize, 'range', [10, 20]);

figure;
g = graph(res.adjacencyMat);
plot(g, 'Layout', 'force', 'Usegravity', true, 'WeightEffect', 'inverse', ...
    'MarkerSize', nodeSize, 'NodeCData', avgNode);
colorbar
colormap parula

%% Figure 3
% We can do even better by coloring the nodes based on the average color of the node members
% This time, we use the `nodeCData` data to color the nodes 
nodeColor = cellfun(@(x) mean(nodeCData(x, :), 1), res.nodeMembers, 'UniformOutput', false);
nodeColor = cell2mat(nodeColor);

figure;
g = graph(res.adjacencyMat);
plot(g, 'Layout', 'force', 'Usegravity', true, 'WeightEffect', 'inverse', ...
    'MarkerSize', nodeSize, 'NodeColor', nodeColor(:, 1:3));
