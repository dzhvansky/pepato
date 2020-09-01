function [FileDat, result] = check_filenames(FileDat, PathDat, condition_list)

if ~strcmp(FileDat, '')
    if ischar(FileDat)
        FileDat = {FileDat};
    end
    
    N = length(FileDat);
    
    try
        [~, trials, conditions] = get_trial_info(FileDat);
        result = sum(ismember(conditions, condition_list)) == N;
    catch
        result = false;
    end
    
    for i = 1:N
        
        f = FileDat(i);
        splitted = strsplit(f{:}, '_');
        
        % check filename parts
        try
            result = result && strcmp(splitted{1}, 'subject') && strcmp(splitted{3}, 'run');
                % && (length(subject{1, i})==4) && (length(trial{1, i})==3);   
        catch
            result = false;
        end
        
        % check corresponding yaml file exists
        splitted{end} = 'gaitEvents.yaml';
        yaml_file_name = strjoin(splitted, '_');
        result = result && (exist(fullfile(PathDat, yaml_file_name), 'file') == 2);
    end
    
    % check all conditions are unique for each run
    for trial = unique(trials)
        trial_idx = strcmp(trials, trial);
        result = result && (length(unique(conditions(trial_idx))) == sum(trial_idx));
    end 
    
else
    result = false;
    
end

end