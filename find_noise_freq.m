function freq2filt = find_noise_freq(emg_data, emg_framerate, high_pass, low_pass)
n_emg = size(emg_data, 2);

if nargin < 3
    high_pass = emg_framerate/2;
end

[psd_emg, f] = emg_spectra(emg_data, emg_framerate);

freq2filt = double.empty(2,0);

for i = 1 : n_emg

    freq_artifacts = f((psd_emg(:,i) ./ mtlb_smooth(psd_emg(:,i), round(size(psd_emg(:,i),1)/50), 'moving', 2)) > 5);
    freq_artifacts = freq_artifacts((freq_artifacts > high_pass) & (freq_artifacts < low_pass));
    freq_artifacts = [freq_artifacts - 0.1; freq_artifacts + 0.1];
    
    if ~isempty(freq_artifacts)
        band_start = freq_artifacts(1, [true, freq_artifacts(1, 2:end) > freq_artifacts(2, 1:end-1) + 0.2]);
        band_end = freq_artifacts(2, [freq_artifacts(1, 2:end) > freq_artifacts(2, 1:end-1) + 0.2, true]);
        band_mean = mean([band_start;band_end], 1);
        band_start = band_mean - (band_end - band_start) / 0.1 .* (band_mean - band_start);
        band_end = band_mean + (band_end - band_start) / 0.1 .* (band_end - band_mean);
        
        freq_temp = [freq2filt(1,:), band_start; freq2filt(2,:), band_end];
        [freq_temp(1, :), idx] = sort(freq_temp(1, :));
        freq_temp(2, :) = freq_temp(2, idx);
        
        freq2filt = [];
        freq2filt(1, :) = freq_temp(1, [true, freq_temp(1, 2:end) > freq_temp(2, 1:end-1) + 0.2]);
        freq2filt(2, :) = freq_temp(2, [freq_temp(1, 2:end) > freq_temp(2, 1:end-1) + 0.2, true]);        
    end
end

mask = zeros(1, size(freq2filt, 2));
f_mean = f(mean(psd_emg, 2) ./ mtlb_smooth(mean(psd_emg, 2), round(size(mean(psd_emg, 2),1)/50), 'moving', 2) > 2);
for i = 1 : size(f_mean, 2)
    mask = mask + (freq2filt(1, :) < f_mean(i)) .* (freq2filt(2, :) > f_mean(i));
end
freq2filt = reshape(freq2filt([mask>0; mask>0]), 2, []);

end