function fig_envelope(handle_obj, emg_normalized, emg_label, n_points, colors, filtered_emg_data, emg_framerate)

n_emg = size(emg_normalized, 2);
n_cycles = size(emg_normalized, 1) / n_points;

ylimits = [0, max(max(emg_normalized, [], 1))];

axes('Parent', handle_obj);

ystart = zeros(n_cycles, 1);
ystop = zeros(n_cycles, 1) + 5;
for i = 1:n_emg
    ax(i) = subplot('Position', [.1, .1+(n_emg-i)*.8/n_emg, .67, .75/n_emg]);
    
    plot(emg_normalized(:,i), 'Color', colors(i,:)); hold on;
    
    tx_start = [1 : n_points : n_cycles*n_points; 1 : n_points : n_cycles*n_points; nan(1, n_cycles)];
    tx_stop = [n_points : n_points : n_cycles*n_points; n_points : n_points : n_cycles*n_points; nan(1, n_cycles)];
    ty = [ystart.'; ystop.'; nan(1, n_cycles)];
    
    plot(tx_start(:), ty(:), 'Color', [.9 .9 .9]); alpha(.2);
    plot(tx_stop(:), ty(:), 'Color', [.9 .9 .9], 'LineStyle', '--'); alpha(.2);
    
    ylabel(emg_label{i}, 'Rotation', 0, 'VerticalAlignment','middle', 'HorizontalAlignment','right');
    
    if exist('ylimits','var')
        ylim(ylimits); axis(axis); 
    end
        
    % grid(ax_curr, 'on');
    if i<n_emg
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
    else
        xlabel('points'); ylabel(sprintf([ '[mV]\n' emg_label{i} '\n']), 'Rotation', 0, 'VerticalAlignment','middle', 'HorizontalAlignment','right');
    end
end

linkaxes(ax, 'xy'); % linking of subplot axes for XY-axis


if exist('filtered_emg_data', 'var') && exist('filtered_emg_data', 'var')
    filtered_emg_data = filtered_emg_data - repelem(mean(filtered_emg_data, 1), size(filtered_emg_data, 1), 1);

    [psd_emg, f] = emg_spectra(filtered_emg_data(), emg_framerate);
    scaler = max(max(psd_emg));
    for i = 1:n_emg
        ax_psd(i) = subplot('Position', [.8, .1+(n_emg-i)*.8/n_emg, .18, .75/n_emg]);
        plot(f, psd_emg(:,i), 'Color', colors(i,:));
        xlim([0 f(end)]); ylim([0 scaler]); axis(axis); hold on;

        if i<n_emg
            set(gca,'xtick',[]);
            set(gca,'ytick',[]);
        else
            xlabel('Hz'); ylabel('[PSD]');
        end
    end

    linkaxes(ax_psd, 'xy'); % linking of subplot axes for XY-axis
end
    
end
