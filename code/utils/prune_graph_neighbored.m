function [adja_pruned, prunedMat, prunedBins] = prune_graph_neighbored( ...
    memberMat, binNeighbors)
% Input:
% - memberMat: matrix of nr bins by nr datapoints. value is 1 if datapoint
% in bin
% - binNeighbors: matrix of nr bins by nr bins. value is 1 if bin i
% is within neighborhood of bin j


%% Find bins that have the same members and neighbors
M = horzcat(memberMat, binNeighbors);
[prunedM, uniq_idx] = unique(M, 'stable', 'rows');
n = size(prunedM,1);
prunedMat = prunedM(1:n, 1:size(memberMat, 2)); % extract only memberMat

% Find the transformed matrix after applying unique
uniq_neighbors = binNeighbors(uniq_idx, uniq_idx);

%% Create weighted adjacency matrix
adja_pruned = double(prunedMat) * double(prunedMat)' ;
adja_pruned = adja_pruned .* (1-eye(n)); % zero-out diagonal
adja_pruned = adja_pruned .* uniq_neighbors; % Filter out non-neighbors

prunedBins = cellfun(@find,num2cell(prunedMat,2),'UniformOutput',false);
end
