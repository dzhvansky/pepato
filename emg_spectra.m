function [psd_emg, f] = emg_spectra(emg_data, emg_framerate)
n_emg = size(emg_data, 2);

L = size(emg_data, 1);
f = emg_framerate * (0 : round(L/2)) / L;

psd_emg = zeros(size(f, 2), n_emg);
for i = 1 : n_emg
    Y = fft(emg_data(:,i));
    P2 = abs(Y/L);
    P1 = P2(1:round(L/2)+1);
    P1(2:end-1) = 2*P1(2:end-1); 
    psd_emg(:, i) = P1;
end
end