function data = read_1d(data_path, delimiter)
if nargin < 2
    delimiter = ' ';
end

data_opts = delimitedTextImportOptions('Delimiter', delimiter);
data = readmatrix(data_path, data_opts);
data = str2double(data);
end
