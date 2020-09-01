function [emg_data, emg_timestamp, emg_bounds, emg_label, emg_framerate, mov_data, mov_timestamp] = load_csv_yaml_data(path_to_csv_file, csv_file_name, body_side)

% emg
emg_filename = fullfile(path_to_csv_file, csv_file_name);
fid = fopen(emg_filename, 'r'); 
column_names = strsplit(fgetl(fid), ','); 
fclose(fid);
emg_data = csvread(emg_filename, 1, 0);
emg_timestamp = emg_data(:, 1)';
emg_framerate = round(length(emg_timestamp) / (emg_timestamp(end) - emg_timestamp(1)) * 1000); % in Hz -- from miliseconds

index = ~cellfun(@isempty, regexp(column_names, ['_' body_side '$']));
if sum(index) == 0
    index = 2:length(column_names);
end
emg_label = column_names(index);
emg_data = emg_data(:, index);


% gait events
splitted = strsplit(emg_filename, '_');
splitted{end} = 'gaitEvents.yaml';
events_filename = strjoin(splitted, '_');

gait_events = read_yaml(events_filename);
events = gait_events.([body_side(1) '_heel_strike']);
events = events((events >= min(emg_timestamp)) & (events <= max(emg_timestamp)));
[~, closest_idx] = min(abs(bsxfun(@minus, repmat(emg_timestamp', [1, length(events)]), events*1000))); % find closest

emg_bounds = [closest_idx(1 : end-1); closest_idx(2 : end) - 1]';
emg_timestamp = emg_timestamp / 1000; % in seconds


% gait cycles (if available)
splitted{end} = 'cycles.csv';
cycles_filename = strjoin(splitted, '_');
if exist(cycles_filename, 'file') == 2
    fid = fopen(cycles_filename, 'r'); 
    cycle_column_names = strsplit(fgetl(fid), ','); 
    fclose(fid);
    
    cycle_data = csvread(cycles_filename, 1, 0);
    cycle_table = array2table(cycle_data, 'VariableNames', cycle_column_names);
    
    mov_data = cycle_table{:, [body_side '_cycles']};
    mov_timestamp = cycle_table{:, [body_side '_time']};
    
    mov_timestamp = mov_timestamp / 1000; % in seconds
else
    mov_data = [];
    mov_timestamp = [];
end

end