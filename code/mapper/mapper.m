function res = mapper(X, options)
% Main function to run the Mapper Algorithm on (time x features) data
% 
% Mapper is running multiple steps, named and defined below as
% transformations on the data:
%
%   input data X
%
%   -> [1] (optional) preprocessing
%
%   -> [2] distance: pair-wise distance calculation
%
%   -> [3] rknn: Reciprocal k-Nearest Neighbors
%
%   -> [4] embed: Embedding into a smaller space
%
%   -> [5] binning: Segmenting the space into bins
%
%   -> [6] clustering: Partial Clustering to group data points into nodes
%
%   -> [7] finalgraph: Create a final graph by adding edges between nodes
%
% Each step is parameterized and configurable through the input options
% argument. A step can be activated if the option named <step>_type
% is not of the value "none". Below we define the options, and the possible
% values that each can take:
% 
% :param X: the data (rows are observations TRs, columns are variables ROIs)
% :type X: 2D matrix
%
% :param options: the struct defining the parameteres to run Mapper. Defined below:
% :type options: struct
%
% :param options.preprocess_type: defines the preprocessing type. Activated if preprocess_type ~= "none".
% :type options.preprocess_type: "none" | "PCA" | "custom"
%
% :param options.preprocess_varexpl: defines the
%   number of dimensions to take (based on target variance to be
%   explained). Used if preprocess_type == "PCA".
% :type options.preprocess_varexpl: number between 50.0 and 100.0
%
% :param options.preprocess_func: custom function to run on data. Used if
%   prereprocess_type == "custom".
% :type options.preprocess_func: function
%
% :param options.dist_type: defines the distance type to be used to
%   compute the pair-wise distances between datapoints. 
%   Common examples: "cityblock", "euclidean", "correlation". For all
%   examples, check MATLAB documentation of "pdist2".
% :type options.dist_type: distance type
%
% :param options.dist_func: custom function to use as pair-wise distance
%   function. Used if dist_type == "custom".
% :type options.dist_func: function
%
% :param options.prelens_type:
%   defines the way to compute the input to the lens function. Either use reciprocal 
%   k-Nearest Neighbor algorithm, or use the original, preprocessed, or distances
%   input data.
%   It uses a reciprocal kNN if lens_type in {"wtd-pen", "bin-pen"}.
% :type options.prelens_type: "dist" | "original" | "preprocessed" | "bin-pen" | "wtd-pen"
%
% :param options.prelens_rknnparam: defines the number of neighbors (k) to use as
%   parameter for the reciprocal kNN algorithm (PKNNG). Used if rknn is the either
%   weighted or binarized penalized algorithm: lens_type in {"wtd-pen", "bin-pen"}.
% :type options.prelens_rknnparam: number
%
% :param options.prelens_rknn_directed: defines if reciprocal kNN constructs a
%   directed (time-based) graph. Used if rknn is the weighted or binarized
%   penalized algorithm: lens_type in {"wtd-pen", "bin-pen"}.
%   [Currently not implemented]
% :type options.prelens_rknn_directed: boolean
%
% :param options.embed_type: defined the embedding
%   algorithm to use to reduce the datapoint space to fewer dimensions.
%   Activated if embed_type ~= "none".
% :type options.embed_type: "none" | "custom" | "MDS" | "CMDS" | "PCA" |
%   "DiffusionMaps" | "ManifoldChart" | "Isomap" | "LLE" | "HessianLLE" |
%   "Laplacian" | "LTSA" | "SNE" | "tSNE" | "UMAP"
%
% :param options.embed_dim: defines the number of dimensions in the final
%   embedding space. Used if embed_type ~= "none" AND embed_type ~= "custom".
% :type options.embed_dim: number
%
% :param options.embed_kparam: defines the k-param if embed_type is one of
%   "Isomap" | "LLE" | "HessianLLE" | "Laplacian" | "LTSA" | "UMAP"
% :type options.embed_kparam: number
%
% :param options.embed_perplexity: defines the perplexity needed for SNE
%   embedding algorithms. Used if emed_type is one of "SNE" | "tSNE".
% :type options.embed_perplexity: number
%
% :param options.embed_func: custom function to use as embedding algorithm.
%   Used if embed_type == "custom".
% :type options.embed_func: function
%
% :param options.embed_postproc: defines the post-processing
%   type. If embed_postproc == "time", then time is added as a dimension
%   for each datapoint.
% :type options.embed_postproc: "identity" | "time"
% 
% :param options.binning_type: defines the binning strategy.
%       If binning_type == "Nd", then the N-dimensional space is segmented
%       based on polygons or hypercubes. This option requires that the
%       embedding step was ran and the space is reduce to N < 9 dimensions.
%       If binning_type == "cball", then the reciprocal kNN graph is
%       segmented into landmarks to construct a cover of the space. This
%       option needs embed_type == "none".
% :type options.binning_type: "Nd" | "cball"
%
% :param options.binning_resolution: defines the resolution of the binning
%   algorithm. For binning_type == "Nd", the resolution is the number of
%   polygons or hypercubes in one dimension. For binning_type == "cball",
%   the resolution is the number of landmarks.
% :type options.binning_resolution: number
%
% :param options.binning_gain: defines the percentage 
%   of overlap of the bins.
% :type options.binning_gain: number between 0.0 and 100.0
%
% :param options.binning_nsides: defines the number of sides for the polygon
%   used for binning. If binning_nsides ~= 4, then the input embeded space
%   needs to have exactly 2 dimensions. 
% :type options.binning_nsides: number
%
% :param options.clustering_type: defines
%   the clustering algorithm. This step is activated if clustering_type ~=
%   "none".
% :type options.clustering_type: "none" | "custom" | "DBSCAN" | "linkage"
%
% :param options.clustering_linkage: defines the
%   linkage used the clustering algorithm. Used if clustering_type ==
%   "linkage".
% :type options.clustering_linkage: "average" | "complete" | "single"
%
% :param options.clustering_histo_bins: defines the number of histogram bins
%   to be used by the clustering algorithm. Used if clustering_type ==
%   "linkage".
% :type options.clustering_histo_bins: number
%
% :param options.clustering_eps_type: defines how to compute the epsilon used by
%   the DBSCAN clustering algorithm. Used if clustering_type == "DBSCAN". 
%   Options: 'fixed' for a fixed value; 'elbow' for getting epsilon based on elbow 
%   method of kNN distances; 'median' for getting epsilon based on the median of
%   kNN distances
% :type options.clustering_eps_type: string
%
% :param options.clustering_eps_arg: defines the argument used for getting and epsilon
%   used by the DBSCAN clustering algorithm. Used if clustering_type == "DBSCAN".
%   if clustering_eps_type == 'fixed', then it represents the epsilon value to be used.
%   if clustering_eps_type == 'elbow' or 'median', then it represents the
%   knn value used for finding a knn value.
% :type options.clustering_eps_arg: number
%
% :param options.clustering_minpts: defined the minimum points to be taken
%   for a cluster. Used if clustering_type == "DBSCAN"
% :type options.clustering_minpts: number
%
% :param options.clustering_func: custom function to use as clustering 
%   algorithm. Used if clustering_type == "custom".
% :type options.clustering_func: function
%
% :param options.finalgraph_type: defines the construction of
%   the final output graph. If finalgraph_type == "neighbors", then the
%   edges added are restricted to neighbors. 
% :type options.finalgraph_type: "full" | "neighbors"
%
% :param options.verbose: print runtime debugging comments if verbose ==
%   true. Defaults to false.
% :type options.verbose: boolean
%
% :param options.low_mem: return all intermediary steps as part of the
%   output, if low_mem == false. Defaults to true.
% :type options.low_mem: boolean
%
% 
% :returns res: a struct containing the resulting Mapper Graph
%
%       - adjacencyMat: (nodes x nodes) links between Mapper nodes
%
%       - memberMat: (nodes x TRs) logical matrix if node contains TR
%
%       - nodeMembers: (nodes x list<TRs>) cell list for the TRs of each node
%
%       - options: a struct of options used to generate the results
%
%
% ----------------------------------------------------------------------
% :Authors:
%   - Daniel Hasegan
%   - Samir Chowdhury
%   - Caleb Geniesse
%   - Manish Saggar
%

