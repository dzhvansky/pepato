function [csv_files, yaml_files, result] = check_filenames(file_list, condition_list)

if ~isempty(file_list)
    
    % TODO  csv_files = sort(file_list(cell_contains(file_list, '_emg.csv')));
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
        f = get_filenames(csv_files(i));
        splitted = strsplit(f{:}, '_');
        
        % check filename parts
        try
            result = result && strcmp(splitted{1}, 'subject') && strcmp(splitted{3}, 'run');
                % && (length(subject{1, i})==4) && (length(trial{1, i})==3);   
        catch
            result = false;
        end
        
        % check corresponding yaml file exists
%         TODO  splitted{end} = 'gaitEvents.yaml'; 
        splitted{end-1} = 'gaitEvents';
        yaml_file_name = strjoin(splitted, '_');
        yaml_idx = cell_contains(file_list, yaml_file_name);
        result = result && (sum(yaml_idx) == 1);
        
        yaml_files{i} = file_list{yaml_idx};
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