function [lens_X, knn_g] = compute_rknn_prelens(X, rknnparam, rknn_directed, rknnbinarized)
    if nargin < 4
        rknnbinarized = false;
    end

    [~,~,~,knn_g_bin,knn_g_wtd] = createPKNNG_bdl(X, rknnparam);
    if ~rknnbinarized
        knn_g = graph(knn_g_wtd);
    else
        knn_g = graph(knn_g_bin);
    end

    % Create the direction graph based on timing
    if rknn_directed
        % TODO!
    end

    % Compute geodesic distances from the generated graph
    dist_geo = knn_g.distances;
    % Remove Inf values
    mg = max(max(dist_geo(dist_geo ~= Inf)));
    dist_geo(dist_geo == Inf) = 2 * mg;
    % symmetrize to prevent rounding error 
    dist_geo = (dist_geo + dist_geo')/2;
    lens_X = dist_geo;
end
