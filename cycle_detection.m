function emg_bounds = cycle_detection(cycle_separator, emg_framerate, point_framerate, gait_freq)

[~, separ] = findpeaks(cycle_separator, 'minpeakdistance', round(point_framerate/(gait_freq*1.2)));

p_bounds = zeros(size(separ,1)-1, 2);
p_bounds(:, 1) = separ(1:end-1)';
p_bounds(:, 2) = separ(2:end)';

emg_bounds = round(p_bounds * emg_framerate / point_framerate);
emg_bounds(:, 2) = emg_bounds(:, 2) - 1;

end
