
clear;
basefolder = fileparts(fileparts(mfilename('fullpath')));
codefolder  = [basefolder,'/code'];
toolsfolder  = [basefolder,'/tests/tools'];
addpath(genpath(codefolder));
addpath(genpath(toolsfolder));

% Load Data
data_path = [basefolder, '/hasegan_et_al_netneuro_2024/data/trefoil_knot/data_treefoil.1D'];

fn_timing = [basefolder, '/hasegan_et_al_netneuro_2024/data/trefoil_knot/data_treefoil_task.csv'];
timing_table = readtable(fn_timing, 'FileType', 'text', 'Delimiter', ',');
timing_table.task_name = string(timing_table.task_name);

coloring_data = [basefolder, '/hasegan_et_al_netneuro_2024/data/trefoil_knot/data_treefoil_task_nodeCData.1D'];
nodeCData = read_1d(coloring_data);

data = read_1d(data_path);
data = zscore(data);

% Setup default mapper
% opts = BDLMapperOpts(6, 5, 30);
% opts = NeuMapperOpts(32, 200, 35);
opts = NeuMapperOpts(10, 20, 30);
opts.dist_type = 'euclidean';
% opts = KeplerMapperOpts(20, 70, 'euclidean');
opts.low_mem = false;

% Run mapper
res = mapper(data, opts);

% nodeSize = cell2mat(cellfun(@(x) size(x, 2), res.nodeMembers, 'UniformOutput', false));
% nodeSize = normalize(nodeSize, 'range', [2, 10]);
% avgNode = cellfun(@mean, res.nodeMembers);

% g = graph(res.adjacencyMat);
% 
% plot(g, 'Layout', 'force', 'Usegravity', true, 'WeightEffect', 'inverse', ...
%     'MarkerSize', nodeSize, 'NodeCData', avgNode);
% colorbar
% colormap parula

K = (mod(1:120, floor(120 / 4)) == 1)';
markers = num2str(K);
markers(K == 0) = 'o';
markers(K == 1) = 's';
cmarkers = cellstr(markers);

figure;
hold on

h = plot(res.knn_g, 'Layout', 'force', 'Usegravity', true, 'WeightEffect', 'inverse', ...
    'NodeColor', nodeCData(1:end, 1:3), 'MarkerSize', (K+1)*10, 'EdgeColor', 'black', ...
    'Marker', cmarkers);

XY = [h.XData', h.YData'];

for i=1:length(K)
    if K(i) == 1
        sqaround(XY(i, 1), XY(i, 2))
        circle(XY(i, 1), XY(i, 2), 7)
%         viscircles(XY(i, :), 6, 'Color', 'k', 'LineStyle', '--')
    end
end


function h = sqaround(x,y)
k = 0.5;
thx = [1, 1, -1, -1, 1] * k;
thy = [1, -1, -1, 1, 1] * k;
h = plot(thx + x, thy + y, 'k-', 'LineWidth', 3);
end

function h = circle(x,y,r)
th = 0:pi/50:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;
h = plot(xunit, yunit, 'k--');
end