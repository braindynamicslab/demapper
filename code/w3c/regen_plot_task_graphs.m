%  Regenerate plot_task for all selected mappers

basefolder  = split(pwd, 'mappertoolbox-matlab');
basefolder  = [basefolder{1}, 'mappertoolbox-matlab'];
codefolder  = [basefolder,'/code'];
addpath(genpath(codefolder));

fn_timing = '/Users/dh/workspace/BDL/demapper/data/w3c/task_info.csv';
timing_table = readtable(fn_timing, 'FileType', 'text', 'Delimiter', ',');
timing_table.task_name = string(timing_table.task_name);


pdir = '/Users/dh/workspace/BDL/demapper/results/w3c_ss/w3cv5_SBJ99';

K = dir(pdir);
mappers = struct2cell(K); mappers = mappers(1, :);


for mapper=mappers
  if startsWith(mapper, 'CustomBDLMapper')
    p = fullfile(pdir, cell2mat(mapper));
    disp(mapper)
    res = load([p, '/res.mat']).res;
    save_path = [p, '/plot_task_alt1.png'];
    plot_task(res, timing_table, save_path, true)
  end
end
