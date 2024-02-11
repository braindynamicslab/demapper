function stats = compute_stats(res, args, resdir)
% STATS get stats from the Mapper Graph
%
% :param res: the results from running Mapper
% :type res: Mapper struct
%
% :param args: extra details to help create the stats
% :type args: struct
%
% :param resdir: where to save the resulting plots and matrices
% :type resdir: string
%
stats = struct;

n_nodes = size(res.nodeMembers, 1);
stats.n_nodes = n_nodes;
if n_nodes == 0
    stats.coverage_nodes = 0;
    stats.coverage_TRs = 0;
    stats.hrfdur_stat = 0;
    stats.distances_max = 0;
    stats.distances_entropy = 0;
    stats.degree_TRs_avg = 0;
    stats.degree_TRs_entropy = -0;
    save_path = [resdir, '/stats.json'];
    saveAsJSON(stats, save_path)
    return
end


g = graph(res.adjacencyMat);
W = 1 ./ res.adjacencyMat; % W is the weighted adjacency matrix
W(res.adjacencyMat < 1) = 0;

%% Coverage
ccomp = g.conncomp;
[~,f,C] = mode(ccomp);
stats.coverage_nodes = f/length(ccomp);
C = cell2mat(C(1));
largest_comp = ccomp == C;
% get TRs in the largest component
TR_comps = largest_comp * res.memberMat;
stats.coverage_TRs = sum(TR_comps > 0, 'all') / length(TR_comps);
if issparse(stats.coverage_TRs)
    stats.coverage_TRs = full(stats.coverage_TRs);
end

%% HRF threshold
% Compute the percentage of nodes that have TRs separated by at least the
% HRF_threshold. For this we need the TR. 
if isfield(args, 'HRF_threshold')
hrf_threshold = args.HRF_threshold;
TR = args.TR;
node_diff = @(v) max(v) - min(v);
cover_width = cellfun(node_diff, res.nodeMembers);
stats.hrfdur_stat = sum(cover_width * TR > hrf_threshold, 'all')/length(cover_width);
% TODO: Take into account the TRs that were scrubbed by xcpengine.
%       Sometimes it might make a difference.
end

%% Network distances entropy
% Compute on the unweighted matrix
gD = g.distances('Method', 'unweighted');
% if 1-point graph, leave gD as-is. Otherwise, get distances.
% Include zeros on diagonal.
if numel(gD) > 1
    gD = gD(tril(true(size(gD))));
end
stats.distances_max = max(gD(~isinf(gD)));
q = histcounts(gD, 0:1:stats.distances_max+1);
stats.distances_entropy = getEntropy(q);

%% Network stats
% Betweenness centrality
btwness = betweenness_wei(res.adjacencyMat);
write_1d(btwness, [resdir, '/stats_betweenness_centrality.1D']);
btwness_TRs_avg = res.memberMat' * btwness ./ sum(res.memberMat', 2);
write_1d(btwness_TRs_avg, [resdir, '/stats_betweenness_centrality_TRs_avg.1D']);
btwness_TRs_max = full(max(res.memberMat .* btwness)');
write_1d(btwness_TRs_max, [resdir, '/stats_betweenness_centrality_TRs_max.1D']);


% Compute if ~= 0
if ~all(all(W == 0))
    % Assortativity
    stats.assortativity = assortativity_wei(W, 0);

    % Rich club Coefficients    
    rich_club_coefficients = rich_club_wu(W);
    write_1d(rich_club_coefficients, [resdir, '/stats_rich_club_coeffs.1D']);

    % Core periphery structure
    coreper = core_periphery_dir(W)';
    write_1d(coreper, [resdir, '/stats_core_periphery.1D']);
    coreper_TRs_avg = res.memberMat' * coreper ./ sum(res.memberMat', 2);
    write_1d(coreper_TRs_avg, [resdir, '/stats_core_periphery_TRs_avg.1D']);
    coreper_TRs_max = full(max(res.memberMat .* coreper)');
    write_1d(coreper_TRs_max, [resdir, '/stats_core_periphery_TRs_max.1D']);
end

% TR Degrees
degrees_TRs = res.memberMat' * (res.adjacencyMat > 0);
degrees_TRs = sum(degrees_TRs, 2);
write_1d(degrees_TRs, [resdir, '/stats_degrees_TRs.1D']);
stats.degree_TRs_avg = mean(degrees_TRs);
q = histcounts(degrees_TRs, 0:1:max(degrees_TRs)+1);
stats.degree_TRs_entropy = getEntropy(q);
if issparse(stats.degree_TRs_avg)
    stats.degree_TRs_avg = full(stats.degree_TRs_avg);
end

%% Save the stats to file
save_path = [resdir, '/stats.json'];
saveAsJSON(stats, save_path)

end
