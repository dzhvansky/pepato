function freq2filt = select_freq2filt(handle_obj, colors, emg_data, emg_framerate, emg_label, freq2filt, high_pass, low_pass)
n_emg = size(emg_data, 2);

[psd_emg, f] = emg_spectra(emg_data, emg_framerate);
scaler = max(max(psd_emg));

axes('Parent', handle_obj);

for i = 1:n_emg
    ax(i) = subplot('Position', [.14, .12+(n_emg-i)*.8/n_emg, .72, .75/n_emg]);
    plt(i) = plot(f, psd_emg(:,i), 'Color', colors(i,:), 'Tag', ['psd_raw_' num2str(i)]);
    xlim([0 emg_framerate/2]);
    ylim([0 scaler]);
    ylabel(sprintf([emg_label{i} '\n']), 'Rotation', 0, 'VerticalAlignment','middle', 'HorizontalAlignment','right');
    axis(axis); hold on;
    
    rect_h(i) = rectangle('Position', [0 0 high_pass scaler], 'LineStyle', 'None', 'FaceColor', [1 0 0 .15]);
    rect_l(i) = rectangle('Position', [low_pass 0 f(end)-low_pass scaler], 'LineStyle', 'None', 'FaceColor', [1 0 0 .15]);
    
    if i<n_emg
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
    else
        xlabel('sec'); ylabel(sprintf([ '[PSD]\n' emg_label{i} '\n']), 'Rotation', 0, 'VerticalAlignment','middle', 'HorizontalAlignment','right');
    end
end
linkaxes(find_axes_by_plot(handle_obj, 'psd_raw_*'), 'xy'); % linking of subplot axes for X-axis


freq2filt_accept = ones(1, size(freq2filt,2));

for i = 1:size(freq2filt,2)
    for j = 1:n_emg
        rect(i,j) = rectangle('Parent', ax(j), 'Position', [freq2filt(1,i) 0 freq2filt(2,i)-freq2filt(1,i) scaler], 'LineStyle', 'None', 'FaceColor', [1 0 0 .15]);
    end
    
    carr_freq = (freq2filt(1,i) + freq2filt(2,i)) / 2;
    band_width = freq2filt(2,i)-freq2filt(1,i);
    
    m = menu(sprintf(['Accept band cut at a carrier frequence of ' num2str(carr_freq, '%.2f') ' Hz and a width of ' num2str(band_width, '%.2f') ' Hz:']), 'Yes', 'No');
    if m == 2
        delete(rect(i,:));
        freq2filt_accept(i) = 0;
    end
end

freq2filt = reshape(freq2filt([freq2filt_accept>0; freq2filt_accept>0]), 2, []);


emg_data_filtered = filter_emg(emg_data, emg_framerate, high_pass, low_pass, freq2filt);


[psd_emg_hl_bc, f] = emg_spectra(emg_data_filtered, emg_framerate);
scaler = max(max(psd_emg_hl_bc));
    
delete(plt);
for i = 1:n_emg
    plot(f, psd_emg_hl_bc(:,i), 'Parent', ax(i), 'Color', colors(i,:), 'Tag', ['psd_filt_' num2str(i)]);
    set(gca, 'XTickMode', 'auto', 'XTickLabelMode', 'auto', 'YTickMode', 'auto', 'YTickLabelMode', 'auto');
    xlim([0 emg_framerate/2]);
    ylim([0 scaler]);
    ylabel(sprintf([emg_label{i} '\n']), 'Rotation', 0, 'VerticalAlignment','middle', 'HorizontalAlignment','right');
    hold on; 
    
    if i<n_emg
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
    else
        xlabel('Hz'); ylabel(sprintf([ '[PSD]\n' emg_label{i} '\n']), 'Rotation', 0, 'VerticalAlignment','middle', 'HorizontalAlignment','right');
    end
    
end
linkaxes(find_axes_by_plot(handle_obj, 'psd_filt_*'), 'xy'); % linking of subplot axes for X-axis

end
