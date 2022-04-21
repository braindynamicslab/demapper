function score = circleloss_score(mapper_path, tr_names)
    % This score computes the length for each node to the low and up
    % states. The loss is the subtraction of the distances to the two
    % low and up states. The loss is computed and added for transition_plus
    % and transition_minus.
    datapath = fullfile(mapper_path, 'res.mat');
    res = load(datapath).res;

    % Really process
    mm = res.memberMat;

    trs_low = strcmp(tr_names, 'low');
    trs_tplus = strcmp(tr_names, 'trans_plus');
    trs_up = strcmp(tr_names, 'up');
    trs_tmin = strcmp(tr_names, 'trans_minus');
    
    n_low = mm * trs_low > 0; % all nodes that contain low
    n_up = mm * trs_up > 0; % all nodes that contain up
    
    % all nodes that contain only trans_minus or trans_plus
    nonly_tmin = (mm * trs_tmin > 0) & (mm * (1-trs_tmin) == 0);
    nonly_tplus = (mm * trs_tplus > 0) & (mm * (1-trs_tplus) == 0);
    if sum(nonly_tmin) == 0 || sum(nonly_tplus) == 0
        score = Inf;
        return;
    end
    
    g = graph(res.adjacencyMat); D = g.distances;
    
    score_tmin = min(abs(noninf_mean(D(nonly_tmin, n_low)) - noninf_mean(D(nonly_tmin, n_up))));
    score_tplus = min(abs(noninf_mean(D(nonly_tplus, n_low)) - noninf_mean(D(nonly_tplus, n_up))));
    score = score_tplus + score_tmin;
end

% Helper functions
function res = noninf_mean(mat)
    % get the mean to all nodes like: mean(mat, 2)
    % but actually remove the target nodes that are apart from all nodes
    inf_targets = all(mat == Inf, 1);
    if all(inf_targets)
        res = mean(mat, 2);
        return;
    end
    mat = mat(:, ~inf_targets);
    res = mean(mat, 2);
end
