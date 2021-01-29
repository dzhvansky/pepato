function idx = cell_contains(cell_array, string)

idx = cellfun(@(x) ~isempty(x), strfind(cell_array, string), 'UniformOutput', true);

end