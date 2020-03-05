function cycles2drop_new = select_cycles_loop(cycles2drop, emg_normalized, muscle_labels, emg_cleaned, emg_bounds, threshold)

n_emg = size(emg_normalized, 2);
n_cycles = size(emg_bounds, 1);
n_points = size(emg_normalized, 1) / n_cycles;

emg_normalized = emg_normalized(repelem(~cycles2drop, n_points), :);
emg_bounds = emg_bounds(~cycles2drop, :);
n_cycles = size(emg_bounds, 1);

emg_cleaned = emg_cleaned - repelem(mean(emg_cleaned, 1), size(emg_cleaned, 1), 1);


if nargin < 6
    threshold = .6;
end
    
cycles2drop_new = zeros(n_cycles, 1);
[emg_mean, emg_sd, ~, ~] = emg_cycle_averaging(emg_normalized, n_points, 2);

env_corr = zeros(n_cycles, n_emg);
for i = 1:n_emg
    for j = 0:n_cycles-1
        env_corr(j+1,i) = corr(emg_mean(:, i), emg_normalized(j*n_points+1:(j+1)*n_points, i), 'Type', 'Pearson');
    end
end

artifact_channels = env_corr < threshold;
artifact_cycles = find(sum(artifact_channels, 2));

if ~isempty(artifact_cycles)
    fh = figure('name', 'Cycle selection', 'NumberTitle','off'); clf;
    for i = artifact_cycles'
        ax_all = [];
        figure(fh); clf;
        channel_index = find(artifact_channels(i, :)); k = 1;
        for j = channel_index
            ax_curr = subplot(length(channel_index), 1, k); k = k+1;
            plot(linspace(1, n_points, emg_bounds(i,2)-emg_bounds(i,1)+1), emg_cleaned(emg_bounds(i,1):emg_bounds(i,2), j), 'Color', [.5 .5 .5]); alpha(.3); hold on;
            plot(1:n_points, emg_normalized((i-1)*n_points+1:i*n_points, j), 'Color', [0 .447 .741], 'LineWidth', 1.5); 
            plot(1:n_points, emg_mean(:, j), 'Color', 'r', 'LineWidth', 1.5); 
            make_fill = fill([1:n_points fliplr(1:n_points)],[max((emg_mean(:, j) - emg_sd(:, j))', zeros(1,n_points)) fliplr((emg_mean(:, j) + emg_sd(:, j))')], [.85 .325 .098], 'EdgeColor','None'); alpha .3;
            if k == 2
                title(sprintf('Suspicious EMG for movement cycle # %d', i));
                legend(sprintf('Raw EMG (cycle # %d)', i), sprintf('EMG envelope (cycle # %d)', i),'Average EMG ± SD','Location','best');
            end
            ylabel(muscle_labels(j));
            ax_all = [ax_all, ax_curr];
        end
        linkaxes(ax_all, 'x'); % linking of subplot axes for X-axis
        m = menu('Drop this cycle?', 'Yes', 'No', '-- Stop selection --');
        if m ~= 3
            cycles2drop_new(i) = mod(m, 2);
        else
            break
        end
    end
    close(fh);
else
    disp('Suspicious cycles not found.');
end
end