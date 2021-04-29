function emg_to_csv_2_stairs(timestamps)
addpath(genpath('D:\!Work\Science\PEPATO\btk'))

[FileDat, PathDat] = uigetfile(['/cd/*.' 'c3d'], 'Open EMG data', 'Multiselect', 'off');
Path2datafiles = [PathDat FileDat];

disp(FileDat);
N = input('Input subject`s number N: ', 's');
R = input('Input run number R: ');
condition = input('Input condition: ', 's');
output_name = strjoin({'subject', sprintf('%s', N), 'run', sprintf('%03d', R)}, '_');


if strcmp(Path2datafiles(end-2 : end), 'mat')
    load(Path2datafiles, 'ANALOGdat', 'POINTdat', 'ParameterGroup', 'AnalogFrameRate');
    
    emg_framerate = AnalogFrameRate;
    point_framerate = ParameterGroup(3).Parameter(5).data;
    
elseif strcmp(Path2datafiles(end-2 : end), 'c3d')
    acq = btkReadAcquisition(Path2datafiles);
    ANALOGdat = btkGetAnalogsValues(acq)';
    md = btkGetMetaData(acq); %metadata

    markers = btkGetMarkers(acq);
    ccc = struct2cell(markers);
    dim2 = size(ccc,1); 
    A = cell2mat(ccc);
    dim3 = size(A,1)/dim2; 
    POINTdat = permute(reshape(A', [3 dim3 dim2]), [1 3 2]);
    
    emg_framerate = btkGetAnalogFrequency(acq);
    point_framerate = emg_framerate / btkGetAnalogSampleNumberPerFrame(acq);
end

% 14 - BiFe_right, 18 - GaLa_right, 17 - GaMe_right, 8 - GlMa_right, 
% 20 - PeLo_right, 13 - ReFe_right, 22 - SeTe_right, 19 - Sol_right, 
% 10 - TeFa_right, 21 - TiAn_right, 11 - VaLa_right, 12 - VaMe_right
emg_label = {'BiFe_right', 'GaLa_right', 'GaMe_right', 'GlMa_right', 'PeLo_right', 'ReFe_right', ... 
    'SeTe_right', 'Sol_right', 'TeFa_right', 'TiAn_right', 'VaLa_right', 'VaMe_right'};

ANALOG_label = md.children.ANALOG.children.LABELS.info.values;
emg_idx = [];
for label = {'Voltage.8', 'Voltage.12', 'Voltage.11', 'Voltage.2', 'Voltage.14', 'Voltage.7', ...
        'Voltage.16', 'Voltage.13', 'Voltage.4', 'Voltage.15', 'Voltage.6', 'Voltage.5'}
    idx = find(strcmp(ANALOG_label, label{:}), 1, 'first');
    emg_idx = [emg_idx, idx];
end
emg_data = ANALOGdat(emg_idx, :)';

emg_frames = size(emg_data, 1);
n_shift = round(48 * emg_framerate / 1000);

% shift DELSYS EMG by 48 msec (standard DELSYS wireless lag = 48 msec)
emg_data = [emg_data(n_shift+1 : end, :); zeros([n_shift size(emg_data, 2)])]; 
emg_timestamp = linspace(0, (emg_frames-1)/emg_framerate, emg_frames)';

new_emg_data = [];
start_ = 1;
for i = 2 : 2 : length(timestamps)
    if i < length(timestamps)
        idx = find(round(emg_timestamp * 1000) == round(timestamps(i) * 1000));
        new_emg_data = [new_emg_data; emg_data(start_ : idx(1), :)];
        idx_start = find(round(emg_timestamp * 1000) == round(timestamps(i+1) * 1000));
        start_ = 1 + idx_start(1);
    else
        new_emg_data = [new_emg_data; emg_data(start_ : end, :)];
    end
end
emg_data = new_emg_data;
emg_frames = size(emg_data, 1);
emg_timestamp = linspace(0, (emg_frames-1)/emg_framerate, emg_frames)';

gaitEvents = [];
new_timestamps = [];
shift = 0;
for i = 1 : 2 : length(timestamps)
    stamp = timestamps(i) - shift;
    new_timestamps = [new_timestamps, stamp];
    if i < length(timestamps) - 1
        shift = shift + timestamps(i+2) - timestamps(i+1);
    end
end
new_timestamps = [new_timestamps, timestamps(end) - shift];

gaitEvents.r_heel_strike = new_timestamps;

% 
% POINT_label = md.children.POINT.children.LABELS.info.values;
% r_heel_idx = find(strcmp(POINT_label, 'RHEEL'));
% l_heel_idx = find(strcmp(POINT_label, 'LHEEL'));
% %  max = heel strike
% r_heel_x = squeeze(POINTdat(1, r_heel_idx, :));
% r_heel_y = squeeze(POINTdat(3, r_heel_idx, :));
% 
% l_heel_x = squeeze(POINTdat(1, l_heel_idx, :));
% l_heel_y = squeeze(POINTdat(3, l_heel_idx, :));
% 
% r_cycle_separator = r_heel_y;
% l_cycle_separator = l_heel_y;
% r_cycle_frames = size(r_cycle_separator, 1);
% l_cycle_frames = size(l_cycle_separator, 1);


% r_cycle_timestamp = linspace(0, (r_cycle_frames-1)/point_framerate, r_cycle_frames)';
% l_cycle_timestamp = linspace(0, (l_cycle_frames-1)/point_framerate, l_cycle_frames)';
% 
% 
% if strcmp(condition, 'speed2kmh')
%     gait_freq = 1.0;
% elseif strcmp(condition, 'speed4kmh')
%     gait_freq = 1.5;
% elseif strcmp(condition, 'speed6kmh')
%     gait_freq = 2.25;
% else
%     error('Invalid condition specified.');
% end
% 
% try
%     r_emg_bounds = find_gait_events(r_heel_x, r_heel_y, point_framerate, gait_freq);
% catch
%     r_emg_bounds = [];
% end
% try
%     l_emg_bounds = find_gait_events(l_heel_x, l_heel_y, point_framerate, gait_freq);
% catch
%     l_emg_bounds = [];
% end
% 
% 
% gaitEvents = [];
% gaitEvents.r_heel_strike = r_emg_bounds;
% gaitEvents.l_heel_strike = l_emg_bounds;

label = [{'time'}, emg_label];
data = [emg_timestamp * 1000, round(emg_data, 5)]; % -- emg data rounded -- 

% try
%     T_kin = array2table([l_cycle_timestamp * 1000, l_cycle_separator, r_cycle_timestamp * 1000, r_cycle_separator], ...
%         'VariableNames', {'left_time', 'left_cycles', 'right_time', 'right_cycles'});
%     writetable(T_kin, fullfile(PathDat, strjoin({output_name, 'cycles', [condition '.csv']}, '_')), 'Delimiter', ',');
% catch
% end

T = array2table(data, 'VariableNames', label);
writetable(T, fullfile(PathDat, strjoin({output_name, 'emg', [condition '.csv']}, '_')), 'Delimiter', ',');

write_yaml(fullfile(PathDat, strjoin({output_name, 'gaitEvents', [condition '.yaml']}, '_')), gaitEvents);

end
