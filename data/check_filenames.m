function [csv_files, yaml_files, result, csv_header] = check_filenames(file_list, condition_list, muscle_list)

csv_header = 'CSV header errors: ';

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
        
        % check scv header
        try
            fid = fopen(csv_files{i}, 'r'); 
            column_names = strsplit(fgetl(fid), ','); 
            fclose(fid);
            if ~strcmp(column_names{1}, 'time')
                csv_header = [csv_header sprintf('file %s has no timestamp; ', f)];
            end

            cols_splitted = cellfun(@(x) strsplit(x, '_'), column_names, 'UniformOutput', false);
            prefixes = cellfun(@(x) x{1}, cols_splitted, 'UniformOutput', false);
            if sum(cellfun(@(x) sum(strcmp(x, muscle_list)) > 0, prefixes)) == 0
                csv_header = [csv_header sprintf('file %s has no muscle EMG data; ', f)];
            end
        catch
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

if strcmp(csv_header, 'CSV header warnings: ')
    csv_header = true;
else
    csv_header = [csv_header 'The first column should be called "time"; ' ...
        sprintf('The name of at least one column must begin with the name of the muscle: [%s]', strjoin(muscle_list, ', '))];
end

end
