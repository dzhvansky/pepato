function [fwhm, coa] = pattern_analisys(emg_mean, n_points)

n_emg = size(emg_mean, 2);
n_cycles =  size(emg_mean, 1) / n_points;


fwhm = zeros(n_cycles, n_emg);

for i = 1:n_emg
    for j = 1:n_cycles
        emg_cycle = emg_mean(1+(j-1)*n_points : j*n_points, i);
        fwhm(j, i) = sum((emg_cycle - min(emg_cycle)) > max(emg_cycle)/2) / n_points * 100;
    end
end


coa = zeros(n_cycles, n_emg);

bin = 2*pi / n_points;
angle = linspace(bin, 2*pi, n_points)';

for i = 1:n_emg
    for j = 1:n_cycles
        w = emg_mean(1+(j-1)*n_points : j*n_points, i);

        xc = sum(cos(angle) .* w);
        yc = sum(sin(angle) .* w);

        beta = atan(yc/xc) + pi*(xc<0) + 2*pi*(xc>=0 && yc<0);
        coa(j, i) = beta / (2*pi) * 100;
    end
end

end