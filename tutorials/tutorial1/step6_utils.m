%% Compute some general statistics on the computed graph
resdir = './stats'; % results directory
mkdir(resdir);

stats_args = struct; % no extra args needed here.
compute_stats(res, stats_args, resdir);

%% Compute the temporal connectivity matrices
resdir = './tmp'; % results directory
mkdir(resdir);

skip_temp = false; % do not skip saving the matrices
compute_temp(res, resdir, skip_temp);
