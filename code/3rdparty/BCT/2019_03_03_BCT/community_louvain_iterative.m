%WGGG
%
%
%

function [ciu, mean_q, d] = community_louvain_iterative(A, obj_fun, gamma, iters)

    if nargin < 2
       obj_fun = 'modularity';
       gamma = 1;
    end
    if nargin < 4
        iters = 100;
    end
    m=[];
    q=[];
    for iter=1:1:iters
        [m(:,iter),q(iter)] = community_louvain(A,gamma,[],obj_fun);
    end
    d=agreement_weighted(m,q);
    ciu=consensus_und(d,0.001,100);
    mean_q = mean(q);

end