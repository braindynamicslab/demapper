function options = ExBinNS3MapperOpts(k, resolution, gain, verbose)

if nargin < 4
    verbose = false;
end

options = struct;
options.verbose=verbose;
options.preprocess_type = 'none';
options.dist_type = 'euclidean';
options.prelens_type = 'bin-pen';
options.prelens_rknnparam = k;
options.embed_type = 'CMDS';
options.embed_dim = 2;
options.binning_type = 'Nd';
options.binning_resolution = resolution;
options.binning_gain = gain;
options.binning_nsides = 3;
options.clustering_type = 'linkage_histo';
options.clustering_histo_bins = 10;
options.finalgraph_type = 'full';

end