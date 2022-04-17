%{
## Run command locally:

datafolder = '/Users/dh/workspace/BDL/demapper/results/w3c_sim/mappers_test/';
fn_timing = '/Users/dh/workspace/BDL/demapper/data/w3c_sim/task_info.csv';
output_dir = '/Users/dh/workspace/BDL/demapper/results/w3c_sim/analysis/mappers_test/';
circle_test

## Run the with the following command on Sherlock (on `sdev`)

module load matlab
DATAFOLDER="/scratch/groups/saggar/demapper-w3c/mappers_w3cv2.json/"
FN_TIMING="/scratch/groups/saggar/demapper-w3c/data/task_info.csv"
OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/analysis/mappers_w3cv2.json/"

ARGS="datafolder='${DATAFOLDER}'; fn_timing='${FN_TIMING}'; output_dir='${OUTPUT_DIR}';"
matlab -r "${ARGS} run('code/w3c/circle_test.m')"


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

circle_errors = zeros(size(all_mappers));
circle_errors_all = zeros(length(all_mappers) * length(sbjs), 1);
fprintf('Processing %d mappers...\n', length(all_mappers));
for mid = 1:length(all_mappers)
    mapper_name = cell2mat(all_mappers(mid));
    disp(mapper_name)

    n_sbjs = length(sbjs);
    all_scores = zeros(n_sbjs, 1);
    for sbjid = 1:length(sbjs)
        sbj = cell2mat(sbjs(sbjid));

        mapper_path = fullfile(datafolder, sbj, mapper_name);
        all_scores(sbjid, 1) = process(mapper_path, timing_labels);
    end

    circle_errors(mid) = mean(all_scores, 1);
    circle_errors_all((mid-1)*n_sbjs+1:mid*n_sbjs) = all_scores;
end
disp('...done')

if ~exist(output_dir, 'dir')
    mkdir(output_dir)
end

varNames = ["Mapper", "CircleLoss"];
mappers_table = table(all_mappers', circle_errors', ...
    'VariableNames', varNames);
output_path = fullfile(output_dir, 'scores.csv');
writetable(mappers_table, output_path);

varNames = ["Mapper", "subject", "CircleLoss"];
all_mappers_table = table( ...
    reshape(repmat(all_mappers, length(sbjs), 1), length(circle_errors_all), 1), ...
    reshape(repmat(sbjs, length(all_mappers), 1)', length(circle_errors_all), 1), ...
    circle_errors_all, ...
    'VariableNames', varNames);
all_output_path = fullfile(output_dir, 'scores-all.csv');
writetable(all_mappers_table, all_output_path);


%% Helper functions
function score = process(mapper_path, tr_names)
    datapath = fullfile(mapper_path, 'res.mat');
    res = load(datapath).res;

    % Really process
    mm = res.memberMat;

    trs_low = strcmp(tr_names, 'low');
    trs_tplus = strcmp(tr_names, 'trans_plus');
    trs_up = strcmp(tr_names, 'up');
    trs_tmin = strcmp(tr_names, 'trans_minus');
    
    n_low = mm * trs_low > 0; % all nodes that contain low
    n_up = mm * trs_up > 0; % all nodes that contain up
    
    % all nodes that contain only trans_minus or trans_plus
    nonly_tmin = (mm * trs_tmin > 0) & (mm * (1-trs_tmin) == 0);
    nonly_tplus = (mm * trs_tplus > 0) & (mm * (1-trs_tplus) == 0);
    assert(sum(nonly_tmin) > 0)
    assert(sum(nonly_tplus) > 0)
    
    g = graph(res.adjacencyMat); D = g.distances;
    score_tmin = min(abs(mean(D(nonly_tmin, n_low), 2) - mean(D(nonly_tmin, n_up), 2)));
    score_tplus = min(abs(mean(D(nonly_tplus, n_low), 2) - mean(D(nonly_tplus, n_up), 2)));
    score = score_tplus + score_tmin;
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