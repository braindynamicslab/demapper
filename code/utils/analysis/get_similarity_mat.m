function tpmat = get_similarity_mat(nodes_adj, node_to_Tp)
% GET_SIMILARITY_MAT create a similarity matrix from Mapper results
%
% Inputs:
%   - nodes_adj: nodes adjacency matrix
%   - node_to_Tp: node to timepoint matrix
% Outputs:
%   - tpmat: matrix of timepoint by timepoint as a similarity metric

if all(diag(nodes_adj) == 0)
  % If adjacency matrix diagonal is 0 then add similarity between TRs of the same node.
  tpmat = node_to_Tp' * (nodes_adj > 0) * node_to_Tp + node_to_Tp' * node_to_Tp;
else
  tpmat = node_to_Tp' * (nodes_adj > 0) * node_to_Tp;
end
tpmat(1:size(tpmat,1)+1:end) = 0;

end
