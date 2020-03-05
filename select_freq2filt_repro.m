function select_freq2filt_repro(handle_obj, colors, emg_data, emg_framerate, emg_label, high_pass, low_pass, freq2filt_accepted)
n_emg = size(emg_data, 2);

axes('Parent', handle_obj);


emg_data_filtered = filter_emg(emg_data, emg_framerate, high_pass, low_pass, freq2filt_accepted);


[psd_emg_hl_bc, f] = emg_spectra(emg_data_filtered, emg_framerate);
scaler = max(max(psd_emg_hl_bc));
    
% delete(plt);
for i = 1:n_emg
    subplot('Position', [.14, .12+(n_emg-i)*.8/n_emg, .72, .75/n_emg]);
    plot(f, psd_emg_hl_bc(:,i), 'Color', colors(i,:), 'Tag', ['psd_filt_' num2str(i)]);
    set(gca, 'XTickMode', 'auto', 'XTickLabelMode', 'auto', 'YTickMode', 'auto', 'YTickLabelMode', 'auto');
    xlim([0 emg_framerate/2]); 
    ylim([0 scaler]);
    ylabel(sprintf([emg_label{i} '\n']), 'Rotation', 0, 'VerticalAlignment','middle', 'HorizontalAlignment','right');
    axis(axis); hold on; 
    
    rect_h(i) = rectangle('Position', [0 0 high_pass scaler], 'LineStyle', 'None', 'FaceColor', [1 0 0 .15]);
    rect_l(i) = rectangle('Position', [low_pass 0 f(end)-low_pass scaler], 'LineStyle', 'None', 'FaceColor', [1 0 0 .15]);
    
    for j = 1:size(freq2filt_accepted, 2)
        rect(j,i) = rectangle('Position', [freq2filt_accepted(1,j) 0 freq2filt_accepted(2,j)-freq2filt_accepted(1,j) scaler], 'LineStyle', 'None', 'FaceColor', [1 0 0 .15]);
    end
    
    if i<n_emg
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
    else
        xlabel('Hz'); ylabel(sprintf([ '[PSD]\n' emg_label{i} '\n']), 'Rotation', 0, 'VerticalAlignment','middle', 'HorizontalAlignment','right');
    end
    
end

linkaxes(find_axes_by_plot(handle_obj, 'psd_filt_*'), 'xy'); % linking of subplot axes for X-axis

end
