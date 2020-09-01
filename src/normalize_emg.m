function emg_normalized = normalize_emg(emg_enveloped, emg_bounds, n_points)% [n_points*n_cycles, n_emg]

n_emg = size(emg_enveloped, 2);
n_cycles = size(emg_bounds, 1);

if nargin < 3
    n_points = 200;
end

emg_normalized = zeros(n_points * n_cycles, n_emg);
for i = 1:n_emg
    for j = 0:n_cycles-1
        emg_normalized(j*n_points+1:(j+1)*n_points, i) = interp1(emg_bounds(j+1, 1):emg_bounds(j+1, 2), ...
            emg_enveloped(emg_bounds(j+1, 1):emg_bounds(j+1, 2), i), ...
            linspace(emg_bounds(j+1, 1), emg_bounds(j+1, 2), n_points), 'linear');
    end
end

end 