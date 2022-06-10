

basefolder  = split(pwd, 'BDL');
basefolder  = [basefolder{1}, 'BDL/mappertoolbox-matlab'];
codefolder  = [basefolder,'/code'];
addpath(genpath(codefolder));

% Get the timing
fn_timing = '/Users/dh/workspace/BDL/demapper/data/cme/input/timing.csv';
timing_table = readtable(fn_timing, 'FileType', 'text', 'Delimiter', ',');
timing_table.task_name = string(timing_table.task_name);
timing_labels = timing_table.task_name;

% Load Data
% data_path = [basefolder, '/tests/fixtures/sub-1_rest1_schaefer400x7_ts.1D'];
% data_path = [basefolder, '/tests/fixtures/sub-1_rest1_schaefer400x7_ts.1D'];
data_path = '/Users/dh/workspace/BDL/bdl-mapper/data-cme-gordon/SBJ01_Gordon333.npy';

data = readNPY(data_path);
% data = readNPY(data_path);
data = drop_nan(data);
data = drop_lowvar(data, 1e-2);
data = zscore(data);

% Setup default mapper
% opts = BDLMapperOpts(32, 30, 60);
% opts = NeuMapperOpts(32, 200, 35);
% opts = KeplerMapperOpts(20, 70, 'euclidean');
% opts.low_mem = false;
% opts.verbose = false;

%% Run mapper normal
opts = BDLMapperOpts(32, 30, 60);
res1 = mapper(data, opts);

outdir1 = '/Users/dh/workspace/BDL/demapper/results/BDLMapperTest-cme/normal';
mkdir(outdir1);
plot_graph(res1, [outdir1, '/plot_graph.png'])
plot_task(res1, timing_table, [outdir1, '/plot_task.png'])
compute_temp(res1, outdir1, true)


%% Run mapper with binarized
opts.rknn_type = 'bin-pen';
res2 = mapper(data, opts);

outdir2 = '/Users/dh/workspace/BDL/demapper/results/BDLMapperTest-cme/bin-pen';
mkdir(outdir2);
plot_graph(res2, [outdir2, '/plot_graph.png'])
plot_task(res2, timing_table, [outdir2, '/plot_task.png'])
compute_temp(res2, outdir2, true)


%% Run mapper with weighted but no inf
opts.rknn_type = 'wtd-pen-noinf';
res3 = mapper(data, opts);

outdir3 = '/Users/dh/workspace/BDL/demapper/results/BDLMapperTest-cme/wtd-pen-noinf';
mkdir(outdir3);
plot_graph(res3, [outdir3, '/plot_graph.png'])
plot_task(res3, timing_table, [outdir3, '/plot_task.png'])
compute_temp(res3, outdir3, true)


%% Run mapper with weighted but no inf
opts = BDLMapperOpts(32, 30, 60);
opts.binning_nsides = 3;
res4 = mapper(data, opts);

outdir4 = '/Users/dh/workspace/BDL/demapper/results/BDLMapperTest-cme/nsides3';
mkdir(outdir4);
plot_graph(res4, [outdir4, '/plot_graph.png'])
plot_task(res4, timing_table, [outdir4, '/plot_task.png'])
compute_temp(res4, outdir4, true)



%% Run mapper with weighted but no inf
opts = BDLMapperOpts(32, 30, 60);
opts.binning_nsides = 6;
res4 = mapper(data, opts);

outdir4 = '/Users/dh/workspace/BDL/demapper/results/BDLMapperTest-cme/nsides6';
mkdir(outdir4);
plot_graph(res4, [outdir4, '/plot_graph.png'])
plot_task(res4, timing_table, [outdir4, '/plot_task.png'])
compute_temp(res4, outdir4, true)

%% end


function res = drop_nan(data)
    drop_trs = all(isnan(data),2);
    data = data(~drop_trs,:);

    % drop nan columns too
    drop_rois = any(isnan(data),1)';
    res = data(:,~drop_rois);
end

function res = drop_lowvar(data, var_th)
    v = var(data);
    lowvar = var_th;
    drop_rois = v(:) < lowvar;
    res = data(:,~drop_rois);
end