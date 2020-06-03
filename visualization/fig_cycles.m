function fig_cycles(handle_obj, cycle_separator, cycle_timestamp, emg_timestamp, emg_framerate, point_framerate, n_emg, emg_bounds)

p_bounds = round(emg_bounds / emg_framerate * point_framerate);
separ = [p_bounds(:, 1); p_bounds(end, 2)];

axes('Parent', handle_obj);

subplot('Position', [.05, .03, .72, .10]);

plot(cycle_timestamp, cycle_separator, 'Color', [0 .447 .741], 'Tag', 'cycles'); axis(axis); hold on;
ylabel(sprintf('[deg]\ncycles'));


ystart = zeros(size(separ)) - 100;
ystop = zeros(size(separ)) + 100;
tx = [cycle_timestamp(separ.'); cycle_timestamp(separ.'); nan(1, size(separ, 1))];
ty = [ystart.'; ystop.'; nan(1, size(separ, 1))];
plot(tx(:), ty(:), 'Color', [.85 .325 .098]);


emg_axes = find_axes_by_plot(handle_obj, 'emg_*');

ystart = zeros(size(emg_bounds, 1), 1) - 5;
ystop = zeros(size(emg_bounds, 1), 1) + 5;
for j = 1 : n_emg
    axes(emg_axes(j));
    
    tx_start = [emg_timestamp(emg_bounds(:,1)'); emg_timestamp(emg_bounds(:,1)'); nan(1, length(emg_bounds(:,1)))];
    tx_stop = [emg_timestamp(emg_bounds(:,2)'); emg_timestamp(emg_bounds(:,2)'); nan(1, length(emg_bounds(:,2)))];
    ty = [ystart.'; ystop.'; nan(1, size(emg_bounds, 1))];
    
    plot(tx_start(:), ty(:), 'Color', [.9 .9 .9]); alpha(.2);
    plot(tx_stop(:), ty(:), 'Color', [.9 .9 .9], 'LineStyle', '--'); alpha(.2);
end

% linkaxes([emg_axes, find_axes_by_plot(handle_obj, 'cycles')], 'x'); % linking of subplot axes for X-axis
end