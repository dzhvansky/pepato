function results = read_yaml(file_path)

fid = fopen(file_path, 'r');
data = textscan(fid, '%s', 'delimiter', '\n', 'whitespace', '');
fclose(fid);

data = deblank(data{1});
data(cellfun('isempty', data)) = [];

results = [];

for i = 1:numel(data)
    line = data{i};
    
    if strcmp(line(1), '#')
        continue
    end
    
    sep_idx = find(line==':', 1, 'first');
    
    key = strtrim(line(1:sep_idx-1));  
    
    value = strsplit(line(sep_idx+1:end), '#');
    value = strtrim(value{1}); 
    
    [numerical, status] = str2num(value);
    if status
        value = numerical;
    end
    
    results.(key) = value;
end