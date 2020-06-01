function [FileDat, result] = check_filenames(FileDat, PathDat)

if ~strcmp(FileDat, '')
    if ischar(FileDat)
        FileDat = {FileDat};
    end
    
    N = length(FileDat);
    
    subject = cell(1, N);
    trial = cell(1, N);
    
    for i = 1:N
        
        f = FileDat(i);
        splitted = strsplit(f{:}, '_');
        
        % check filename parts
        try
            subject{1, i} = splitted{2};
            trial{1, i} = splitted{4};
            result = strcmp(splitted{1}, 'subject') && strcmp(splitted{3}, 'emg') && ...
                (length(subject{1, i})==4) && (length(trial{1, i})==3);   
        catch
            result = false;
        end
        
        splitted{3} = 'gaitEvents';
        yaml_file_name = strjoin(splitted, '_');
        yaml_file_name(end-2:end) = 'yml';
        
        % check corresponding yaml file exists
        result = result && (exist(fullfile(PathDat, yaml_file_name), 'file') == 2);
    end
    
    % check all conditions are unique for the only one subject
    result = result && (length(unique(subject))==1) && (length(unique(trial))==N);
    
else
    result = false;
    
end

end