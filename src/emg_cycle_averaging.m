function [emg_mean, emg_sd, emg_min, emg_max] = emg_cycle_averaging(emg_enveloped, n_points, dim, emg_bounds)% [n_points, n_emg] 
% "emg_enveloped" should consist of normalized cycles (or "emg_bounds" must be set)
% "emg_bounds" must be set only if normalization is needed
% dim = 2 -- avereging through the cycles
% dim = 1 -- avereging through the points inside cycle

n_emg = size(emg_enveloped, 2);

if nargin < 4
    n_cycles = size(emg_enveloped, 1) / n_points;
else
    n_cycles = size(emg_bounds, 1);
    emg_enveloped = normalize_emg(emg_enveloped, emg_bounds, n_points);
end

emg_mean = squeeze(mean(reshape(emg_enveloped, [n_points n_cycles n_emg]), dim));
emg_sd = squeeze(std(reshape(emg_enveloped, [n_points n_cycles n_emg]), 0, dim));
emg_min = squeeze(min(reshape(emg_enveloped, [n_points n_cycles n_emg]), [], dim));
emg_max = squeeze(max(reshape(emg_enveloped, [n_points n_cycles n_emg]), [], dim));

end