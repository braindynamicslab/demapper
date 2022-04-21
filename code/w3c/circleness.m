function score = circleness(mapper_path, tr_names)
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

    % graph without trans_min
    g_wout_tmin = graph(res.adjacencyMat(~nonly_tmin, ~nonly_tmin));
    D_wout_tmin = g_wout_tmin.distances;
    score_tplus = mean(D_wout_tmin(n_low, n_up), 2);

    % graph without trans_plus
    g_wout_tplus = graph(res.adjacencyMat(~nonly_tplus, ~nonly_tplus));
    D_wout_tplus = g_wout_tplus.distances;
    score_tminus = mean(D_wout_tplus(n_low, n_up), 2);

    score = min(abs(score_tminus - score_tplus));
end
