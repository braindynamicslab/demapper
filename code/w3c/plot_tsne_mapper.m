

basefolder  = split(pwd, 'BDL');
basefolder  = [basefolder{1}, 'BDL/mappertoolbox-matlab'];
codefolder  = [basefolder,'/code'];
addpath(genpath(codefolder));

% Get the timing
fn_timing = '/Users/dh/workspace/BDL/demapper/data/w3c/task_info.csv';
timing_table = readtable(fn_timing, 'FileType', 'text', 'Delimiter', ',');
timing_table.task_name = string(timing_table.task_name);
timing_labels = timing_table.task_name;

% Load Data
% data_path = [basefolder, '/tests/fixtures/sub-1_rest1_schaefer400x7_ts.1D'];
% data_path = [basefolder, '/tests/fixtures/sub-1_rest1_schaefer400x7_ts.1D'];
% data_path = '/Users/dh/workspace/BDL/bdl-mapper/data-cme-gordon/SBJ01_Gordon333.npy';
data_path = '/Users/dh/workspace/BDL/demapper/data/w3c/w3c_simulated_bold.npy';

data = readNPY(data_path);
% data = readNPY(data_path);
data = zscore(data);

% Setup default mapper
% opts = BDLMapperOpts(6, 10, 60);
opts = BDLMapperOpts(6, 10, 70);
opts.low_mem = false;
opts.verbose = false;
% 
% outdir1 = '/Users/dh/workspace/BDL/demapper/results/BDLMapperTest-w3c/tSNE/';
% opts.embed_type = 'tSNE';
% opts.dist_type = 'cosine';
% opts.prelens_type = 'preprocessed';
% opts.embed_perplexity = 3;
% 
% res = mapper(data, opts);
% 
% plot_task(res, timing_table, [outdir1, 'plot_task-diffparams-tSNE_', ...
%     opts.dist_type, '_-', ...
%     num2str(opts.embed_perplexity), '_', opts.prelens_type, '.png'], true)


outdir1 = '/Users/dh/workspace/BDL/demapper/results/BDLMapperTest-w3c/tSNE_v2/';


for prelens = {'wtd-pen', 'preprocessed', 'dist'}
    for perp=[2,3, 6, 10, 20]
        for dist_type = {'cityblock', 'cosine', 'correlation', 'chebychev', 'euclidean'}
            opts.embed_type = 'tSNE';
            opts.prelens_type = cell2mat(prelens);
            opts.dist_type = cell2mat(dist_type);
            opts.embed_perplexity = perp;
            
            res = mapper(data, opts);
            
            plot_task(res, timing_table, [outdir1, 'plot_task-tSNE_', opts.dist_type, '_-', ...
                num2str(opts.embed_perplexity), '_', opts.prelens_type, '.png'], true)
        end
    end
end
