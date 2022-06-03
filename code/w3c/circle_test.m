%{
## Run command locally:

datafolder = '/Users/dh/workspace/BDL/demapper/results/w3c_sim/mappers_test/';
fn_timing = '/Users/dh/workspace/BDL/demapper/data/w3c/task_info.csv';
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

circle_errors = zeros(length(all_mappers), 2);
circle_errors_all = zeros(length(all_mappers) * length(sbjs), 2);
fprintf('Processing %d mappers...\n', length(all_mappers));
for mid = 1:length(all_mappers)
    mapper_name = cell2mat(all_mappers(mid));
    disp(mapper_name)

    n_sbjs = length(sbjs);
    all_scores = zeros(n_sbjs, 1);
    for sbjid = 1:length(sbjs)
        sbj = cell2mat(sbjs(sbjid));

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