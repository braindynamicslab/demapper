function options = TMapperOpts(k, resolution, gain, verbose)
% Not implemented yet
assert(false, "Not implemented yet")

if nargin < 4
    verbose = false;
end

options = struct;
options.verbose=verbose;
options.preprocess_type = 'none';
options.dist_type = 'euclidean';
options.prelens_type = 'wtd-pen';
options.prelens_rknnparam = k;
options.prelens_rknn_directed = true;
options.embed_type = 'CMDS';
options.embed_dim = 2;
options.binning_type = 'Nd';
options.binning_resolution = resolution;
options.binning_gain = gain;
options.binning_nsides = 4;
options.clustering_type = 'linkage_histo';
options.clustering_histo_bins = 10;
options.finalgraph_type = 'full';

end