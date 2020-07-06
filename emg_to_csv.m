function emg_to_csv()
addpath(genpath('D:\!Work\Science\PEPATO\btk'))

[FileDat, PathDat] = uigetfile(['/cd/*.' 'c3d'], 'Open EMG data', 'Multiselect', 'off');
Path2datafiles = [PathDat FileDat];
side = 'left';

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

% 28 - BiFe_left, 35 - GaLa_left, 34 - GaMe_left, 25 - GlMa_left, 30 -
% ReFe_left, 29 - SeTe_left, 36 - Sol_left, 26 - TeFa_left, 37 - TiAn_left,
% 31 - VaLa_left, 32 - VaMe_left
% 41 - BiFe_right, 47 - GaLa_right, 46 - GaMe_right, 38 - GlMa_right, 43 -
% ReFe_right, 42 - SeTe_right, 48 - Sol_right, 39 - TeFa_right, 49 -
% TiAn_right, 44 - VaLa_right, 45 - VaMe_right
emg_label = {'BiFe_left', 'GaLa_left', 'GaMe_left', 'GlMa_left', 'ReFe_left', 'SeTe_left', 'Sol_left', 'TeFa_left', 'TiAn_left', 'VaLa_left', 'VaMe_left', ...
    'BiFe_right', 'GaLa_right', 'GaMe_right', 'GlMa_right', 'ReFe_right', 'SeTe_right', 'Sol_right', 'TeFa_right', 'TiAn_right', 'VaLa_right', 'VaMe_right'};

emg_data = ANALOGdat([28, 35, 34, 25, 30, 29, 36, 26, 37, 31, 32,     41, 47, 46, 38, 43, 42, 48, 39, 49, 44, 45], :)';
% if strcmp(side, 'right')
%     emg_data = ANALOGdat(38:49, :)';
% elseif strcmp(side, 'left')
%     emg_data = ANALOGdat([25:32 34:37], :)';
% end

emg_frames = size(emg_data, 1);
n_shift = round(48 * emg_framerate / 1000);

% shift DELSYS EMG by 48 msec (standard DELSYS wireless lag = 48 msec)
emg_data = [emg_data(n_shift+1 : end, :); zeros([n_shift size(emg_data, 2)])]; 

% thi -- thigh, toe -- big toe; max = heel strike

r_thi_x = squeeze(POINTdat(1, 34, :));
r_thi_y = squeeze(POINTdat(3, 34, :));

r_toe_x = squeeze(POINTdat(1, 39, :));
r_toe_y = squeeze(POINTdat(3, 39, :));

l_thi_x = squeeze(POINTdat(1, 28, :));
l_thi_y = squeeze(POINTdat(3, 28, :));

l_toe_x = squeeze(POINTdat(1, 33, :));
l_toe_y = squeeze(POINTdat(3, 33, :));

r_cycle_separator = atand((r_toe_x - r_thi_x) ./ (r_thi_y - r_toe_y));
l_cycle_separator = atand((l_toe_x - l_thi_x) ./ (l_thi_y - l_toe_y));
% r_cycle_frames = size(r_cycle_separator, 1);
% l_cycle_frames = size(l_cycle_separator, 1);

emg_timestamp = linspace(0, (emg_frames-1)/emg_framerate, emg_frames)';
% r_cycle_timestamp = linspace(0, (r_cycle_frames-1)/point_framerate, r_cycle_frames);
% l_cycle_timestamp = linspace(0, (l_cycle_frames-1)/point_framerate, l_cycle_frames);


if ~isempty(strfind(FileDat, 'speed2kmh'))
    gait_freq = 0.75;
elseif ~isempty(strfind(FileDat, 'speed4kmh'))
    gait_freq = 1.5;
elseif ~isempty(strfind(FileDat, 'speed6kmh'))
    gait_freq = 2.25;
end

% r_cycle_separator(1:7700) -- for Yani -- 77 sec cut
% l_cycle_separator(1:7700) -- for Yani -- 77 sec cut
r_emg_bounds = find_gait_events(r_cycle_separator, point_framerate, gait_freq);
l_emg_bounds = find_gait_events(l_cycle_separator, point_framerate, gait_freq);

gaitEvents = [];
gaitEvents.r_heel_strike = r_emg_bounds;
gaitEvents.l_heel_strike = l_emg_bounds;

label = [{'time'}, emg_label];
data = [emg_timestamp * 1000, round(emg_data, 5)];
% data = [emg_timestamp * 1000, emg_data]; -- without rounding -- 
% data = data(1:154000, :); -- for Yani -- 77 sec cut

N = input('Input subject`s number N: ');
R = input('Input run number R: ');
condition = input('Input condition: ', 's');

T = array2table(data, 'VariableNames', label);
writetable(T, [PathDat 'subject_' sprintf('%04d', N) '_run_' sprintf('%03d', R) '_' condition '_emg.csv'], 'Delimiter', ',');

write_yaml([PathDat 'subject_' sprintf('%04d', N) '_run_' sprintf('%03d', R) '_' condition '_gaitEvents.yaml'], gaitEvents);

% dlmwrite(filename, label{:}, 'delimiter', ',');
% dlmwrite(filename, data, '-append', 'delimiter', ',', 'roffset', 0, 'precision', 3);
end


