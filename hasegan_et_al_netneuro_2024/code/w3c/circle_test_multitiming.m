%{
## Run command locally:

workspace = getenv('WORKSPACE');
datafolder = [workspace, '/results/w3c_sim/mappers_test/'];
cohort_path = [workspace, '/data/w3c_subsampled/cohort.csv'];
timing_base_path = [workspace, '/data/w3c_subsampled/'];
output_dir = [workspace, '/results/w3c_sim/analysis/mappers_test/'];
circle_test_multitiming

## Run the with the following command on Sherlock (on `sdev`)

module load matlab
DATAFOLDER="/scratch/groups/saggar/demapper-w3c/mappers_w3cv5kval_fast.json/"
COHORT_PATH="/scratch/groups/saggar/demapper-w3c/data_subsampled/cohort_1sbj.csv"
OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/analysis/mappers_w3cv5kval_fast.json/"

ARGS="datafolder='${DATAFOLDER}'; cohort_path='${COHORT_PATH}'; output_dir='${OUTPUT_DIR}';"
matlab -r "${ARGS} run('code/w3c/circle_test_multitiming.m')"


%}

if ~exist('datafolder', 'var')
    error('DeMapper:IncorrectSetup', ...
        'Please set up variable datafolder');
end
if ~exist('cohort_path', 'var')
    error('DeMapper:IncorrectSetup', ...
        'Please set up variable cohort_path');
end
if ~exist('output_dir', 'var')
    error('DeMapper:IncorrectSetup', ...
        'Please set up variable output_dir');
end

cohort = readtable(cohort_path, ...
    delimitedTextImportOptions('Delimiter', ',', 'VariableNamesLine', 1, ...
    'DataLines', 2));

task_paths = containers.Map(cohort.('id0'), cohort.('task_path_G'));

task_labels = containers.Map;
uniq_task_paths = unique(cohort.('task_path_G'));
for task_path_id=1:length(uniq_task_paths)
    task_path = uniq_task_paths(task_path_id);
    tp = cell2mat(task_path);
    if exist('timing_base_path', 'var')
        if isempty(fileparts(tp))
            tp = fullfile(timing_base_path, tp);
        else
            tp = replace(tp, fileparts(tp), timing_base_path);
        end
    end
    if ~startsWith(tp, '/')
        % If relative, make absolute w.r.t. cohort path
        data_root = fileparts(cohort_path);
        tp = [data_root, '/', tp];
    end

    timing_table = readtable(tp, 'FileType', 'text', 'Delimiter', ',');
    timing_table.task_name = string(timing_table.task_name);
    timing_labels = timing_table.task_name;
    task_labels(cell2mat(task_path)) = timing_labels;
end

sbjsdirs = dir(datafolder);
sbjs = struct2cell(sbjsdirs); sbjs  = sbjs(1,:);
sbjs = sbjs(startsWith(sbjs , 'SBJ'));
sbjs = sort(sbjs);

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

circle_errors = zeros(length(all_mappers), 2);
circle_errors_all = zeros(length(all_mappers) * length(sbjs), 2);
fprintf('Processing %d mappers...\n', length(all_mappers));
for mid = 1:length(all_mappers)
    mapper_name = cell2mat(all_mappers(mid));
    disp(mapper_name)

    n_sbjs = length(sbjs);
    all_scores = zeros(n_sbjs, 1);
    for sbjid = 1:n_sbjs
        sbj = cell2mat(sbjs(sbjid));

        task_path = task_paths(sbj);
        timing_labels = task_labels(task_path);

        mapper_path = fullfile(datafolder, sbj, mapper_name);
        all_scores(sbjid, 1) = circleloss_score(mapper_path, timing_labels);
        all_scores(sbjid, 2) = transition_betweeness(mapper_path, timing_labels);
    end

    circle_errors(mid, :) = mean(all_scores, 1);
    circle_errors_all((mid-1)*n_sbjs+1:mid*n_sbjs, :) = all_scores;
end
disp('...done')

if ~exist(output_dir, 'dir')
    mkdir(output_dir)
end

varNames = ["Mapper", "CircleLoss", "TransitionBetweeness"];
mappers_table = table(all_mappers', circle_errors(:, 1), circle_errors(:, 2), ...
    'VariableNames', varNames);
output_path = fullfile(output_dir, 'scores.csv');
writetable(mappers_table, output_path);


varNames = ["Mapper", "subject", "CircleLoss", "TransitionBetweeness"];
all_mappers_table = table( ...
    reshape(repmat(all_mappers, length(sbjs), 1), length(circle_errors_all), 1), ...
    reshape(repmat(sbjs, length(all_mappers), 1)', length(circle_errors_all), 1), ...
    circle_errors_all(:,1), ...
    circle_errors_all(:,2), ...
    'VariableNames', varNames);
all_output_path = fullfile(output_dir, 'scores-all.csv');
writetable(all_mappers_table, all_output_path);