%% Obtain options. If a parameter is missing, switch to a default value.
low_mem     = getoptions(options,'low_mem',true);
verbose     = getoptions(options,'verbose',false);

% 1: Options for preprocessing / Data alignment
preprocess         = getoptions(options,'preprocess_type','none');
preprocess_varexpl = getoptions(options,'preprocess_varexpl', nan);
preprocess_func    = getoptions(options,'preprocess_func', nan);

% 2: Options for Distance Matrix
dist_type    = getoptions(options,'dist_type','euclidean');
dist_func    = getoptions(options,'dist_func', nan);

% 3: Options for prelens type
prelens_type          = getoptions(options,'prelens_type', 'dist');
prelens_rknnparam     = getoptions(options,'prelens_rknnparam', nan); % for r-knn graph construction
prelens_rknn_directed = getoptions(options,'prelens_rknn_directed',false);

% 4: Options for creating embedding
embed_type          = getoptions(options,'embed_type','none');
embed_dim           = getoptions(options,'embed_dim',nan);
embed_kparam        = getoptions(options,'embed_kparam',nan);
embed_perplexity    = getoptions(options,'embed_perplexity',nan);
embed_func          = getoptions(options,'embed_func',nan);
embed_postproc      = getoptions(options,'embed_postproc','identity');

