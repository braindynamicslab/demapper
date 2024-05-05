function all_mapper_opts = parse_mappers(mapper_opts)
all_mapper_opts = {};
for i=1:size(mapper_opts)
    mopts = mapper_opts(i);
    if ~isa(mopts, 'struct')
        mopts = cell2mat(mopts);
    end
    switch mopts.type
        case {'BDLMapper', 'NeuMapper'}
            for ki = 1:length(mopts.k)
                for ri = 1:length(mopts.resolution)
                    for gi = 1:length(mopts.gain)
                        switch mopts.type
                            case 'BDLMapper'
                                m = BDLMapperOpts(mopts.k(ki), mopts.resolution(ri), mopts.gain(gi));
                            case 'NeuMapper'
                                m = NeuMapperOpts(mopts.k(ki), mopts.resolution(ri), mopts.gain(gi));
                        end
                        m.name = [mopts.type, '_', num2str(mopts.k(ki)), ...
                            '_', num2str(mopts.resolution(ri)), ...
                            '_', num2str(mopts.gain(gi))];
                        all_mapper_opts = vertcat(all_mapper_opts, {m});
                    end
                end
            end
        case 'KeplerMapper'
            for ri = 1:length(mopts.resolution)
                for gi = 1:length(mopts.gain)
                    for dti = 1:length(mopts.dist_type)
                        dist_type = cell2mat(mopts.dist_type(dti));
                        m = KeplerMapperOpts(mopts.resolution(ri), ...
                            mopts.gain(gi), ...
                            dist_type);
                        m.name = ['KeplerMapper_', ...
                            num2str(mopts.resolution(ri)), '_', ...
                            num2str(mopts.gain(gi)), '_', ...
                            dist_type];
                        all_mapper_opts = vertcat(all_mapper_opts, {m});
                    end
                end
            end
        case 'CustomMapper'
            fields = fieldnames(mopts);
            fields = fields(~strcmp(fields, 'type') & ~strcmp(fields, 'name'));
            name = 'CustomMapper';
            if isfield(mopts, 'name') name = mopts.name; end
            all_mapper_opts = vertcat(all_mapper_opts, ...
                recParseCustomMapper(mopts, fields, 1, name));
        otherwise
            error('Did not recognize Mapper Type!')
    end
end
end

function mappers_list = recParseCustomMapper(opts, fields, fidx, name)
    assert(isstruct(opts));
    if (fidx > length(fields))
        opts.name = name;
        mappers_list = {opts};
        return;
    end

    field = cell2mat(fields(fidx));
    fieldval = opts.(field);
    N = length(fieldval);
    if ((iscell(fieldval) || (~isscalar(fieldval) && ~ischar(fieldval))) && ...
            N > 1)
        % If N > 1 AND its either:
        %       a cell matrix of a list of strings
        %       a list of numbers
        % then recursively create the options for the Mapper algorithm
        mappers_list = {};
        for k=1:N
            opts.(field) = fieldval(k);
            if iscell(opts.(field))
                opts.(field) = cell2mat(opts.(field));
            end
            fieldstr = opts.(field);
            if ~ischar(fieldstr)
                fieldstr = num2str(fieldstr);
            end
            mappers_list = vertcat(...
                mappers_list, ...
                recParseCustomMapper(opts, fields, fidx+1, [name, '_', fieldstr]));
        end
    else
        if iscell(fieldval)
            opts.(field) = cell2mat(fieldval);
        end
        mappers_list = recParseCustomMapper(opts, fields, fidx + 1, name);
    end
end