function data = read_data(path)
    %% Read data from path based on the extension
    %
    % **Supported formats:**
    % 
    %   - MAT: the file should have the extension `.mat`
    % 
    %   - Numpy: the file should have the extension `.npy`
    % 
    %   - NIfTI: the file should have the extension `.nii` or `.nii.gz`
    % 
    %   - CSV: the file should have the extension `.csv`
    % 
    %   - TSV: the file should have the extension `.tsv`
    % 
    %   - 1D: the file should have the extension `.1D`, same as CSV but having a space (' ') as a delimiter
    % 
    [~,~,ext] = fileparts(path);
    ext = lower(ext);
    switch ext
        case '.1d'
            data = read_1d(path);
        case '.csv'
            data = read_1d(path, ',');
        case '.tsv'
            data = read_1d(path, '\t');
        case '.npy'
            data = readNPY(path);
        case {'.nii', '.nii.gz'}
            data = niftiread(path);
        case '.mat'
            data = load(path).data;
        otherwise
            data = read_1d(path);
    end
end
