%{
## Run command locally:

datafolder = '/Users/dh/workspace/BDL/demapper/data/cme/';
fn_timing = '/Users/dh/workspace/BDL/neurolens/data/data-cme-shine375/timing.csv';
output_dir = '/Users/dh/workspace/BDL/demapper/results/cme/test';
stat_type = 'compute_degrees';
CHANGE_POINTS = 7;
HAS_INSTRUCTIONS=1
deg_analysis_sbjs

## Run the with the following command on Sherlock (on `sdev`)

module load matlab
DATAFOLDER="/scratch/groups/saggar/demapper-cme/mappers_cmev2.json/"
FN_TIMING="/oak/stanford/groups/saggar/data-cme-shine375/timing.csv"
OUTPUT_DIR="/scratch/groups/saggar/demapper-cme/analysis/mappers_cmev2.json/"
STAT_TYPE="degrees_TRs"
CHANGE_POINTS=7
HAS_INSTRUCTIONS=1
ARGS="datafolder='${DATAFOLDER}'; fn_timing='${FN_TIMING}'; output_dir='${OUTPUT_DIR}'; stat_type='${STAT_TYPE}';"
ARGS="$ARGS HAS_INSTRUCTIONS=${HAS_INSTRUCTIONS}; CHANGE_POINTS=${CHANGE_POINTS};"
matlab -r "${ARGS} run('code/cme/deg_analysis_sbjs.m')"


%}

if ~exist('datafolder', 'var')
    error('MapperToolbox:IncorrectSetup', ...
        'Please set up variable datafolder');
end
if ~exist('fn_timing', 'var')
    error('MapperToolbox:IncorrectSetup', ...
        'Please set up variable fn_timing');
end
if ~exist('output_dir', 'var')
    error('MapperToolbox:IncorrectSetup', ...
        'Please set up variable output_dir');
end
if ~exist('stat_type', 'var')
    error('MapperToolbox:IncorrectSetup', ...
        'Please set up variable stat_type');
end
if ~exist('CHANGE_POINTS', 'var')
    CHANGE_POINTS = 7;
end
if ~exist('HAS_INSTRUCTIONS', 'var')
    HAS_INSTRUCTIONS = 1;
end
if ~exist('RERUN_UNCOMPUTED', 'var')
    RERUN_UNCOMPUTED = 0;
end

timing_table = readtable(fn_timing, 'FileType', 'text', 'Delimiter', ',');
timing_table.task_name = string(timing_table.task_name);
timing_labels = timing_table.task_name;
if table_isfield(timing_table, 'task')
    timing_arr = timing_table.task;
else
    timing_arr = get_timing_arr(timing_table.task_name);
