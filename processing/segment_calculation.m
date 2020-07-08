function emg_segment = segment_calculation(time_bounds, emg_framerate, emg_index_max)

emg_segment = zeros(size(time_bounds));

for i = 1 : size(time_bounds, 1)
    emg_segment(i, :) = [max([round(emg_framerate * time_bounds(i,1)), 1]); ...
        min([round(emg_framerate * time_bounds(i,2)), emg_index_max])];
end

end