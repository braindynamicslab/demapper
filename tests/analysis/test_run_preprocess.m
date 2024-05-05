clear;
basefolder = fileparts(fileparts(fileparts(mfilename('fullpath'))));
codefolder  = [basefolder,'/code'];
addpath(genpath(codefolder));

config1_path = [basefolder, '/tests/fixtures/config.json'];
config2_path = [basefolder, '/tests/fixtures/config2.json'];
config5_path = [basefolder, '/tests/fixtures/config5.json'];

rng('default');
data = rand(50, 200); % time x features (TRs x ROIs

% Test config1
c1 = read_json(config1_path);
res = run_preprocess(c1, data);
assert(all(size(res) == [50, 200]))

% Test config2
c2 = read_json(config2_path);
res = run_preprocess(c2, data);
assert(all(size(res) == [200, 50]))

% Test config5
data = rand(200, 50); % time x features (TRs x ROIs)
datavar = var(data(:, 4:end));
% drop 4 TRs:
data(50, :) = nan;
data(51, :) = nan;
data(52, :) = nan;
data(53, :) = nan;
% drop 2 ROIs bc of nan:
data(10, 5) = nan;
data(100, 7) = nan;
% drop 2 ROIs bc of low variance
data(:, 10) = data(:, 10) * 0.01;
data(:, 20) = data(:, 20) * 0.004;

c5 = read_json(config5_path);
[res,deets] = run_preprocess(c5, data);
assert(all(size(res) == size(data) - 4))
assert(all(find(deets.drop_rois) == [5; 7; 10; 20]))
assert(all(find(deets.drop_trs) == [50; 51; 52; 53]))
