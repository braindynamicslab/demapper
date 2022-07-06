

basefolder  = split(pwd, 'BDL');
basefolder  = [basefolder{1}, 'BDL/mappertoolbox-matlab'];
codefolder  = [basefolder,'/code'];
addpath(genpath(codefolder));

% Get the timing
fn_timing = '/Users/dh/workspace/BDL/demapper/data/cme/input/timing.csv';
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

% Load Data
res_path = '/Users/dh/workspace/BDL/demapper/results/cme/ch10_mappers_cmev3_fast.json/BDLMapper_16_25_60';
res = load([res_path, '/res.mat']).res;

%%  % Plot Mapper stuff
% plot_task(res, timing_table, [res_path, '/plot_task.png'])
% compute_temp(res, res_path, true)

% TCM_output_path = [res_path, '/compute_temp-TCM.png'];
% TCM = get_similarity_mat(res.adjacencyMat, res.memberMat);
% TCM = normalize(TCM, 'range');
% f = figure('visible', 'off');
% imagesc(TCM);
% colorbar;
% saveas(f, TCM_output_path);
% close(f);

avg_degs = read_1d([res_path, '/avgstat_BDLMapper_16_25_60.1D']);
CHANGE_POINTS = 10;
chgs = findchangepts(avg_degs, 'MaxNumChanges', CHANGE_POINTS);
output_path = [res_path, '/change-degs.png'];

%     p_chgs = 0:length(chgs);
p_chgs = [0, 1, 3, 5, 7, 8, 9, 10];
plot_degs(avg_degs, timing_labels, timing_changes, chgs, p_chgs, output_path);


%% Helper functions
function plot_degs(degs, timing_labels, timing_changes, chgs, p_chgs, output_path)
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
                col = 'yellow';
            case 'math'
                col = [1.0 .1 1.0];
            case 'memory'
                col = 'green';
            case 'video'
                col = [0 .3 1];
        end
    
        patch([ch1 ch2 ch2 ch1], [0 0, 1, 1], col, 'FaceAlpha', .2)
    
%         avg_deg = mean(degs(1, ch1:ch2));
%         plot(ch1:ch2, repmat(avg_deg, ch2-ch1+1, 1), 'black');
    end

    % plot the found changes
%     for ch=p_chgs
%         xline(ch, '--m')
%     end
    for i=p_chgs
        x1 = 1;
        x2 = length(degs);
        if i > 0
            x1 = chgs(i);
        end
        if i < length(chgs)
            x2 = chgs(i+1);
        end

        vs = mean(degs(x1:x2));
        plot([x1,x2], [vs, vs], '--r', 'LineWidth', 2)
    end
    
    plot(1:length(degs), degs, 'black')
    xlim([1,length(degs) * 1.01])
%     title(['TR Degrees for ', mapper_name], 'Interpreter', 'none')

    saveas(f, output_path);
    close(f);
end

function data = read_1d(data_path)
data_opts = delimitedTextImportOptions('Delimiter', ' ');
data = readmatrix(data_path, data_opts);
data = str2double(data);
end

function b = table_isfield(tbl, f)
    b = sum(ismember(tbl.Properties.VariableNames, f));
end