% 5: Options for binning
binning_type        = getoptions(options,'binning_type','Nd');
binning_resolution  = getoptions(options,'binning_resolution',nan);
binning_gain        = getoptions(options,'binning_gain',nan);
binning_nsides      = getoptions(options,'binning_nsides',4);

% 6: Options for clustering
clustering_type         = getoptions(options,'clustering_type','none');
clustering_linkage      = getoptions(options,'clustering_linkage','single');
clustering_histo_bins   = getoptions(options,'clustering_histo_bins',nan);
clustering_eps_type     = getoptions(options,'clustering_eps_type','fixed');
clustering_eps_arg      = getoptions(options,'clustering_eps_arg',nan);
clustering_minpts       = getoptions(options,'clustering_minpts',nan);
clustering_func         = getoptions(options,'clustering_func',nan);

% 7: Options for graph construction
finalgraph_type         = getoptions(options,'finalgraph_type','full');

% 8: Write results in res
res = struct;
res.options = options;

%% [1] Data Alignment
% Output: a preprocessed version of X, with dim_init

switch preprocess
        
    case 'none'
        if verbose; fprintf(1,'No preprocessing \n'); end
        preprocessed_X = X;
        
    case 'PCA'
        if verbose; fprintf(1,'Performing PCA \n'); end
        [preprocessed_X, mapping] = compute_mapping(X, 'PCA', size(X,2));
        dims = find(cumsum(mapping.lambda) ./ sum(mapping.lambda) > preprocess_varexpl / 100.0, 1);
        preprocessed_X = preprocessed_X(:, 1:dims);

    case 'custom'
        if verbose; fprintf(1,'Performing custom preprocessing \n'); end
        preprocessed_X = preprocess_func(X);
        
    otherwise
        error('Did not recognize preprocessing method!')
end

if verbose; fprintf(1,'After preprocessing (dims = %d) \n', size(preprocessed_X,2)); end

%% [2] Distance matrix
% Obtain metric at the data level
% Output: distance matrix dX on original data space, eventually 
% used for partial clustering
if strcmp(dist_type, 'custom')
    distances_X = dist_func(preprocessed_X);
else
    distances_X = compute_distance_matrix(preprocessed_X, dist_type);
end
if verbose; fprintf(1,'Distances computed with %s .\n', dist_type); end


%% [3] Run reciprocal KNN of different types
% Output: prelens_X
switch prelens_type
    case 'original'
        if verbose; fprintf(1,'rknn: No Reciprocal-KNN, using original input \n'); end
        prelens_X = X;

    case 'preprocessed'
        if verbose; fprintf(1,'rknn: No Reciprocal-KNN, using preprocessed input \n'); end
        prelens_X = preprocessed_X;

    case 'dist'
        if verbose; fprintf(1,'rknn: No Reciprocal-KNN, using distance metric \n'); end
        prelens_X = distances_X;

    case {'bin-pen'}
        if verbose; fprintf(1,'rknn: Reciprocal-KNN with k=%s Binarized \n', prelens_rknnparam); end
        [prelens_X, knn_g] = compute_rknn_prelens(distances_X, prelens_rknnparam, prelens_rknn_directed, true);
        if verbose; fprintf(1,'rknn: Reciprocal-KNN with k=%s Binarized completed \n', prelens_rknnparam); end

    case {'wtd-pen'}
        if verbose; fprintf(1,'rknn: Reciprocal-KNN with k=%s \n', prelens_rknnparam); end
        [prelens_X, knn_g] = compute_rknn_prelens(distances_X, prelens_rknnparam, prelens_rknn_directed);
        if verbose; fprintf(1,'rknn: Reciprocal-KNN with k=%s completed \n', prelens_rknnparam); end
