%% RUN_MAIN runs mapper on a large cohort of items based on the config.
% The mapper config is defined at `config_path`.
%
% The items (cohort) to be processed it defined by each line of the CSV 
% file at path `cohort_csv`. Each item's path is relative to the
% the path `data_root`.
% 
% Finally, the output is saved at the path `output_dir`
%
%
% :param cohort_csv: the path to a CSV file with the header: `id0,id1,id2,path`
%              the `id`s can be any string and the path is the location
%              of the 1D file used for processing Mapper. The path is
%              relative to the `data_root` path.
%
% :param data_root: the absolute root directory to the paths defined in the
%                CSV file: `cohort_csv`
% :param config_path: the path to the config file that defines what mappers
%                  and analysis to be used. Some example configurations are
%                  at `tests/fixtures/config*.json` or below. This
%                  configuration also defines the preprocessing step.
% :param output_dir: the absolute root directory of where to save the results
%                 of the mappers and the analysis. 
% :param poolsize: (optional) number of threads to use for parallelizing the
%               process and analysis. This is highly recommended for big
%               jobs. Usually its set as the number of CPU cores.
% :param rerun_analysis: (optional) if this is set, the process will use
%                     pre-computed mapper results from a previous run and
%                     reruns only the specified analysis.
%                     Possible Values are: "plot_graph", "compute_stats",
%                     "compute_temp". Or check `run_analysis` function for
%                     the latest.
% :param rerun_uncomputed: (optional) if this boolean option is set, the
%                       process will rerun all items of the cohort that
%                       either failed or didn't finish successfully based
%                       on the `status.csv` file.
%
% **Output structure:**
%
%   The result of an individual item will be saved at: `id0/id1/id2/MapperID/`, 
%   *where:*
%
%     - Each `id` (id0, id1, id2) is taken from the `cohort_csv` for the item
%     - The id `MapperID` is generated from the specific mapper from `config_path`
% 
%   Moreover, there is a status file saved at `config_name/status.csv`, that
%   displays the status of the process running all mappers.
%

basefolder = fileparts(fileparts(fileparts(mfilename('fullpath'))));
codefolder  = [basefolder, '/code'];
addpath(genpath(codefolder));

VALID_ANALYSES = {'plot_graph', 'plot_task', 'compute_stats', 'compute_temp'};

if ~exist('cohort_csv', 'var')
    error('DeMapper:IncorrectSetup', ...
        'Please set up variable cohort_csv to correctly run DeMapper');
end
if ~exist('config_path', 'var')
    error('DeMapper:IncorrectSetup', ...
        'Please set up variable config_path to correctly run DeMapper');
end
if ~exist('data_root', 'var')
    error('DeMapper:IncorrectSetup', ...
        'Please set up variable data_root to correctly run DeMapper');
end
if ~exist('output_dir', 'var')
    error('DeMapper:IncorrectSetup', ...
    'Please set up variable output_dir to correctly run DeMapper');
end

%% Special option of running one step only
is_rerun_analysis = 0;
if exist('rerun_analysis', 'var')
    assert(any(startsWith(rerun_analysis, VALID_ANALYSES)), ['Option to rerun ' ...
        'parameters is not valid: ', rerun_analysis])
    is_rerun_analysis = 1;
end

%% Special option to run only the uncomputed and errored
is_rerun_uncomputed = 0;
if exist('rerun_uncomputed', 'var')
    is_rerun_uncomputed = 1;
end

%% Set poolsize for parallel computing
% - set poolsize = # cpus to request
% - default is to use all available cpus
parForArg = 0;
if exist('poolsize', 'var')
    delete(gcp('nocreate')); % TODO: use gcp if size matches poolsize
    pool = parpool(poolsize);
    parForArg = poolsize;
end

%% Parse Options
csv_opts = delimitedTextImportOptions('Delimiter', ',', ...
    'VariableNamesLine', 1, 'DataLines', 2);
cohort = readtable(cohort_csv, csv_opts);
config = read_json(config_path);
mappers = parse_mappers(config.mappers);


has_multi_plot_tasks = has_multiple_analyses(config.analyses, 'plot_task');

%% Create the results folder if not there already and create a status file
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end
status_path = [output_dir, '/status.csv'];
IDS = {'id0', 'id1', 'id2', 'mapper'};
if ~exist(status_path, 'file')
    an_header = arrayfun(@(x) get_analysis_name(x, has_multi_plot_tasks), ...
        config.analyses, 'UniformOutput', false)';
    header = horzcat(IDS, {'preprocess', 'result'}, an_header);
    writecell(header, status_path);
    if is_rerun_analysis
        % Extra check for exact match to the header
        assert(any(strcmp(rerun_analysis, an_header)), ['Option to rerun ' ...
            'analysis is not valid: ', rerun_analysis])
    end
end
if is_rerun_uncomputed
    statuses = readtable(status_path, 'PreserveVariableNames', true, ...
        'Delimiter', ',');
    status_ids = table2cell(statuses(:, 1:length(IDS)));
    status_ids(cell2mat(cellfun(@(x) all(isnan(x)), status_ids, 'UniformOutput', false))) = {''};
    status_ids = join(string(status_ids), '_');
    status_results = all(statuses{:, length(IDS)+1:end}, 2);
    if is_rerun_analysis
        % Expect the rerun analysis to exist in the header of statuses
        assert(any(strcmp(statuses.Properties.VariableNames, rerun_analysis)), ...
            ['Analysis has not run before: ', rerun_analysis])
        status_results = statuses.(rerun_analysis);
    end
    if ~isempty(status_ids)
        status_map = containers.Map(status_ids, status_results);
    else
        status_map = containers.Map();
    end
