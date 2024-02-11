clear;
basefolder  = split(pwd, 'demapper');
basefolder  = [basefolder{1}, 'demapper'];
codefolder  = [basefolder,'/code/utils'];
toolsfolder  = [basefolder,'/tests/tools'];
addpath(genpath(codefolder));
addpath(genpath(toolsfolder));

% ======= Test on directed Adjacency matrix =======
M = [ % Adjacency (directed)
    0 1 0 
    0 0 1
    0 0 0];

bmat = [1 0 0 0 % node to TRs
        0 1 1 0
        0 0 0 1];

T1 = get_similarity_mat(M, bmat);
T1e = [
     0     1     1     0
     0     0     1     1
     0     1     0     1
     0     0     0     0];
assert(all(all(T1 == T1e)));

% ======= Test on symmetric Adjacency matrix =======
M2 = M + M';
T2 = get_similarity_mat(M2, bmat);
T2e = [
     0     1     1     0
     1     0     1     1
     1     1     0     1
     0     1     1     0];
assert(all(all(T2 == T2e)));


% ======= Test on Weighted Adjacency matrix =======
M3 = M * 3;
T3 = get_similarity_mat(M3, bmat);
T3e = [
     0     1     1     0
     0     0     1     1
     0     1     0     1
     0     0     0     0];
assert(all(all(T3 == T3e)));