end

%% [4] Embedding / Dimension reduction
% Output: a low dimensional embedding, stored in embed_X
% Output: after embedding postprocessing, stored in embed_postproc_X

switch embed_type
           
    case 'none'
        if verbose; fprintf(1,'No dimension reduction \n'); end
        embed_X = prelens_X;

    case 'custom'
        if verbose; fprintf(1,'Custom dimension reduction \n'); end
        embed_X = embed_func(prelens_X);

    case 'CMDS'
        if verbose; fprintf(1,'Performing CMDS \n'); end
        y = cmdscale(prelens_X);
        embed_X = y(:,1:embed_dim);
        
    case {'MDS', 'PCA', 'LDA', 'ProbPCA', 'FactorAnalysis', 'GPLVM', 'Sammon', 'DiffusionMaps' }
        if verbose; fprintf(1,'Performing %s \n', embed_type); end
        embed_X = compute_mapping(prelens_X,embed_type,embed_dim);
        
%   Methods using k nearest neighbors 
    case {'Isomap', 'LLE', 'HessianLLE', 'Laplacian', 'LTSA'}
        if verbose; fprintf(1,'Performing %s with %d nearest neighbors \n', embed_type, embed_kparam); end
        embed_X = compute_mapping(prelens_X, embed_type, embed_dim, embed_kparam);

%   SNE-type methods
    case 'SNE'
        if verbose; fprintf(1,'Performing stochastic neighborhood embedding with perplexity %d \n',embed_perplexity); end
        embed_X = compute_mapping(prelens_X,embed_type,embed_dim,embed_perplexity);
        
    case 'tSNE'
        if verbose; fprintf(1,'Performing tSNE with perplexity %d \n',embed_perplexity); end
        %embed_X = compute_mapping(prelens_X,embed_type,embed_dim,embed_perplexity);
        embed_X = tsne(prelens_X, [], embed_dim, size(prelens_X,2), embed_perplexity);

%  UMAP 
    case 'UMAP'
        if verbose; fprintf(1,'Performing UMAP with n_neighbors %d \n',embed_kparam); end
        [embed_X, ~] = run_umap(prelens_X, 'verbose', 'text', ...
            'n_components', embed_dim, 'n_neighbors', embed_kparam);

    otherwise
        error('Did not recognize dimension reduction method')
end