end

%% Start the process
n_data = size(cohort, 1);
n_mappers = length(mappers);
params = combvec(1:n_data, 1:n_mappers)';
errors_cnt = 0; % reduction variable for parfor
parfor (params_idx = 1:size(params,1), parForArg)

    data_idx = params(params_idx, 1);
    mapper_idx = params(params_idx, 2);

    %% Setup datapath & mapper options
    item = cohort(data_idx, :);
    data_path = [data_root, '/', cell2mat(item.path)];

    mopts = cell2mat(mappers(mapper_idx));

    % `resdir` Base results path 
    resdir = [output_dir, '/', cell2mat(item.id0), '/', ...
        cell2mat(item.id1), '/', ...
        cell2mat(item.id2), '/', ...
        mopts.name];
    % `M` is the status of the whole process. Writted to CSV
    M = [item.id0, item.id1, item.id2, mopts.name];

    if ~exist(resdir, 'dir')
        mkdir(resdir);
    end

    if is_rerun_uncomputed
        run_key = join(M, '_');
        if status_map.isKey(run_key) && status_map(cell2mat(run_key))
            disp(['Skipping running: ', cell2mat(run_key)]);
            continue
        end
    end

    if is_rerun_analysis
        % Load cached results if `rerun_analysis` is set
        res = load([resdir, '/res.mat']).res;
        M = horzcat(M, {'-1', '-1'});
    else
        %% Default codepath, run the Mapper with the configuration
        data = read_data(data_path);
        % TODO: wrap preprocessing inside try-catch
        [data, preproc_details] = run_preprocess(config, data);
        M = horzcat(M, {'1'});

        % Run the Mapper
        try
            tStart = tic;
            res = mapper(data, mopts);
            res.processing_time = toc(tStart);
            res.preproc_details = preproc_details;
            writemyfile([resdir, '/res.mat'], res);
            M = horzcat(M, {'1'});
        catch ME
            % Catch all failures, display them and set the status for mapper to 0.
            warning('Failed mapper on item (%s) with Exception:', ...
                strjoin([item.id0, item.id1, item.id2, mopts.name]));
            warning(getReport(ME, 'extended', 'hyperlinks', 'on' ));
            M = horzcat(M, {'0'}, repmat({'0'}, 1, length(config.analyses)));
            writecell(M, status_path, 'WriteMode', 'append');
            % count numbers of errors
            errors_cnt = errors_cnt + 1;
            continue
        end
    end

    %% Run the Analyses
    for a_idx = 1:size(config.analyses)
        an = config.analyses(a_idx);
        if iscell(an)
            an = cell2mat(an);
        end
        try
            if ~any(strcmp(an.type, VALID_ANALYSES))
                % Throw if the analysis type is not valid
                error('DeMapper:UnidentifiedAnalysisType', ...
                    'Cannot process analysis of type: %s', analysis.type);
            end
            analysis_name = get_analysis_name(an, has_multi_plot_tasks);
            if ~is_rerun_analysis || strcmp(rerun_analysis, analysis_name)
                % Run if rerun_analysis is not set, or if that's the
                % analysis to be rerun.
                run_analysis(res, an, generalize_item(item, data_root), resdir);
                M = horzcat(M, {'1'});
            else
                % Set a default `-1` in CSV to let know that this
                % analysis was not run this time.
                M = horzcat(M, {'-1'});
            end
        catch ME
            % Catch all failures, display them and set the status to 0.
            warning('Failed processing item (%s) with Exception:', ...
                strjoin([item.id0, item.id1, item.id2, mopts.name]));
            warning(getReport(ME, 'extended', 'hyperlinks', 'on' ));
            M = horzcat(M, {'0'});
        end
    end

    % Append the results to the status CSV file
    writecell(M, status_path, 'WriteMode', 'append');
end

disp(['Total mapper errors: ', num2str(errors_cnt)]);

%% Helper functions
function has = has_multiple_analyses(analyses, analysis_type)
    count = 0;
    for a_idx = 1:size(analyses)
        an = analyses(a_idx);
        if iscell(an)
            an = cell2mat(an);
        end
        if strcmp(an.type, analysis_type)
            count = count + 1;
        end
    end
    if count > 1
        has = true;
    else
        has = false;
    end
end

function item = generalize_item(item, data_root)
    % make the tmask and any task_path_* to point to absolute path instead of relative
    fns = fieldnames(item);
    if any(strcmp(fns, 'tmask'))
        tmask_path = item.tmask;
        if iscell(tmask_path)
            tmask_path = cell2mat(tmask_path);
        end
        if ~startsWith(tmask_path, '/')
            % if not absolute, make absolute
            item.tmask = [data_root, '/', item.tmask];
        end
    end
    for i = 1:length(fns)
        fn = fns{i};
        if startsWith(fn, 'task_path')
            fn_path = item.(fn);
            if iscell(fn_path)
                fn_path = cell2mat(fn_path);
            end
            if ~startsWith(fn_path, '/')
                % if not absolute, make absolute
                item.(fn) = [data_root, '/', fn_path];
            end
        end
    end
end

function analysis_name = get_analysis_name(analysis, has_multi_plot_tasks)
    if iscell(analysis)
        analysis = cell2mat(analysis);
    end
    analysis_name = analysis.type;
    if has_multi_plot_tasks && isfield(analysis, 'args') && isfield(analysis.args, 'name')
        % Small case if there are multiple plot tasks, have a
        % status field describing each one individually so we can
        % rerun specific analyses. Needs a "an.args.name"
        analysis_name = [analysis.type, '-', analysis.args.name];
    end
end
