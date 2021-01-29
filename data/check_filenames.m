function [csv_files, yaml_files, result] = check_filenames(file_list, condition_list)

if ~isempty(file_list)
    
    csv_files = sort(file_list(cell_contains(file_list, '_emg_')));
    yaml_files = cell(size(csv_files));
    N = length(csv_files);
    try
        [~, trials, conditions] = get_trial_info(csv_files);
        result = sum(ismember(conditions, condition_list)) == N;
    catch
        result = false;
    end
    
    for i = 1:N
        [csv_path, f, ~] = fileparts(csv_files{i});
        splitted = strsplit(f, '_');
        
        % check filename parts
        try
            result = result && strcmp(splitted{1}, 'subject') && strcmp(splitted{3}, 'run') && strcmp(splitted{5}, 'emg');
        catch
            result = false;
        end
        
        % check corresponding yaml file exists
        splitted{end-1} = 'gaitEvents';
        yaml_file_name = strjoin(splitted, '_');
        
        if length(file_list) > length(csv_files)
            yaml_idx = cell_contains(file_list, yaml_file_name);
            yaml_check = sum(yaml_idx) == 1;
            result = result && yaml_check;
            if yaml_check
                yaml_files{i} = file_list{yaml_idx};
            end
        else
            yaml_file = fullfile(csv_path, [yaml_file_name '.yaml']);
            yaml_check = exist(yaml_file, 'file') == 2;
            result = result && yaml_check;
            if yaml_check
                yaml_files{i} = yaml_file;
            end
        end
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
