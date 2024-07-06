function [res, preprop_deets] = run_preprocess(config, data)
% RUN_PREPROCESS runs a whole preprocessing configuration on an input data.
% The steps are applied in the order of the configuration.
% 
% :param config: the preprocessing configuration details
% :type config: list of struct
%
% :param data: the data to preprocess
% :type data: 2D matrix
% 
% :returns res: the result of the input `data` after processing
%          using the preprocessing steps in `config`
% :type res: 2D matrix
%
% :returns preprop_deets: the detailed parameteres that were used
%                    to preprocess the data
% :type preprop_deets: (struct)
%
% **Note:** This will process any 2D matrix. As the output of the processing is 
% a 2D matrix that will be used within Mapper, the output rows will be
% reduced by the Mapper. If you want to reduce the columns instead,
% you can use the `transpose` preprocessing step.
% Usually for fMRI data, if we want to process the dynamics, we use rows
% as the time points (TRs) and columns as the ROIs, with the value being
% the BOLD response at a ROI at that point in time.
%
% **Possible preprocessing steps:**
%
%   - ``zscore``: normalizes the input data by subtracing the mean and diving
%     by the standard deviation of the input data.
%
%   - ``zscore-baseline``: normalizes the input data by subtracing the mean and
%     diving by the standard deviation of the baseline
%     data. The baseline data indices are defined within
%     the preprocess step as `min` and `max`.
%
%   - ``transpose``: simply transposes the data.
%
%   - ``drop-nan``: drop Not-A-Number (nan) values in two steps: 
%     (1) drop rows (e.g., TRs) that are all nan;
%     (2) drop columns (e.g., ROIs) that contain at least one nan value.
%
%   - ``drop-lowvar``: drop all columns (e.g., ROIs) that have a variance
%     below the one provided as value `var`.
% 

res = data;
preprop_deets = struct;
bystep = cell(1,length(config.preprocess));
for p_idx = 1:size(config.preprocess)
    prp = config.preprocess(p_idx);
    if iscell(prp)
        prp = cell2mat(prp);
    end
    [res,pres] = run_preprocess_step(prp, res);
    bystep{p_idx} = pres;
end

%% set metadata for preprocessing
preprop_deets.config = config.preprocess;
preprop_deets.bystep = bystep;
preprop_deets = add_agg_fields(preprop_deets, bystep);

end

%% Helper functions
function [res,pres] = run_preprocess_step(preprocess, data)
    pres = struct;
    switch preprocess.type
        case 'zscore'
            [res,miu,sigma] = zscore(data);
            pres.miu = miu;
            pres.sigma = sigma;

        case 'zscore-baseline'
            % extract min,max as the indices of the baseline
            bmin = preprocess.min;
            bmax = preprocess.max;
            baseline = data(bmin:bmax, :);
            % compute mean and std
            [~, miu, sigma] = zscore(baseline);
            % normalize (zscore) based on the mean and std of the baseline
            res = (data - miu) ./ sigma;
            pres.miu = miu;
            pres.sigma = sigma;
            
        case 'transpose'
            res = data';

        case 'drop-nan'
            % drop bad frames (all NaN)
            drop_trs = all(isnan(data),2);
            data = data(~drop_trs,:);
        
            % drop nan columns too
            drop_rois = any(isnan(data),1)';
            res = data(:,~drop_rois);
            pres.drop_trs = drop_trs;
            pres.drop_rois = drop_rois;

        case 'drop-lowvar'
            v = var(data);
            lowvar = preprocess.var;
            drop_rois = v(:) < lowvar;
            res = data(:,~drop_rois);
            pres.drop_rois = drop_rois;
    end
end

function deets = add_agg_fields(prevdeets, bystep)
    % combine the details from all the preprocessing steps into one for
    % easy access.
    deets = prevdeets;
    % generate drop_trs and drop_rois as an aggregate of all the steps
    for fname=["drop_trs", "drop_rois"]
        final = false;
        hasfinal = false;
        for si = 1:length(bystep)
            step = bystep{si};
            if isfield(step, fname)
                if hasfinal
                    % apply next drop step on the existing items
                    final(~final) = step.(fname);
                else
                    final = step.(fname);
                    hasfinal = true;
                end
            end
        end
        if hasfinal
            deets.(fname) = final;
        end
    end
end
