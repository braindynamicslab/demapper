function options = KeplerMapperOpts(resolution, gain, dist_type, eps_kvalue, verbose)

if nargin < 3
    dist_type = 'euclidean';
end

if nargin < 4
    eps_kvalue = 50;
end

if nargin < 5
    verbose = false;
end

options = struct;
options.verbose=verbose;
options.preprocess_type = 'none';
options.dist_type = dist_type;
options.prelens_type = 'preprocessed';
options.embed_type = 'tSNE';
options.embed_dim = 2;
options.embed_perplexity = 50;
options.binning_type = 'Nd';
options.binning_resolution = resolution;
options.binning_gain = gain;
options.binning_nsides = 4;
options.clustering_type = 'DBSCAN';
options.clustering_eps_type = 'median';
options.clustering_eps_arg = eps_kvalue;
options.clustering_minpts = 2;
options.finalgraph_type = 'neighbors';

end
