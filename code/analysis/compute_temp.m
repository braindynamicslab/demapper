function compute_temp(res, resdir, skip_mat)
% COMPUTE_TEMP Compute and plot the Temporal matrices
%
% :param res: the results from running Mapper
% :type res: Mapper struct
%
% :param resdir: where to save the resulting plots and matrices
% :type resdir: string
%
% :param skip_mat: if true, it doesn't print out the TCM matrices (default: false)
% :type skip_mat: bool
%
output_prefix = [resdir, '/compute_temp-'];

TCM = get_similarity_mat(res.adjacencyMat, res.memberMat);
TCM_inv = graph(1 ./ TCM).distances;

if nargin < 3
    skip_mat = false;
end
assert(isa(skip_mat,'logical'))

% plot the TCM matrix
f = figure('visible', 'off');
imagesc(TCM);
colorbar;
saveas(f, [output_prefix, 'TCM.png']);
close(f);

% plot the TCM_inv matrix
f = figure('visible', 'off');
imagesc(TCM_inv);
colorbar;
saveas(f, [output_prefix, 'TCM_inv.png']);
close(f);

if ~skip_mat
    % Write TCM and TCM_inv matrices
    write_1d(TCM, [output_prefix, 'TCM-mat.1D']);
    write_1d(TCM_inv, [output_prefix, 'TCM_inv-mat.1D']);
end

end
