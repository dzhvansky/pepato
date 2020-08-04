function emg_data = filter_emg(emg_data, emg_framerate, high_pass, low_pass, freq2filt)
n_emg = size(emg_data, 2);

LP = 0;
BC = 0;
if nargin < 2
    emg_framerate = 1000; high_pass = 20;
elseif nargin < 3
    high_pass = 20;
elseif nargin == 4
    LP = 1;
elseif nargin == 5
    LP = 1; BC = 1;
end

hp = high_pass /(emg_framerate/2); %high pass
[bh, ah] = butter(2, hp, 'high'); %Butterworth 2-nd order
for i = 1:n_emg 
   emg_data(:,i) = filtfilt(bh, ah, emg_data(:,i)); %high-pass 4-th order Butterworth filter
end

if LP == 1
    cutoff = low_pass /(emg_framerate/2);%low pass
    [bl, al] = butter(2, cutoff); %Butterworth 2-nd order
    for i = 1:n_emg 
       emg_data(:,i) = filtfilt(bl, al, emg_data(:,i)); %low-pass 4-th order Butterworth filter
    end
end

if BC == 1
    for i = 1 : size(freq2filt, 2)
        band = [freq2filt(1, i), freq2filt(2, i)] / (emg_framerate/2);
        [bc, ac] = butter(3, band, 'stop'); %Butterworth 3-rd order
        for j = 1:n_emg 
            emg_data(:,j) = filtfilt(bc, ac, emg_data(:,j)); %band-cut 6-th order Butterworth filter
        end
    end
end

artifact_filter_idx = [];
hp150 = 150 /(emg_framerate/2); %high pass 150 Hz
[bh150, ah150] = butter(2, hp150, 'high'); %Butterworth 2-nd order
for emg_idx = artifact_filter_idx
    [psd_emg_old, ~] = emg_spectra(emg_data(:,emg_idx), emg_framerate);
    emg_data(:,emg_idx) = filtfilt(bh150, ah150, emg_data(:,emg_idx)); %high-pass 4-th order Butterworth filter
    [psd_emg_new, ~] = emg_spectra(emg_data(:,emg_idx), emg_framerate);
    emg_data(:,emg_idx) = emg_data(:,emg_idx) * mean(psd_emg_old) / mean(psd_emg_new);
end

zeroing_idx = [];
for emg_idx = zeroing_idx
    emg_data(:,emg_idx) = 1e-3 * randn(size(emg_data(:,emg_idx)));
end

end