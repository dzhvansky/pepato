function emg_enveloped = emg_envelope(emg_data, emg_framerate, method, method_parameter)
% method = 'lowpass', method_parameter -- cutoff frequency (Hz) 
% method = 'rms', method_parameter -- smoothing window width (ms)
% method = 'hilbert', method_parameter -- None
n_emg = size(emg_data, 2);
if nargin < 3
    method = 'lowpass'; method_parameter = 10;
elseif nargin < 4
    if strcmp(method,'rms')
        method_parameter = 20; % 20 ms smoothing window
    elseif strcmp(method,'lowpass')
        method_parameter = 10; %low pass 10 Hz filter
    else
        method_parameter = [];
    end
end

if strcmp(method,'rms')
    w20 = round(method_parameter * emg_framerate / 1000);
    for i = 1:n_emg
        emg_data(:,i) = smooth(abs(emg_data(:,i)), w20, 'moving', 2);%sglazhivanie oknom 20 ms
    end
elseif strcmp(method,'lowpass')
    cutoff = method_parameter / (emg_framerate/2);
    [bl, al] = butter(2, cutoff); %Butterworth 2-nd order
    for i = 1:n_emg 
       emg_data(:,i) = filtfilt(bl, al, abs(emg_data(:,i))); %low-pass 4-th order Butterworth filter
    end
elseif strcmp(method,'hilbert')
    for i = 1:n_emg
        emg_data(:,i) = (imag(hilbert(emg_data(:,i))).^2 + emg_data(:,i).^2).^0.5; % Hilbert transform curve envelope
    end
else
    error('Error. \n%s', 'The method is incorrect. Choose one of ["rms", "lowpass", "hilbert"]');
end

emg_enveloped = emg_data;
end