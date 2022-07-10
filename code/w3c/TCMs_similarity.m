%{
## Example command locally:

mappers_path_1 = '/Users/dh/workspace/BDL/demapper/results/cme_mappers/mappers_cmev6kval_fast.json/SBJ01/';
mappers_path_2 = '/Users/dh/workspace/BDL/demapper/results/cme_mappers/mappers_cmev6kval_fast.json/SBJ19/';
output_path = '/Users/dh/workspace/BDL/demapper/results/cme_mappers/res.csv';

## Run the with the following command on Sherlock (on `sdev`)

module load matlab
ARGS=""
ARGS="$ARGS mappers_path_1='/scratch/groups/saggar/demapper-w3c/mappers_w3cv3_fast.json/SBJ99';"
ARGS="$ARGS mappers_sel_1='/scratch/groups/saggar/demapper-w3c/mappers_w3cv3_fast.json/fewer_mappers.txt';"
ARGS="$ARGS mappers_path_2='/scratch/groups/saggar/demapper-w3c/mappers_w3cv4_euc_fast.json/SBJ99';"
ARGS="$ARGS mappers_sel_2='/scratch/groups/saggar/demapper-w3c/mappers_w3cv4_euc_fast.json/fewer_mappers.txt';"
ARGS="$ARGS output_path='/scratch/groups/saggar/demapper-w3c/analysis/v3_vs_v4_fast_TCM_sim.csv';"
ARGS="$ARGS poolsize=8;"
matlab -r "${ARGS} run('code/w3c/TCMs_similarity.m')"

%}

mpath = 'compute_temp-TCM-mat.1D';

mappers1 = get_mappers(mappers_path_1);
mappers2 = get_mappers(mappers_path_2);
if exist('mappers_sel_1', 'var')
    mappers1 = read_list(mappers_sel_1)';
end
if exist('mappers_sel_2', 'var')
    mappers2 = read_list(mappers_sel_2)';
end
if exist('compute_half', 'var')
    compute_half = 1;
else
    compute_half = 0;
end

parForArg = 0;
if exist('poolsize', 'var')
    delete(gcp('nocreate')); % TODO: use gcp if size matches poolsize
    pool = parpool(poolsize);
    parForArg = poolsize;
end

header = {'mapper1', 'mapper2', 'L1', 'L2'};
writecell(header, output_path);

parfor (idx1 = 1:length(mappers1), parForArg)
    mapper1 = mappers1{idx1};
    path1 = fullfile(mappers_path_1, mapper1, mpath);
    tcm1 = rescale(read_1d(path1));
    mask = tril(ones(size(tcm1)), -1);
    vals1 = tcm1(logical(mask)); 

    for idx2 = 1:length(mappers2)
        if compute_half
            if idx1 <= idx2
                continue
            end
        end
        mapper2 = mappers2{idx2};
        path2 = fullfile(mappers_path_2, mapper2, mpath);
        
        tcm2 = rescale(read_1d(path2));
        vals2 = tcm2(logical(mask));
        L1 = sum(abs(vals1 - vals2));
        L2 = sqrt(sum((vals1 - vals2) .^ 2));
    
        M = {mapper1, mapper2, num2str(L1), num2str(L2)};
        writecell(M, output_path, 'WriteMode', 'append');
    end
end

%% Helper functions
function data = read_1d(data_path)
data_opts = delimitedTextImportOptions('Delimiter', ' ');
data = readmatrix(data_path, data_opts);
data = str2double(data);
end

function mappers = get_mappers(mappers_path)
    mappers_dirs = dir(mappers_path);
    names = struct2cell(mappers_dirs); names = names(1,:);
    mappers_ids = cellfun(@(s) ~isempty(s), strfind(names, 'Mapper'));
    mappers = names(mappers_ids);
end

function names = read_list(path)
data_opts = delimitedTextImportOptions('Delimiter', ' ');
names = readmatrix(path, data_opts);
end