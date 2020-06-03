% function fig_segment(handle_obj, n_emg, emg_timestamp, cycle_timestamp, emg_framerate, point_framerate, time_bounds)
function fig_segment(handle_obj, n_emg, emg_timestamp, emg_framerate, time_bounds)

% [emg_segment, cycle_segment] = segment_calculation(time_bounds, emg_framerate, point_framerate, length(emg_timestamp), length(cycle_timestamp));
emg_segment = segment_calculation(time_bounds, emg_framerate, length(emg_timestamp));

emg_axes = find_axes_by_plot(handle_obj, 'emg_*');

x1 = emg_timestamp(emg_segment(1));
x2 = emg_timestamp(emg_segment(2));
for j = 1:n_emg
    axes(emg_axes(j));
    plot([x1, x1], [-5 5], 'Color', 'k', 'LineStyle', '-', 'LineWidth', 2, 'Tag', ['segment_start_' num2str(j)]);
    plot([x2, x2], [-5 5], 'Color', 'k', 'LineStyle', '-', 'LineWidth', 2, 'Tag', ['segment_end_' num2str(j)]);
    rectangle('Position', [x1 -5 x2-x1 10], 'LineStyle', 'None', 'FaceColor', [0 1 0 .1], 'Tag', ['segment_fill_' num2str(j)]);
end

% axes(find_axes_by_plot(handle_obj, 'cycles'));
% x1 = cycle_timestamp(cycle_segment(1));
% x2 = cycle_timestamp(cycle_segment(2));
% plot([x1, x1], [-100 100], 'Color', 'k', 'LineStyle', '-', 'LineWidth', 2, 'Tag', 'segment_cycle_start');
% plot([x2, x2], [-100 100], 'Color', 'k', 'LineStyle', '-', 'LineWidth', 2, 'Tag', 'segment_cycle_end'); 
% rectangle('Position', [x1 -100 x2-x1 200], 'LineStyle', 'None', 'FaceColor', [0 1 0 .1], 'Tag', 'segment_cycle_fill');

end
