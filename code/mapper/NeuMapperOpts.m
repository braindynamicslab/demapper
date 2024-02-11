function options = NeuMapperOpts(k, resolution, gain, verbose)

if nargin < 4
    verbose = false;
end

options = struct;
options.verbose=verbose;
options.preprocess_type = 'none';
options.dist_type = 'cityblock';
options.prelens_type = 'wtd-pen';
options.prelens_rknnparam = k;
options.embed_type = 'none';
options.binning_type = 'cball';
options.binning_resolution = resolution;
options.binning_gain = gain;
options.clustering_type = 'linkage_histo';
options.clustering_histo_bins = 10;
options.finalgraph_type = 'full';


end