function cycles2drop = select_cycles(emg_normalized, muscle_labels, emg_cleaned, emg_bounds, threshold)

n_cycles = size(emg_bounds, 1);

cycles2drop = select_cycles_loop(zeros(n_cycles, 1), emg_normalized, muscle_labels, emg_cleaned, emg_bounds, threshold);

cycles2drop_buffer = 1;
while sum(cycles2drop_buffer) > 0
    cycles2drop_buffer = select_cycles_loop(cycles2drop, emg_normalized, muscle_labels, emg_cleaned, emg_bounds, threshold);
    cycles2drop(cycles2drop==0) = cycles2drop(cycles2drop==0) + cycles2drop_buffer;
end

end