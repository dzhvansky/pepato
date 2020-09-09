function [emg_data, emg_timestamp, emg_bounds, emg_label, emg_framerate, mov_data, mov_timestamp] = load_csv_yaml_data(emg_csv_file, gaitevents_yaml_file, body_side)

% emg
fid = fopen(emg_csv_file, 'r'); 
column_names = strsplit(fgetl(fid), ','); 
fclose(fid);
emg_data = csvread(emg_csv_file, 1, 0);
emg_timestamp = emg_data(:, 1)';
emg_framerate = round(length(emg_timestamp) / (emg_timestamp(end) - emg_timestamp(1)) * 1000); % in Hz -- from miliseconds

index = ~cellfun(@isempty, regexp(column_names, ['_' body_side '$']));
if sum(index) == 0
    index = 2:length(column_names);
end
emg_label = column_names(index);
emg_data = emg_data(:, index);


% gait events
gait_events = read_yaml(gaitevents_yaml_file);
events = gait_events.([body_side(1) '_heel_strike']);
events = events((events >= min(emg_timestamp)) & (events <= max(emg_timestamp)));
[~, closest_idx] = min(abs(bsxfun(@minus, repmat(emg_timestamp', [1, length(events)]), events*1000))); % find closest

emg_bounds = [closest_idx(1 : end-1); closest_idx(2 : end) - 1]';
emg_timestamp = emg_timestamp / 1000; % in seconds


% gait cycles (if available)
splitted = strsplit(gaitevents_yaml_file, '_');
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