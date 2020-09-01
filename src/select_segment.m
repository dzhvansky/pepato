function [emg_data, emg_bounds, emg_timestamp] = select_segment(emg_data, emg_bounds, emg_timestamp, emg_framerate, time_bounds)

emg_segment = segment_calculation(time_bounds, emg_framerate, size(emg_data, 1));

time_list = [];
new_emg_segment = [];
segment_lengths = [1];

left_bound = emg_segment(1, 1);
for i = 1 : size(emg_segment, 1) - 1 
    right_bound = emg_bounds(find(emg_bounds(:, 2) <= emg_segment(i, 2), 1, 'last'), 2);
    time_list = [time_list, left_bound : right_bound];
    new_emg_segment = [new_emg_segment; left_bound, right_bound];
    segment_lengths = [segment_lengths, (right_bound - left_bound + 1)];
    left_bound = emg_bounds(find(emg_bounds(:, 1) >= emg_segment(i+1, 1), 1, 'first'), 1);
end
right_bound = emg_segment(end, 2);
time_list = [time_list, left_bound : right_bound];
new_emg_segment = [new_emg_segment; left_bound, right_bound];
segment_lengths = [segment_lengths, (right_bound - left_bound + 1)];


emg_data = emg_data(time_list, :);
emg_timestamp = emg_timestamp(1, time_list);

new_emg_bounds = [];
for i = 1 : size(emg_segment, 1)
    idx_start = find(emg_bounds(:, 1) >= emg_segment(i, 1), 1, 'first');
    idx_end = find(emg_bounds(:, 2) <= emg_segment(i, 2), 1, 'last');
    new_emg_bounds = [new_emg_bounds; emg_bounds(idx_start : idx_end, :) - new_emg_segment(i, 1) + sum(segment_lengths(1, 1:i))];
end

emg_bounds = new_emg_bounds;

end
