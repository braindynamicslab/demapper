%{
## Run command locally:

datafolder = '/Users/dh/workspace/BDL/demapper/data/cme/';
fn_timing = '/Users/dh/workspace/BDL/neurolens/data/data-cme-shine375/timing.csv';
output_dir = '/Users/dh/workspace/BDL/demapper/results/cme/test';
local = true;
mod_analysis_sbjs

## Run the with the following command on Sherlock (on `sdev`)

module load matlab
DATAFOLDER="/scratch/groups/saggar/demapper-cme/mappers_cmev3.json/"
FN_TIMING="/oak/stanford/groups/saggar/data-cme-shine375/timing.csv"
OUTPUT_DIR="/scratch/groups/saggar/demapper-cme/analysis/mappers_cmev3.json/"
ARGS="datafolder='${DATAFOLDER}'; fn_timing='${FN_TIMING}'; output_dir='${OUTPUT_DIR}';"
matlab -r "${ARGS} run('code/cme/mod_analysis_sbjs.m')"


%}

if ~exist('datafolder', 'var')
    error('DeMapper:IncorrectSetup', ...
        'Please set up variable datafolder');
end
if ~exist('fn_timing', 'var')
    error('DeMapper:IncorrectSetup', ...
        'Please set up variable fn_timing');
end
if ~exist('output_dir', 'var')
    error('DeMapper:IncorrectSetup', ...
        'Please set up variable output_dir');
end

timing_table = readtable(fn_timing, 'FileType', 'text', 'Delimiter', ',');
timing_table.task_name = string(timing_table.task_name);
timing_labels = timing_table.task_name;
if table_isfield(timing_table, 'task')
    timing_arr = timing_table.task;
else
    timing_arr = get_timing_arr(timing_table.task_name);
end

sbjsdirs = dir(datafolder);
sbjs = struct2cell(sbjsdirs); sbjs  = sbjs (1,:);
sbjs = sbjs(startsWith(sbjs , 'SBJ'));
if exist('local', 'var') && local
    sbjs = [sbjs, sbjs]; % This is a hack to replicate the production dataset
    % where there are more than 1 subject
end

all_mappers = {};

disp('Extracting mappers...')
for sbjid = 1:length(sbjs)
    sbj = cell2mat(sbjs(sbjid));
    disp(sbj)

    mappers_dirs = dir(fullfile(datafolder, sbj));
    names = struct2cell(mappers_dirs); names = names(1,:);
    mappers_ids = cellfun(@(s) ~isempty(s), strfind(names, 'Mapper'));
    mappers = names(mappers_ids);
    if isempty(all_mappers)
        all_mappers = mappers;
    else
        new_mappers = intersect(mappers, all_mappers);
        if length(mappers) > length(new_mappers)
            disp(['Missing from ', num2str(sbjid), ': ', sbj])
            disp(setdiff(mappers, new_mappers))
        end
        if length(all_mappers) > length(new_mappers)
            disp(['Extra in ', num2str(sbjid), ': ', sbj])
            disp(setdiff(all_mappers, new_mappers))
        end
        all_mappers = new_mappers;
    end
end
disp('...done')


