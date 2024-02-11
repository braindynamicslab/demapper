function h = getEntropy(p)
% Function getEntropy
% October 1, 2019
% Input:
% p         -- a probability vector or a histogram

% Output:
% h         -- the Shannon entropy of the probability vector defined by p

% normalize to get probability vector

if sum(p) ~= 1
    p = p./sum(p);
end

% remove zeros
p(p==0) = [];

% calculate entropy
h = -sum(p.*log2(p));

end
