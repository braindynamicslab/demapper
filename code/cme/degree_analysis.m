projfolder  = split(pwd, 'demapper');
basefolder  = [projfolder{1}, 'demapper'];
% codefolder  = [basefolder,'/sim'];
% addpath(genpath(codefolder));


BCTfolder  = [projfolder{1},'neurolens/code/neumapper/BCT'];
addpath(genpath(BCTfolder));

fn_timing = [projfolder{1}, 'neurolens/data/data-cme-shine375/timing.csv'];
timing_table = readtable(fn_timing, 'FileType', 'text');
timing_table.run_name = string(timing_table.run_name);
timing_table.task_name = string(timing_table.task_name);
timing_labels = timing_table.task_name;
timing_arr = timing_table.task;
changes = find([timing_arr(2:end) - timing_arr(1:end-1); 1]);

datafolder = [basefolder, '/data/cme/SBJ01'];
mappers = ["BDLMapper_32_25_50"; "BDLMapper_32_25_60"; "BDLMapper_32_25_80"];

mid = 3; % for mid = 1:size(mappers,1)
datapath = strcat(datafolder, '/', mappers(mid), '/res.mat');

res = load(datapath).res;

K = res.memberMat' * (res.adjacencyMat > 0);
% K = res.memberMat' * res.adjacencyMat;
degs = sum(K, 2)';
degs = normalize(degs, 'Range');

f = figure;
f.Position = [f.Position(1:2) 2000 400];
hold on;


for cid = 2:length(changes)
    ch1 = changes(cid-1)+1;
    ch2 = changes(cid);
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
title(['TR Degrees for ', mappers(mid)], 'Interpreter', 'none')