end
timing_changes = find([timing_arr(2:end) - timing_arr(1:end-1); 1]);
target_chgs = findchangepts(timing_arr', 'MaxNumChanges', 15);

sbjsdirs = dir(datafolder);
sbjs = struct2cell(sbjsdirs); sbjs  = sbjs (1,:);
sbjs = sbjs(startsWith(sbjs , 'SBJ'));

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

stat_outdir = fullfile(output_dir, stat_type);
if ~exist(stat_outdir, 'dir')
    mkdir(stat_outdir)
end

chpts_errors = zeros(size(all_mappers));
chpts_count = zeros(size(all_mappers));
missing_items = 0;
fprintf('Processing %d mappers...\n', length(all_mappers));
for mid = 1:length(all_mappers)
    mapper_name = cell2mat(all_mappers(mid));
    disp(mapper_name)
    output_path = fullfile(stat_outdir, [mapper_name, '.png']);
    if ~RERUN_UNCOMPUTED || ~isfile(output_path)
        % there is no cached file, so compute it
        if strcmp(stat_type, 'compute_degrees_from_TCM') || strcmp(stat_type, 'compute_degrees_from_rTCM')
            all_TCMs = zeros(length(sbjs), length(timing_arr), length(timing_arr));
            for sbjid = 1:length(sbjs)
                sbj = cell2mat(sbjs(sbjid));            
    
                mapper_path = fullfile(datafolder, sbj, mapper_name);
                datapath = fullfile(mapper_path, 'res.mat');
                if ~isfile(datapath)
                    missing_items = missing_items + 1;
                    continue
                end
                all_TCMs(sbjid, :, :) = process(mapper_path, stat_type);
            end
            avg_tcms = mean(all_TCMs, 1);
            avg_degs = reshape(normalize(sum(avg_tcms, 2), 'range'), 1, length(timing_arr));
        else
            all_degs = zeros(length(sbjs), length(timing_arr));
            for sbjid = 1:length(sbjs)
                sbj = cell2mat(sbjs(sbjid));
        
                mapper_path = fullfile(datafolder, sbj, mapper_name);
                all_degs(sbjid, :) = process(mapper_path, stat_type);
            end
            avg_degs = normalize(mean(all_degs, 1), 'range');
        end
    
    %     avg_degs = mean(all_degs, 1);
        stat_output_path = fullfile(stat_outdir, ['avgstat_', mapper_name, '.1D']);
        write_1d(avg_degs, stat_output_path);

        chgs = findchangepts(avg_degs, 'MaxNumChanges', CHANGE_POINTS);
        plot_degs(avg_degs, timing_labels, timing_changes, chgs, mapper_name, output_path);
    else
        % use the already computed avg_degs
        stat_output_path = fullfile(stat_outdir, ['avgstat_', mapper_name, '.1D']);
        avg_degs = read_1d(stat_output_path);
        chgs = findchangepts(avg_degs, 'MaxNumChanges', CHANGE_POINTS);
    end

    if isempty(chgs)
        chpts_errors(mid) = nan;
    else
        avg_err = chgs_dist(chgs, target_chgs, HAS_INSTRUCTIONS);
        chpts_errors(mid) = avg_err;
    end
    chpts_count(mid) = length(chgs);

end
disp('...done')

varNames = ["Mapper", "ChangePointsIndicesError", "ChangePointsCount"];
mappers_table = table(all_mappers', chpts_errors', chpts_count', ...
    'VariableNames', varNames);
output_path = fullfile(stat_outdir, ['combined-', stat_type, '.csv']);
writetable(mappers_table, output_path);

if missing_items > 0
    disp(['Found ', num2str(missing_items), ' missing items!'])
end


%% Helper functions
function degs = process(mapper_path, stat_type)
    switch stat_type
        case 'compute_degrees'
            datapath = fullfile(mapper_path, 'res.mat');
            res = load(datapath).res;
            
            K = res.memberMat' * ((res.adjacencyMat > 0) + eye(size(res.adjacencyMat)));
            degs = sum(K, 2)';
            % degs = normalize(degs, 'Range');
        case 'compute_degrees_from_TCM'
            datapath = fullfile(mapper_path, 'res.mat');
            res = load(datapath).res;
            
            sim_mat = get_similarity_mat(res.adjacencyMat, res.memberMat);
            degs = normalize(sim_mat, 'Range');
        case 'compute_degrees_from_rTCM'
            datapath = fullfile(mapper_path, 'res.mat');
            res = load(datapath).res;
            
            sim_mat = get_similarity_mat(res.adjacencyMat, res.memberMat);
            degs = rescale(sim_mat);
        case {'betweenness_centrality_TRs_avg', 'betweenness_centrality_TRs_max', ...
                'core_periphery_TRs_avg', 'core_periphery_TRs_max', 'degrees_TRs'}
            datapath = fullfile(mapper_path, ['stats_', stat_type, '.1D']);
            degs = read_1d(datapath);
            % degs = normalize(degs, 'Range');
        otherwise
            error('MapperToolbox:UnrecognizedStatType', ...
                'Please set up a correct value for `stat_type`');
    end
end

function plot_degs(degs, timing_labels, timing_changes, chgs, mapper_name, output_path)
    f = figure;
    f.Position = [f.Position(1:2) 2000 400];
    hold on;
    
    for cid = 2:length(timing_changes)
        ch1 = timing_changes(cid-1)+1;
        ch2 = timing_changes(cid);
        assert(strcmp(timing_labels(ch1), timing_labels(ch2)))
        label = timing_labels(ch1);
    
        col = '';
        switch label 
            case 'instruction'
                continue
            case 'rest'
                col = 'g';
            case 'math'
                col = 'red';
            case 'memory'
                col = 'yellow';
            case 'video'
                col = 'cyan';
        end
    
        patch([ch1 ch2 ch2 ch1], [0 0, 1, 1], col, 'FaceAlpha', .2)
    
        avg_deg = mean(degs(1, ch1:ch2));
        plot(ch1:ch2, repmat(avg_deg, ch2-ch1+1, 1), 'black');
    end

    % plot the found changes
    for ch=chgs
        xline(ch, '--m')
    end
    for i=0:length(chgs)
        x1 = 1;
        x2 = length(degs);
        if i > 0
            x1 = chgs(i);
        end
        if i < length(chgs)
            x2 = chgs(i+1);
        end

        vs = mean(degs(x1:x2));
        plot([x1,x2], [vs, vs], '--m')
    end
    
    plot(1:length(degs), degs, 'blue')
    xlim([1,length(degs) * 1.01])
    title(['TR Degrees for ', mapper_name], 'Interpreter', 'none')

    saveas(f, output_path);
    close(f);
end

function total_err = chgs_dist(chgs, target_chgs, has_instructions)
    total_err = 0;
    if has_instructions
        N = floor(length(target_chgs) / 2);
    else
        N = length(target_chgs);
    end
    for i = 1:N
        if has_instructions
            ch_start = target_chgs(2*i); ch_end = target_chgs(2*i+1);
        else
            ch_start = target_chgs(i); ch_end = target_chgs(i);
        end
        errs = zeros(size(chgs));
        errs(chgs < ch_start) = chgs(chgs < ch_start) * (-1) + ch_start;
        errs(chgs > ch_end) = chgs(chgs > ch_end) - ch_end;
        total_err = total_err + min(errs);
    end
    total_err = total_err / N;
end

function data = read_1d(data_path)
data_opts = delimitedTextImportOptions('Delimiter', ' ');
data = readmatrix(data_path, data_opts);
data = str2double(data);
end

function write_1d(mat_obj, data_path)
writematrix(mat_obj, data_path, 'Delimiter', 'space', 'FileType', 'text')
end

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
%
% Inputs:
%   - nodes_adj: nodes adjacency matrix
%   - node_to_Tp: node to timepoint matrix
% Outputs:
%   - tpmat: matrix of timepoint by timepoint as a similarity metric

if all(diag(nodes_adj) == 0)
  % If adjacency matrix diagonal is 0 then add similarity between TRs of the same node.
  tpmat = node_to_Tp' * (nodes_adj > 0) * node_to_Tp + node_to_Tp' * node_to_Tp;
else
  tpmat = node_to_Tp' * (nodes_adj > 0) * node_to_Tp;
end
tpmat(1:size(tpmat,1)+1:end) = 0;

end
