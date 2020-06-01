function idx = find_cell_contains(columns, pattern, regexp_flag)

if nargin < 3
    regexp_flag = '-';
end

if strcmp(regexp_flag, 'regexp')
    idx = find(not(cellfun('isempty', regexp(columns, pattern))));
else
    idx = find(not(cellfun('isempty', strfind(columns, pattern))));
end

end