if verbose; fprintf(1,'Data has been embedded into %d dimensions \n',embed_dim); end
% Extra postprocessing function after embedding
% Output: a different dimensional projection, stored in embed_postproc_X
switch embed_postproc
    case 'identity'
        if verbose; fprintf(1,'Using identity postprocessing (after embedding) \n'); end
        embed_postproc_X = embed_X;
        
    case 'time'
        if verbose; fprintf(1,'Incorporating time in the embedding \n'); end
        times = linspace(mean(min(embed_X)), mean(max(embed_X)), size(embed_X,1));
        embed_postproc_X = [embed_X, times'];
        
    otherwise
        error('Did not recognize postprocessing function')
end


%% [5] Binning
% Output: pts_in_bigBin
switch binning_type
    case 'Nd'
        if verbose; fprintf(1,'Using Nd binning \n'); end
        [pts_in_bigBin, bigBin_Nd_indices] = compute_Nd_binning(embed_postproc_X, ...
            binning_resolution, binning_gain, binning_nsides);

    case 'cball'
        if verbose; fprintf(1,'Using connected ball mapper with fixed values \n'); end
        memberMat = construct_cover_from_graph(knn_g, ...
            binning_resolution, binning_gain);
        pts_in_bigBin = cellfun(@find,num2cell(memberMat,2),'UniformOutput',false);
        
    otherwise
        error('Did not recognize binning strategy')
end

if verbose; fprintf(1,'Binning stage produced %d bigBins \n', length(pts_in_bigBin)); end

%% [6] Clustering: second pass//partial clustering
% Output: a refined cell array called pts_in_smallBin comprising of bins 
% with indices of observations in each bin
switch clustering_type
    case 'none'
        if verbose; fprintf(1,'No clustering method \n'); end
        pts_in_smallBin = pts_in_bigBin;

    case 'custom'
        if verbose; fprintf(1,'Running custom clustering method \n'); end
        [pts_in_smallBin, bigbin_idx_in_smallBin] = clustering_func(...
            pts_in_bigBin, distances_X);

    case 'DBSCAN'
        if verbose; fprintf(1,'Partial clustering using DBSCAN \n'); end
        [pts_in_smallBin, bigbin_idx_in_smallBin] = part_cluster_dbscan(...
            pts_in_bigBin, distances_X, ...
            clustering_eps_type, clustering_eps_arg, clustering_minpts);

    case 'linkage_histo'
        if verbose; fprintf(1, 'Partial clustering with %s linkage and histograms \n', ...
            clustering_linkage); end
        [pts_in_smallBin, bigbin_idx_in_smallBin] = part_cluster_linkage(...
            pts_in_bigBin, distances_X, clustering_histo_bins, clustering_linkage);

    otherwise
        error('Did not recognize partial clustering method')
end


if verbose; fprintf(1,'Clustering stage produced %d smallBins \n', length(pts_in_smallBin)); end

%% [7] Create membership matrix prior to pruning
memberMat = false(length(pts_in_smallBin),size(prelens_X,1));
for ii = 1:size(memberMat,1)
   memberMat(ii,pts_in_smallBin{ii}) = true; 
end
% Pruned graph creation
% Output: 
% - remove smallBins that are identical
% - create weighted adjacency matrix where weights are proportional to size
% of intersection

switch finalgraph_type
    case 'full'
        if verbose; fprintf(1,'FinalGraph: Connect anything to anything \n'); end
        [adjacencyMat, memberMat, pts_in_smallBin_pruned] = prune_graph_full( ...
            memberMat);

    case 'neighbors'
        if verbose; fprintf(1,'FinalGraph: Connect neighbors only \n'); end
        assert(strcmp(binning_type, 'Nd'), 'FinalGraph: Can only connect neighbors if running Nd binning')


        neighborBins = false(length(pts_in_smallBin),length(pts_in_smallBin));
        for ii = 1:size(neighborBins,1)
            neighborBins(ii,pts_in_smallBin{ii} + length(pts_in_smallBin)) = true;
            for jj = 1:size(neighborBins,1)
                bb_ii = bigbin_idx_in_smallBin{ii};
                bb_jj = bigbin_idx_in_smallBin{jj};
                indices_diff = abs(bigBin_Nd_indices(bb_ii) - bigBin_Nd_indices(bb_jj));
                if sum(indices_diff > 1) == 0
                    neighborBins(ii,jj) = true;
                end
            end
        end

        [adjacencyMat, memberMat, pts_in_smallBin_pruned] = prune_graph_neighbored( ...
            memberMat, neighborBins);

    otherwise
        error('Did not recognize matrix creation method')
end


%% [Z] Start storing all results in a struct
% Output: a struct which contains the dataset name, all mapper parameters
% used in the analysis, as well as outputs in each layer of the mapper
% pipeline. 

res.memberMat = sparse(memberMat);
res.adjacencyMat = adjacencyMat;
res.nodeMembers = pts_in_smallBin_pruned;
if exist('knn_g', 'var')
    res.knn_g = knn_g;
end

if ~low_mem
    % store data matrices
    res.X = X;
    res.preprocessed_X = preprocessed_X;    % After [1]
    res.distances_X = distances_X;          % After [2]
    if exist('knn_g', 'var')
        res.knn_g = knn_g;                  % After [3]
    end
    res.prelens_X = prelens_X;              % After [3]
    res.embed_X = embed_X;                  % After [4]
    if ~strcmp(embed_postproc, 'identity')
        res.embed_postproc_X = embed_postproc_X;
    end
    res.bigBin = pts_in_bigBin;             % After [5]
    if strcmp(binning_type, 'Nd')
        res.bigBin_Nd_indices = bigBin_Nd_indices;              % After [5]
    end
    res.smallBin = pts_in_smallBin;         % After [6]
    if ~strcmp(clustering_type, 'none')
        res.bigbin_idx_in_smallBin = bigbin_idx_in_smallBin;         % After [6]
    end
end

end
