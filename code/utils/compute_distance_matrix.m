function distances_X = compute_distance_matrix(X, dist_type)
    distances_X = sdist(X, dist_type);

    % Small cleanup for correlation
    del = 10*eps(class(distances_X));
    if any(diag(distances_X) > del)
        % Sometimes the diagonal is not fully 0 because of rounding issues. 
        % This makes sure it all 0s on the diagonal. Especially needed for
        % CMDScale
        distances_X = distances_X - diag(diag(distances_X));
    end

end

function d = sdist(W, dist_type)
    %sdist Symetric pairwise distance
    switch dist_type
        case 'bhattacharyya'
            d = bhattacharyyaDistance(W,W);

        case {'minkowski5', 'minkowski10', 'minkowski50'}
            newDist = 'minkowski';
            distParam = str2double(replace(dist_type, newDist, ''));
            d = pdist2(W, W, newDist, distParam);

        otherwise
            d = pdist2(W,W,dist_type);
    end
    d = (d + d') / 2;
end
