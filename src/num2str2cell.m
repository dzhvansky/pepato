function string_cell = num2str2cell(array)

string_cell = arrayfun(@(x) num2str(x), array, 'UniformOutput', false);

end