function [emg_data, emg_timestamp, cycle_separator, cycle_timestamp, emg_label, emg_framerate, point_framerate] = load_data(Path2datafiles, side)

if strcmp(Path2datafiles(end-2 : end), 'mat')
    load(Path2datafiles, 'ANALOGdat', 'POINTdat', 'ParameterGroup', 'AnalogFrameRate');
    
    emg_framerate = AnalogFrameRate;
    point_framerate = ParameterGroup(3).Parameter(5).data;
    
elseif strcmp(Path2datafiles(end-2 : end), 'c3d')
    acq = btkReadAcquisition(Path2datafiles);
    ANALOGdat = btkGetAnalogsValues(acq)';

    markers = btkGetMarkers(acq);
    ccc = struct2cell(markers);
    dim2 = size(ccc,1); 
    A = cell2mat(ccc);
    dim3 = size(A,1)/dim2; 
    POINTdat = permute(reshape(A', [3 dim3 dim2]), [1 3 2]);
    
    emg_framerate = btkGetAnalogFrequency(acq);
    point_framerate = emg_framerate / btkGetAnalogSampleNumberPerFrame(acq);
    
end


emg_label = {'GlMa', 'TeFa', 'ADDL', 'BiFe', 'SeTe', 'ReFe', 'VaLa', 'VaMe', 'GaMe', 'GaLa', 'Sol', 'TiAn'};

if strcmp(side, 'right')
    emg_data = ANALOGdat(38:49, :)';
elseif strcmp(side, 'left')
    emg_data = ANALOGdat([25:32 34:37], :)';
end

emg_frames = size(emg_data, 1);
n_shift = round(48 * emg_framerate / 1000);

% shift DELSYS EMG by 48 msec (standard DELSYS wireless lag = 48 msec)
emg_data = [emg_data(n_shift+1 : end, :); zeros([n_shift size(emg_data, 2)])]; 

% thi -- thigh, toe -- big toe; max = heel strike
if strcmp(side, 'right')
    r_thi_x = squeeze(POINTdat(1, 34, :));
    r_thi_y = squeeze(POINTdat(3, 34, :));
    r_toe_x = squeeze(POINTdat(1, 39, :));
    r_toe_y = squeeze(POINTdat(3, 39, :));
elseif strcmp(side, 'left')
    r_thi_x = squeeze(POINTdat(1, 28, :));
    r_thi_y = squeeze(POINTdat(3, 28, :));
    r_toe_x = squeeze(POINTdat(1, 33, :));
    r_toe_y = squeeze(POINTdat(3, 33, :));
end

cycle_separator = atand((r_toe_x - r_thi_x) ./ (r_thi_y - r_toe_y));
cycle_frames = size(cycle_separator, 1);

emg_timestamp = linspace(0, (emg_frames-1)/emg_framerate, emg_frames);
cycle_timestamp = linspace(0, (cycle_frames-1)/point_framerate, cycle_frames);
end
