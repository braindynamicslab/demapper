% zscore the data before running Mapper
data = zscore(data);

% Generate simple Mapper options. k=6, resolution=5, gain=30
opts = BDLMapperOpts(6, 5, 30);

% Run the Mapper algorithm
res = mapper(data, opts);
