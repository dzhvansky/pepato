% function fig_emg(handle_obj, colors, emg_data, emg_timestamp, emg_framerate, emg_label, alpha_transp, ylimits)
function fig_emg(handle_obj, colors, emg_data, emg_timestamp, emg_bounds, emg_framerate, emg_label, alpha_transp, ylimits)

emg_data = emg_data - repelem(mean(emg_data, 1), size(emg_data, 1), 1);

n_emg = size(emg_data, 2);
% if nargin < 7
%     alpha_transp = .3;
%     ylimits = [quantile(min(emg_data, [], 1), .1), quantile(max(emg_data, [], 1), .9)];
% elseif nargin < 8
%     ylimits = [quantile(min(emg_data, [], 1), .1), quantile(max(emg_data, [], 1), .9)];
% end
if nargin < 8
    alpha_transp = .3;
    ylimits = [quantile(min(emg_data, [], 1), .1), quantile(max(emg_data, [], 1), .9)];
elseif nargin < 9
    ylimits = [quantile(min(emg_data, [], 1), .1), quantile(max(emg_data, [], 1), .9)];
end

[psd_emg, f] = emg_spectra(emg_data, emg_framerate);
scaler = max(max(psd_emg));


axes('Parent', handle_obj);

ystart = zeros(size(emg_bounds, 1), 1) - 5;
ystop = zeros(size(emg_bounds, 1), 1) + 5;

for i = 1:n_emg
    subplot('Position', [.05, .1+(n_emg-i)*.85/n_emg, .72, .8/n_emg]);
    
    plot(emg_timestamp, emg_data(:,i), 'Color', colors(i,:), 'Tag', ['emg_' num2str(i)]); alpha(alpha_transp); hold on;
    
    ylabel(emg_label{i}, 'Rotation', 0, 'VerticalAlignment','middle', 'HorizontalAlignment','right');
    if i == 1
        
    end
    
    if exist('ylimits','var')
        ylim(ylimits); axis(axis); 
    end
        
    if i<n_emg
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
    else
        xlabel('sec'); ylabel(sprintf(['[mV]\n' emg_label{i} '\n']), 'Rotation', 0, 'VerticalAlignment','middle', 'HorizontalAlignment','right');
    end
    
    % draw cycle bounds
    tx_start = [emg_timestamp(emg_bounds(:,1)'); emg_timestamp(emg_bounds(:,1)'); nan(1, length(emg_bounds(:,1)))];
    tx_stop = [emg_timestamp(emg_bounds(:,2)'); emg_timestamp(emg_bounds(:,2)'); nan(1, length(emg_bounds(:,2)))];
    ty = [ystart.'; ystop.'; nan(1, size(emg_bounds, 1))];
    
    plot(tx_start(:), ty(:), 'Color', [.9 .9 .9]); alpha(.2);
    plot(tx_stop(:), ty(:), 'Color', [.9 .9 .9], 'LineStyle', '--'); alpha(.2);
end

linkaxes(find_axes_by_plot(handle_obj, 'emg_*'), 'xy'); % linking of subplot axes for XY-axis


for i = 1:n_emg
    subplot('Position', [.8, .1+(n_emg-i)*.85/n_emg, .18, .8/n_emg]);
    plot(f, psd_emg(:,i), 'Color', colors(i,:), 'Tag', ['spectra_' num2str(i)]);
    xlim([0 f(end)]); ylim([0 scaler]); axis(axis); hold on;
    
    if i<n_emg
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
    else
        xlabel('Hz'); ylabel('[PSD]');
    end
end

linkaxes(find_axes_by_plot(handle_obj, 'spectra_*'), 'xy');  % linking of subplot axes for XY-axis

end