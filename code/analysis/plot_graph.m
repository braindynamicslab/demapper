function plot_graph(res, save_path)
% PLOT_GRAPH Plot the Mapper Graph
%
% Inputs:
% :param res: the results from running Mapper
% :type res: Mapper struct
%
% :param save_path: where to save the resulting graph
% :type save_path: string
%

n_nodes = size(res.nodeMembers, 1);
if n_nodes == 0
    return
end

nodeSize = cell2mat(cellfun(@(x) size(x, 2), res.nodeMembers, 'UniformOutput', false));
nodeSize = normalize(nodeSize, 'range', [3, 10]);
avgNode = cellfun(@mean, res.nodeMembers);

g = graph(res.adjacencyMat);

f = figure('visible', 'off');
plot(g, 'Layout', 'force', 'Usegravity', true, 'WeightEffect', 'inverse', ...
    'MarkerSize', nodeSize, 'NodeCData', avgNode);
colorbar
colormap parula
saveas(f, save_path);
close(f);


end