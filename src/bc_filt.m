function emg_data = bc_filt(emg_data, emg_framerate, carrier_freq, band_width, width_method)
n_emg = size(emg_data, 2);

if nargin < 4
    band_width = 1; width_method = 'constant';
elseif nargin < 5 
    width_method = 'constant';
end
for k = 1:floor(emg_framerate/2/carrier_freq)
    if strcmp(width_method, 'constant')
        band = [carrier_freq * k - band_width/2, carrier_freq * k + band_width/2] / (emg_framerate/2);
    elseif strcmp(width_method, 'increase')
        band = [carrier_freq * k - band_width/2 * k, carrier_freq * k + band_width/2 * k] / (emg_framerate/2);
    end
    [bc, ac] = butter(3, band, 'stop'); %Butterworth 3-rd order
    for i = 1:n_emg 
        emg_data(:,i) = filtfilt(bc, ac, emg_data(:,i)); %band-cut 6-th order Butterworth filter
    end
end

end