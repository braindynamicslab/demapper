%{
Run the with the following command on Sherlock

module load matlab
DATAFOLDER="/scratch/groups/saggar/demapper-cme/mappers_cmev2.json/"
FN_TIMING="/oak/stanford/groups/saggar/data-cme-shine375/timing.csv"
OUTPUT_DIR="/scratch/groups/saggar/demapper-cme/analysis/mappers_cmev2.json/"
ARGS="datafolder='${DATAFOLDER}'; fn_timing='${FN_TIMING}'; output_dir='${OUTPUT_DIR}';"
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

timing_table = readtable(fn_timing, 'FileType', 'text');
timing_table.run_name = string(timing_table.run_name);
timing_table.task_name = string(timing_table.task_name);
timing_labels = timing_table.task_name;
timing_arr = timing_table.task;
timing_changes = find([timing_arr(2:end) - timing_arr(1:end-1); 1]);

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

fprintf('Processing %d mappers...', length(all_mappers));
for mid = 1:length(all_mappers)
    mapper_name = cell2mat(all_mappers(mid));
    disp(mapper_name)

    all_degs = zeros(length(sbjs), length(timing_arr));
    for sbjid = 1:length(sbjs)
        sbj = sbjs(sbjid);

        mapper_path = fullfile(datafolder, sbjd, mapper_name, 'res.mat');
        all_degs(sbjid, :) = process(mapper_path);
    end

    avg_degs = mean(all_degs, 1);
    output_path = fullfile(output_dir, [mapper_name, '.png']);
    plot_degs(avg_degs, timing_labels, timing_changes, mapper_name);
end
disp('...done')


%% Helper functions
function degs = process(datapath)
    res = load(datapath).res;
    
    K = res.memberMat' * (res.adjacencyMat > 0);
    degs = sum(K, 2)';
    degs = normalize(degs, 'Range');
end

function plot_degs(degs, timing_labels, timing_changes, mapper_name, output_path)
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
    
    plot(1:length(degs), degs, 'blue')
    xlim([1,length(degs) * 1.01])
    title(['TR Degrees for ', mapper_name], 'Interpreter', 'none')

    saveas(f, output_path);
    close(f);
end