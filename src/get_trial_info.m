function [subjects, trials, conditions] = get_trial_info(filenames)

% filenames should be cell array of filenames without extension
N = length(filenames);

subjects = cell(1, N);
trials = cell(1, N);
conditions = cell(1, N);

for i = 1:N
    f = filenames(i);
    splitted = strsplit(f{:}, '_');
    
    subjects{1, i} = splitted{2};
    trials{1, i} = splitted{4};
    conditions{1, i} = splitted{5};
end

end