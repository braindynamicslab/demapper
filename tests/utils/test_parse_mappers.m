clear;
basefolder = fileparts(fileparts(fileparts(mfilename('fullpath'))));
codefolder  = [basefolder,'/code'];
addpath(genpath(codefolder));

config1_path = [basefolder, '/tests/fixtures/config.json'];
config2_path = [basefolder, '/tests/fixtures/config2.json'];
config3_path = [basefolder, '/tests/fixtures/config3.json'];
config4_path = [basefolder, '/tests/fixtures/config4.json'];

% [1] Test multiple mappers in one analysis config
c1 = read_json(config1_path);
m1 = parse_mappers(c1.mappers);
assert(length(m1) == 2);
m1_names = cellfun(@(x) x.name, m1, 'UniformOutput', false);
assert(strcmp(cell2mat(m1_names(1)), 'BDLMapper_32_20_60'));
assert(strcmp(cell2mat(m1_names(2)), 'NeuMapper_16_100_90'));

% [2] Test multiple mappers including Kepler
c2 = read_json(config2_path);
m2 = parse_mappers(c2.mappers);
assert(length(m2) == 6);
m2_names = cellfun(@(x) x.name, m2, 'UniformOutput', false);
assert(strcmp(cell2mat(m2_names(1)), 'KeplerMapper_15_60_euclidean'));
assert(strcmp(cell2mat(m2_names(2)), 'KeplerMapper_15_60_cityblock'));
assert(strcmp(cell2mat(m2_names(3)), 'KeplerMapper_15_70_euclidean'));
assert(strcmp(cell2mat(m2_names(4)), 'KeplerMapper_15_70_cityblock'));
assert(strcmp(cell2mat(m2_names(5)), 'NeuMapper_16_100_90'));
assert(strcmp(cell2mat(m2_names(6)), 'NeuMapper_16_200_90'));

% [3] Test only one mapper in one analysis config
c3 = read_json(config3_path);
m3 = parse_mappers(c3.mappers);
assert(length(m3) == 2);
m3_names = cellfun(@(x) x.name, m3, 'UniformOutput', false);
assert(strcmp(cell2mat(m3_names(1)), 'NeuMapper_16_100_90'));
assert(strcmp(cell2mat(m3_names(2)), 'NeuMapper_16_200_90'));

% [4] Test parsing CustomMapper
c4 = read_json(config4_path);
m4 = parse_mappers(c4.mappers);
total_mappers = 2 * 2 * 2 * 2 * 2;
assert(length(m4) == total_mappers);
m4_names = cellfun(@(x) x.name, m4, 'UniformOutput', false);
assert(strcmp(cell2mat(m4_names(1)), 'SpCustomMapper_cityblock_CMDS_60_10'));
assert(strcmp(cell2mat(m4_names(32)), 'CustomMapper_euclidean_tSNE_80_20'));
