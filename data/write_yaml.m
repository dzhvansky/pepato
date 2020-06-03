function write_yaml(name, params)

fid = fopen(name, 'w');

fn = fieldnames(params);
for i = 1 : numel(fn)
    fprintf(fid, '%s: [%s]\n', fn{i}, strjoin(arrayfun(@(x) num2str(x), params.(fn{i}), 'UniformOutput', false), ', '));
end

fclose(fid);