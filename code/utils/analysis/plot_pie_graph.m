function f = plot_pie_graph(node_adjmat, node_label_counts, cmap, fvisible)
%% PLOT_PIE_GRAPH draws a force plot with heatmaps for nodes
%
% Inputs:
%   - node_adjmat: Nodes adjacency matrix (size NxN where N is the number
%                  of nodes
%   - node_label_counts: Number of classes for each node (size NxC where C
%                        is the number of classes to be displayed). 
%   - cmap: Colors designated for each class (size Cx3)
%   - fvisible: 'off' | 'on' sets the visibility of the figure.
%               Default: 'on'
%
% Output:
%   - f: the figure
%

if nargin < 4
    fvisible = 'on';
end

[~, nodecolor] = max(node_label_counts, [] , 2);

fhelp = figure('visible','off');
h = plot(graph(node_adjmat), 'Layout', 'force', 'UseGravity', 'on', ...
    'MarkerSize', 10, 'nodeCdata', nodecolor);
colormap(cmap)
XY = 2*[h.XData' h.YData'];
close(fhelp);

f = figure('ToolBar', 'none', 'MenuBar', 'none', 'Visible', fvisible);
hold on;
percents = node_label_counts ./ sum(node_label_counts,2);
plot_scale = mean(max(XY) - min(XY));
radius = plot_scale / 160 + plot_scale / 8 * sqrt( sum(node_label_counts,2) ./ sum(node_label_counts,'all') );

%% draw edges
[e_i,e_j] = find(triu(node_adjmat + node_adjmat')); % Draw each edge only once
% Below is the same as the following commented code, but optimized to run
% in one plot function.
x1 = extract_edge_dim(XY, e_i, 1);
y1 = extract_edge_dim(XY, e_j, 1);
x2 = extract_edge_dim(XY, e_i, 2);
y2 = extract_edge_dim(XY, e_j, 2);
plot([x1 y1]', [x2 y2]', 'Color', [0,0,0,0.5]);
% for e = 1:1:length(e_i)
%    plot([XY(e_i(e),1), XY(e_j(e),1)], [XY(e_i(e),2), XY(e_j(e),2)], ...
%        'Color', [0,0,0,0.5]); 
% end


%% draw piecharts
for n = 1:1:length(nodecolor)
    pos = XY(n,:);
    drawpie(percents(n,:), pos, radius(n), cmap)    
end
alpha(0.9);

set(f,'Color','White');
box off
axis off
end

%% Helper functions
function drawpie(percents,pos,radius,colors)
    points = 40;
    x = pos(1);
    y = pos(2);
    last_t = 0;
    if (length(find(percents))>1)
        for i = 1:length(percents)
            end_t = last_t + percents(i)*points;
            tlist = [last_t ceil(last_t):floor(end_t) end_t];
            xlist = [0 (radius*cos(tlist*2*pi/points)) 0] + x;
            ylist = [0 (radius*sin(tlist*2*pi/points)) 0] + y;
            patch(xlist,ylist,colors(i,:))
            last_t = end_t;
        end
    else
        i=find(percents);
        tlist = [0:points];
        xlist = x+radius*cos(tlist*2*pi/points);
        ylist = y+radius*sin(tlist*2*pi/points);
        patch(xlist,ylist,colors(i,:))
    end
end

function res = extract_edge_dim(XY, e_x, dim)
    % Add Nans in-between each edge so that Matlab doesn't draw the
    % connection from one edge to the next edge.
    res = reshape([XY(e_x, dim), NaN(size(e_x))]', size(e_x, 1) * 2, 1);
end