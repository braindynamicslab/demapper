clear;
basefolder  = split(pwd, 'mappertoolbox-matlab');
basefolder  = [basefolder{1}, 'mappertoolbox-matlab'];
codefolder  = [basefolder,'/code/utils'];
toolsfolder  = [basefolder,'/tests/tools'];
addpath(genpath(codefolder));
addpath(genpath(toolsfolder));

% [1] setup small test example
plotall = false;
dataset = [
    0.2, 0.6;
    0.233, 0.581;
    0.215, 0.615;
    0.170, 0.624;
    0.152, 0.594;
    0.31, 0.29;
    0.33, 0.27;
    0.35, 0.26;
    0.34, 0.28;
    0.5, 0.5;
    0.6, 0.7;
    0.7, 0.6;
    0.7, 0.7;
    0.6, 0.6;
    0.5, 0.6;
    0.7, 0.3];

dists = pdist2(dataset, dataset, 'euclidean');

% Scatter plot of data
if plotall
    scatter(dataset(:,1), dataset(:,2))
    xlim([0, 1])
    ylim([0, 1])
end

[knnGraphTbl, ~, knnGraph_dense_wtd, ~, knnGraph_dense_wtd_conn] = createPKNNG_bdl(dists, 4);

% Plot of rknn graph before penalized conns
if plotall
    figure;
    G = graph(knnGraph_dense_wtd);
    LWidths = 5*G.Edges.Weight/max(G.Edges.Weight);
    plot(G,'XData',dataset(:,1),'YData',dataset(:,2), 'LineWidth',LWidths)
end

% Plot of the rknn graph after
if plotall
    figure;
    G = graph(knnGraph_dense_wtd_conn);
    LWidths = 5*G.Edges.Weight/max(G.Edges.Weight);
    plot(G,'XData',dataset(:,1),'YData',dataset(:,2), 'LineWidth',LWidths)
end


added_conns = knnGraph_dense_wtd_conn - knnGraph_dense_wtd;
conn_weights = added_conns(triu(added_conns) > 0);
assert(all(conn_weights > max(max(knnGraph_dense_wtd))))
assert(all(conn_weights > 1.0))

% Plot only added connections and their length
if plotall
    figure;
    G = graph(added_conns);
    LWidths = 5*G.Edges.Weight/max(G.Edges.Weight);
    plot(G,'XData',dataset(:,1),'YData',dataset(:,2), 'LineWidth',LWidths, 'EdgeLabel',G.Edges.Weight)
end

g = graph(knnGraph_dense_wtd_conn);
bins = conncomp(g);
assert(max(bins) == 1) % only 1 connected component at the end

% [2] Test on real data
data = readNPY('../fixtures/example-data.npy');

for dist_type = {'cityblock', 'euclidean'}
    dX = pdist2(data, data, cell2mat(dist_type));
    [knnGraphTbl, ~, knnGraph_dense_wtd, ~, knnGraph_dense_wtd_conn] = createPKNNG_bdl(dX, 4);
    
    added_conns = knnGraph_dense_wtd_conn - knnGraph_dense_wtd;
    conn_weights = added_conns(triu(added_conns) > 0);
    
    disp(['For ', cell2mat(dist_type), ' added ', num2str(length(conn_weights)), ...
        ' connections with min: ', num2str(min(conn_weights)), ...
        ' and max: ', num2str(min(conn_weights)), ...
        ' ! Where max connection in original graph is: ', num2str(max(max(knnGraph_dense_wtd)))
        ])
    assert(all(conn_weights > max(max(knnGraph_dense_wtd))))
end

% [3] Test on data dim red with tsne
pts = tsne(data);

pts_dists = pdist2(pts, pts, 'euclidean');
[knnGraphTbl, ~, knnGraph_dense_wtd, ~, knnGraph_dense_wtd_conn] = createPKNNG_bdl(pts_dists, 10);

added_conns = knnGraph_dense_wtd_conn - knnGraph_dense_wtd;
conn_weights = added_conns(triu(added_conns) > 0.001);
assert(all(conn_weights > max(max(knnGraph_dense_wtd))))

if plotall
    % plot the added connections
    G = graph(added_conns);
    LWidths = 5*G.Edges.Weight/max(G.Edges.Weight);
    plot(G,'XData',pts(:,1),'YData',pts(:,2), 'LineWidth',LWidths)
end
