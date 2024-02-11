function [pts_in_smallBin, bigbin_idx_in_smallBin, eps] = part_cluster_dbscan(...
                    pts_in_bigBin, distMat, eps_type, eps_arg, minpts)
% Function part_cluster_dbscan
% Partial clustering using dbscan

% Notation: Mapper does two binning steps. We give the name "bigBins" to
% the bins produced in the first pass. Each bigBin is then clustered
% further through a partial clustering step. The resulting clusters are
% called "smallBins".

% Inputs: 
% (1) cell array of bigBins containing indices of the data points in
% each bigBin 
% (2) full distance matrix of original space
% (3) eps_type: how to get epsilon to be used for DBSCAN.
%               Possible: 'fixed', 'elbow', 'median'
% (4) eps_arg: if eps_type=='fixed' then its the epsilon value to be used
%              if eps_type=='elbow' or 'median' then it is the k-value used
%              for k-NN.
% (5) minpts: minimum points needed to create clusters with DBSCAN

% Output: cell array of smallBins containing indices of the data points in
% each smallBin. 

% Implementation notes: loop through each bigBin, cluster when possible

num_bigBins = length(pts_in_bigBin);

% The next variable stores, for each bigBin, the indices of the smallBins
% in that bigBin.
indices_smallBins_in_bigBin = cell(num_bigBins,1);

% Initialize list of smallBins
smallBin_index = 0;
pts_in_smallBin= [];
bigbin_idx_in_smallBin = [];

eps = 0;
switch eps_type
    case 'fixed'
        eps = eps_arg;
    case 'elbow'
        eps = findElbowEps(distMat, eps_arg);
    case 'median'
        [~,D]= knnsearch(distMat, distMat, 'k', eps_arg);
        eps = median(D(D>0));
    otherwise
        error('MapperToolbox:part_cluster_dbscan', ...
            'Have to set an Epsilon for DBSCAN');
end

if not(minpts > 1)
    error('MapperToolbox:part_cluster_dbscan', ...
            'Have to set an minpts higher than 1 for DBSCAN');
end


for bin = 1:num_bigBins
% First we use an if statement to figure out how many smallBins will be
% produced from the current bigBin (i.e. how many clusters we will obtain)
% Then we loop over each smallBin to record the indices of the observations
% in the smallBin.
    
    len = length(pts_in_bigBin{bin});
    
    if len == 0
       %fprintf(1,'Level set is empty\n');
       indices_smallBins_in_bigBin{bin} = -1;
       continue;
    elseif len >= minpts
       % get restriction of distance matrix
       bigBin_distMat = distMat(pts_in_bigBin{bin}, pts_in_bigBin{bin});
       
       % perform clustering
       cluster_indices_within_bigBin = dbscan(bigBin_distMat, ...
           eps, minpts, 'Distance','precomputed');
       
       % above returns a list of clusters [1:number of clusters]
       num_smallBins_in_bigBin = max(cluster_indices_within_bigBin);
    else 
       %fprintf(1,'Level set has only 1 pt\n');
       num_smallBins_in_bigBin = len;
       cluster_indices_within_bigBin = 1:len;
    end
   % initialize new smallBins, give them indices relative to the last
   % used index
   indices_smallBins_in_bigBin{bin} = smallBin_index + ...
                                        (1:num_smallBins_in_bigBin);

    for j = 1:num_smallBins_in_bigBin 
    % if the latter was not defined, i.e. we had len==0, then the continue
    % statement passes to the next iteration of the enclosing loop
    
       % iterate counter for each new smallBin
       smallBin_index = smallBin_index + 1;
       pts_in_smallBin{smallBin_index} = pts_in_bigBin{bin}(cluster_indices_within_bigBin==j);
       bigbin_idx_in_smallBin{smallBin_index} = bin;
%      pts_in_smallBin changes size on each iteration, which can likely be 
%      optimized. But this is not immediate because we do not know how many
%      smallBins will be created, a priori.
       
    end
end


end

function eps = findElbowEps(distMat, kvalue)
% Created after Rahmah and Sitanggang 2016

% Do Knn and get the histogram of distances
[~,D]= knnsearch(distMat, distMat, 'k', kvalue);
[N,edges] = histcounts(D(D > 0), 50);

% Create a triangle plot with the 
[~,i] = max(N);
P = (edges(2:end) + edges(1:end-1)) / 2;
X = P(1:i); X = X / max(X);
Y = N(1:i); Y = Y / max(Y);

% projection:
v = [1;1]; V = (v * v') / (v' * v);
proj_d = sum((V * vertcat(X,Y) - vertcat(X,Y)) .^ 2);
proj_v = sum((X-Y) .^ 2);
proj = proj_d - proj_v;
[~, ip] = max(proj);

% % debug:
% figure;
% plot(X, Y);
% plot([0,0], [1,1]);
% plot(X, normalize(proj, 'range'));

eps = P(ip);
end