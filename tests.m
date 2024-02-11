function result = tests()

% Combine all test files that start with `test_`
suite1 = testsuite('./tests/', 'Name', 'test_*/*');
suite2 = testsuite('./tests/analysis', 'Name', 'test_*/*');
suite3 = testsuite('./tests/utils', 'Name', 'test_*/*');
suite = [suite1, suite2, suite3];

% This is just for now to test github actions. TODO:use it
% suite = testsuite('./tests/utils/', 'Name', 'test_parse*/*');

% Run the testsuite
result = run(suite);

end