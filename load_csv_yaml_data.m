function [emg_data, emg_timestamp, emg_bounds, emg_label, emg_framerate] = load_csv_yaml_data(path_to_csv_file, csv_file_name, body_side)

% csv_table = readtable([path_to_csv_file, csv_file_name]);
% 
% column_names = csv_table.Properties.VariableNames;
% emg_timestamp = csv_table.('time')';
fid = fopen([path_to_csv_file, csv_file_name], 'r'); 
column_names = strsplit(fgetl(fid), ','); 
fclose(fid);
emg_data = csvread([path_to_csv_file, csv_file_name], 1, 0);
emg_timestamp = emg_data(:, 1)';

emg_framerate = round(length(emg_timestamp) / (emg_timestamp(end) - emg_timestamp(1)) * 1000); % in Hz -- from miliseconds

index = ~cellfun(@isempty, regexp(column_names, ['_' body_side '$']));
if sum(index) == 0
    index = 2:length(column_names);
end
emg_label = column_names(index);

% emg_data = csv_table{:, emg_label};
emg_data = emg_data(:, index);

splitted = strsplit(csv_file_name, '_');
splitted{3} = 'gaitEvents';
yaml_file_name = strjoin(splitted, '_');
yaml_file_name(end-2:end) = 'yml';

gait_events = read_yaml([path_to_csv_file, yaml_file_name]);
events = gait_events.([body_side(1) '_heel_strike']);
events = events((events >= min(emg_timestamp)) & (events <= max(emg_timestamp)));
[~, closest_idx] = min(abs(bsxfun(@minus, repmat(emg_timestamp', [1, length(events)]), events*1000))); % find closest

emg_bounds = [closest_idx(1 : end-1); closest_idx(2 : end) - 1]';

emg_timestamp = emg_timestamp / 1000; % in seconds

end