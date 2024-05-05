%{
## Example command locally:

workspace = getenv('WORKSPACE');
mappers_path = [workspace, '/results/cme_mappers/mappers_cmev6kval_fast.json/SBJ01/'];
output_path = [workspace, '/results/cme_mappers/res.csv'];

## Run the with the following command on Sherlock (on `sdev`)

module load matlab
ARGS=""
ARGS="$ARGS mappers_path='/scratch/groups/saggar/demapper-w3c/mappers_w3cv4_euc_fast.json/SBJ99';"
ARGS="$ARGS output_path='/scratch/groups/saggar/demapper-w3c/analysis/stats_timing_v4_fast.csv';"
matlab -r "${ARGS} run('code/w3c/stats_timing.m')"

%}

mpath = 'res.mat';
mappers = get_mappers(mappers_path);

parForArg = 0;
if exist('poolsize', 'var')
    delete(gcp('nocreate')); % TODO: use gcp if size matches poolsize
    pool = parpool(poolsize);
    parForArg = poolsize;
end

header = {'mapper', 'timing', 'nodes'};
writecell(header, output_path);

parfor (idx1 = 1:length(mappers), parForArg)
    mapper = mappers{idx1};
    path = fullfile(mappers_path, mapper, mpath);
    res = load(path).res;
    timing = res.processing_time;
    nodes = size(res.memberMat, 1);

    M = {mapper, num2str(timing), num2str(nodes)};
    writecell(M, output_path, 'WriteMode', 'append');
end

%% Helper functions
function mappers = get_mappers(mappers_path)
    mappers_dirs = dir(mappers_path);
    names = struct2cell(mappers_dirs); names = names(1,:);
    mappers_ids = cellfun(@(s) ~isempty(s), strfind(names, 'Mapper'));
    mappers = names(mappers_ids);
end
