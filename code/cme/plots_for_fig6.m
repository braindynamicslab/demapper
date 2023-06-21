%% Generates the figure 6a
%% Requires set: fn_timing res_path mapper_name
% fn_timing='/Users/dh/workspace/BDL/demapper/data/cme/timing.csv';
% res_path='/Users/dh/workspace/BDL/demapper/results/cme/ch10_mappers_cmev3_disp.json';
% mapper_name='BDLMapper_12_30_60';
% CHANGE_POINTS = 10;


% Get the timing
timing_table = readtable(fn_timing, 'FileType', 'text', 'Delimiter', ',');
timing_table.task_name = string(timing_table.task_name);
timing_labels = timing_table.task_name;
timing_arr = timing_table.task;
timing_changes = find([timing_arr(2:end) - timing_arr(1:end-1); 1]);

% Load Data
% TODO: Get the correct path for figure 4
% res_path = '/Users/dh/workspace/BDL/demapper/results/cme/ch10_mappers_cmev6kval_disp.json';

% Run for all `mapper_name`s as the following:
% DistsGeoBDLMapper_euclidean_12_20_50
% DistsGeoBDLMapper_cityblock_12_20_50
% DistsGeoBDLMapper_chebychev_12_20_50
% DistsGeoBDLMapper_correlation_12_20_50
% DistsBDLMapper_euclidean_20_50
% DistsBDLMapper_correlation_20_50

avg_degs = read_1d([res_path, '/compute_degrees_from_TCM/avgstat_', mapper_name, '.1D']);
chgs = findchangepts(avg_degs, 'MaxNumChanges', CHANGE_POINTS);
output_path = [res_path, '/change-degs_', mapper_name, '.png'];
p_chgs = 0:length(chgs);
plot_degs(avg_degs, timing_labels, timing_changes, chgs, p_chgs, output_path);


%% Helper functions
function plot_degs(degs, timing_labels, timing_changes, chgs, p_chgs, output_path)
    f = figure;
    f.Position = [f.Position(1:2) 1000 100];
    hold on;
    
    for cid = 2:length(timing_changes)
        ch1 = timing_changes(cid-1)+1;
        ch2 = timing_changes(cid);
        assert(strcmp(timing_labels(ch1), timing_labels(ch2)))
        label = timing_labels(ch1);
    
        modulatory = 1;
        col = '';
        switch label 
            case 'instruction'
                continue
            case 'rest'
                col = [0.0352, 0.8828, 0.2383] * modulatory; % 'g'; % green
            case 'math'
                col = [0.6914, 0.1250, 0.1016] * modulatory; % 'r'; % red
            case 'memory'
                col = [0.9531, 0.8398, 0.1641] * modulatory; % 'yellow';
            case 'video'
                col = [0.8984, 0.4805, 0.0625] * modulatory; % orange
        end
    
        patch([ch1 ch2 ch2 ch1], [0 0, 1, 1], col, 'FaceAlpha', .1)
    
%         avg_deg = mean(degs(1, ch1:ch2));
%         plot(ch1:ch2, repmat(avg_deg, ch2-ch1+1, 1), 'black');
    end

    % plot the found changes
    for i=p_chgs
        if i > 0
          xline(chgs(i), '-k', 'LineWidth', 3)
        end
    end
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
        plot([x1,x2], [vs, vs], '--b', 'LineWidth', 2)
    end
    
    plot(1:length(degs), degs, 'black')
    xlim([1,length(degs) * 1.01])
    ylim([0, 1.1])

    saveas(f, output_path);
    close(f);
end

function data = read_1d(data_path)
data_opts = delimitedTextImportOptions('Delimiter', ' ');
data = readmatrix(data_path, data_opts);
data = str2double(data);
end
