% WGGGG
%
% aim - to code neighborhood based filter function in Matlab
% authors - saggar@stanford.edu (7.11.2019)
%           hasegan@stanford.edu (1.7.2022)
%
%
% output: knnGraph (as a table, binary and weighted versions)
%
% inspired by the paper on penalized KNN graph in Baya & Granitto 2011 BMC
% Bioinformatics
%
% Version History
% - [7.11.19] Wrote it to perform knn graph construction with outlier
% removal and penalized edges to construct a single connected component
% - [1.7.22] Use a fixed normalizer for the exponential penalizing function
%
function [knnGraphTbl, knnGraph_bin, knnGraph_wtd, knnGraph_bin_conn, knnGraph_wtd_conn]= createPKNNG_bdl(distMat, num_k)
   % create neighborhood graph
   knnGraphTbl = zeros(size(distMat,1), num_k);
   knnGraph_bin = zeros(size(distMat));
   knnGraph_wtd = zeros(size(distMat));
   for n = 1:1:size(distMat,1)
      [tmp idx] = sort(distMat(n,:),'ascend');
      knnGraphTbl(n,:) = idx(2:2+num_k-1);
      for l = 1:1:num_k
         knnGraph_bin(n, knnGraphTbl(n,l)) = 1;
         knnGraph_wtd(n, knnGraphTbl(n,l)) = distMat(n,knnGraphTbl(n,l));

      end
   end

   % remove outliers in knn graph to find densely connected subgraphs
   % first remove non-reciprocal connections
   %
   % TODO: remove outlier arc lengths;
   %
   % See excerpt from paper listed above:
   %   "[...] and the length of the arc is an out-lier of its own distribution
   %    (i.e. if its length is larger than the 3rd quartile plus 1.5 times
   %    the inter-quartile distance of the distribution of the lengths of
   %    all the edges in the graph)." - Baya & Granitto, 2011
   %
   knnGraph_bin = knnGraph_bin;
   knnGraph_wtd = knnGraph_wtd;
   for n = 1:1:size(distMat,1)
      tmp = knnGraphTbl(n,:);
      for l = 1:1:num_k
         if ~ismember(n,knnGraphTbl(tmp(l),:))
             knnGraph_bin(n,tmp(l)) = 0;
             knnGraph_bin(tmp(l),n) = 0;

             knnGraph_wtd(n,tmp(l)) = 0;
             knnGraph_wtd(tmp(l),n) = 0;

         end

      end

   end

   % connect disconnected components of the graph
   %
   % TODO: bound the weights so that distances do not explode?
   %       (see the Baya 2016 paper on PK-D adaptation of PKNNG)
   %
   if nargout <= 3
       return;
   end
   g = graph(knnGraph_wtd);
   knnGraph_wtd_conn = knnGraph_wtd;
   knnGraph_bin_conn = knnGraph_bin;
   bins = conncomp(g);
   nComp = max(bins);

   if nComp > 1
      % Choose normalizer for exponential penalization function
      max_weight = max(max(knnGraph_wtd));
      mean_weight = mean(knnGraph_wtd(tril(knnGraph_wtd) > 0));
      miu = mean_weight;

      % Fully connect all components to each other
      % TODO: add option to minimally connect the components!
      for c = 1:1:nComp
         for d = c+1:1:nComp
            nodes_c = find(bins==c);
            nodes_d = find(bins==d);
            if length(nodes_d) == 1
               [val, best_nodes_c] = min(distMat(nodes_d, nodes_c));
               best_nodes_c = nodes_c(best_nodes_c);% [samir] added this to fix indexing

               knnGraph_wtd_conn(nodes_d, best_nodes_c) = val * exp(val/miu);
               knnGraph_wtd_conn(best_nodes_c, nodes_d) = knnGraph_wtd_conn(nodes_d, best_nodes_c);
               knnGraph_bin_conn(nodes_d, best_nodes_c) = 1;
               knnGraph_bin_conn(best_nodes_c, nodes_d) = 1;
            elseif length(nodes_c) == 1
               [val, best_nodes_d] = min(distMat(nodes_c, nodes_d));
               best_nodes_d = nodes_d(best_nodes_d);

               knnGraph_wtd_conn(nodes_c, best_nodes_d) = val * exp(val/miu);
               knnGraph_wtd_conn(best_nodes_d, nodes_c) = knnGraph_wtd_conn(nodes_c, best_nodes_d);
               knnGraph_bin_conn(nodes_c, best_nodes_d) = 1;
               knnGraph_bin_conn(best_nodes_d, nodes_c) = 1;
            else % find the best pair of nodes between nodes_c and nodes_d that can be connected
               tmp = distMat(nodes_c, nodes_d);
               val = min(tmp(:));
               [nodes_c_min, nodes_d_min] = find(tmp==val);
               nodes_c_min = nodes_c(nodes_c_min);
               nodes_d_min = nodes_d(nodes_d_min);
               knnGraph_wtd_conn(nodes_c_min, nodes_d_min) = val * exp(val/miu);
               knnGraph_wtd_conn(nodes_d_min, nodes_c_min) = knnGraph_wtd_conn(nodes_c_min, nodes_d_min);
               knnGraph_bin_conn(nodes_c_min, nodes_d_min) = 1;
               knnGraph_bin_conn(nodes_d_min, nodes_c_min) = 1;
            end
         end % for d
      end % for c
   end % if

end