nr_nodes = zeros(length(all_mappers), length(sbjs));
calmod_nodes = zeros(length(all_mappers), length(sbjs));
calmod_trs = zeros(length(all_mappers), length(sbjs));
fprintf('Processing %d mappers...\n', length(all_mappers));
for mid = 1:length(all_mappers)
    mapper_name = cell2mat(all_mappers(mid));
    disp(mapper_name)

    all_degs = zeros(length(sbjs), length(timing_arr));
    for sbjid = 1:length(sbjs)
        sbj = cell2mat(sbjs(sbjid));

        mapper_path = fullfile(datafolder, sbj, mapper_name);
        datapath = fullfile(mapper_path, 'res.mat');
        res = load(datapath).res;

        hh = graph(res.adjacencyMat > 0);
        % mask components to keep
        [comps, comp_sizes] = get_graph_components(hh);
        [B, I] = maxk(comp_sizes, 1);
        idx_maxcc = comps == I;
        sg = subgraph(hh,idx_maxcc);
        maxMemberMat = res.memberMat(idx_maxcc,:);
        % winner takes all voting for each smallBin
        vote = @(v) mode(timing_arr(v));
        m0 = cellfun(vote,num2cell(maxMemberMat,2));
        % calculate modularity
        calmod_nodes(mid, sbjid) = calMod(sg.adjacency,m0);
        nr_nodes(mid, sbjid) = max(comp_sizes);

        % calculate modularity for TRs
        sim_mat = get_similarity_mat(sg.adjacency, maxMemberMat);
        sim_g = graph(sim_mat);
        calmod_trs(mid, sbjid) = calMod(sim_g.adjacency, timing_arr);
    end
end
disp('...done')

varNames = ["Mapper", "NrNodes-mean", "NrNodes-std", ...
    "CalModNodes-mean", "CalModNodes-std", ...
    "CalModTRs-mean", "CalModTRs-std"];
mappers_table = table(all_mappers', mean(nr_nodes, 2), std(nr_nodes, [], 2), ...
    mean(calmod_nodes, 2), std(calmod_nodes, [], 2), ...
    mean(calmod_trs, 2), std(calmod_trs, [], 2), ...
    'VariableNames', varNames);
output_path = fullfile(output_dir, 'modularity-avg.csv');
writetable(mappers_table, output_path);

inds = combvec(1:length(all_mappers), 1:length(sbjs))';
varNames = ["Mapper", "SBJ", "NrNodes", "CalModNodes", "CalModTRs"];
mappers_table = table(all_mappers(inds(:, 1))', sbjs(inds(:, 2))', ...
    reshape(nr_nodes, numel(nr_nodes), 1), ...
    reshape(calmod_nodes, numel(calmod_nodes), 1), ...
    reshape(calmod_trs, numel(calmod_trs), 1), ...
    'VariableNames', varNames);
output_path = fullfile(output_dir, 'modularity.csv');
writetable(mappers_table, output_path);

%% Helper functions

function task_arr = get_timing_arr(task_names)
    task_arr = zeros(size(task_names));
    tasks = unique(task_names);
    for i=1:length(tasks)
        task_arr(task_names == tasks(i)) = i;
    end
end

function b = table_isfield(tbl, f)
    b = sum(ismember(tbl.Properties.VariableNames, f));
end

function tpmat = get_similarity_mat(nodes_adj, node_to_Tp)
% GET_SIMILARITY_MAT create a similarity matrix from Mapper results
if all(diag(nodes_adj) == 0)
  % If adjacency matrix diagonal is 0 then add similarity between TRs of the same node.
  tpmat = node_to_Tp' * (nodes_adj > 0) * node_to_Tp + node_to_Tp' * node_to_Tp;
else
  tpmat = node_to_Tp' * (nodes_adj > 0) * node_to_Tp;
end
tpmat(1:size(tpmat,1)+1:end) = 0;

end


function [comps,comp_sizes] = get_graph_components(hh)
comps = hh.conncomp;
comp_sizes = arrayfun(@(cc) sum(comps == cc), unique(comps));
end


function mod = calMod(W, m0)
s = sum(sum(W)); % calculate sum of degrees of nodes (assuming symmetric)
if s == 0
   mod = 0;
   % samir: if there are no edges, consider the network to be neither
   % modular nor non-modular
else

   gamma = 1; % scaling parameter

   B   = (W-gamma*(sum(W,2)*sum(W,1))/s)/s; % normalized form of "modularity matrix"

   B = (B+B.')/2;    % symmetrize
   mod = sum(B(bsxfun(@eq, m0, m0'))); %calculate Q score
end
end
