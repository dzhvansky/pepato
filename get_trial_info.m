function [subject, conditions] = get_trial_info(filenames)

% filenames should be cell of filenames without extension
N = length(filenames);
conditions = cell(1, N);

for i = 1:N
    f = filenames(i);
    splitted = strsplit(f{:}, '_');
    conditions{1, i} = strjoin(splitted(5:end), '_');
end

subject = splitted{2};

end