function muscle_index = select_muscles(fig_handle, colors, emg_data, emg_bounds, emg_timestamp, emg_label)

n_emg = size(emg_data, 2);
n_cycles = size(emg_bounds, 1);
muscle_index = ones(1, n_emg);

ylimits = [min(min(emg_data, [], 1)), max(max(emg_data, [], 1))];

axes('Parent', fig_handle);

ystart = zeros(size(emg_bounds, 1), 1) - 5;
ystop = zeros(size(emg_bounds, 1), 1) + 5;
for i = 1:n_emg
    subplot('Position', [.1, .1+(n_emg-i)*.8/n_emg, .88, .75/n_emg]);
    
    plot(emg_timestamp, emg_data(:,i), 'Color', colors(i,:), 'Tag', ['emg_' int2str(i)]); ylim(ylimits); axis(axis); hold on;
    
    tx_start = [emg_timestamp(emg_bounds(:,1)'); emg_timestamp(emg_bounds(:,1)'); nan(1, length(emg_bounds(:,1)))];
    tx_stop = [emg_timestamp(emg_bounds(:,2)'); emg_timestamp(emg_bounds(:,2)'); nan(1, length(emg_bounds(:,2)))];
    ty = [ystart.'; ystop.'; nan(1, size(emg_bounds, 1))];
    
    plot(tx_start(:), ty(:), 'Color', [.9 .9 .9]); alpha(.2);
    plot(tx_stop(:), ty(:), 'Color', [.9 .9 .9], 'LineStyle', '--'); alpha(.2);
    
    ylabel(emg_label{i}, 'Rotation', 0, 'VerticalAlignment','middle', 'HorizontalAlignment','right');

    if i<n_emg
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
    else
        xlabel('sec'); ylabel(sprintf([ '[mV]\n' emg_label{i} '\n']), 'Rotation', 0, 'VerticalAlignment','middle', 'HorizontalAlignment','right');
    end
end

linkaxes(find_axes_by_plot(fig_handle, 'emg_*'), 'xy'); % linking of subplot axes for XY-axis


cfch = get(gcf, 'children');
tg = get(cfch(1), 'children');
seltab = tg.SelectedTab;
annotation(seltab, 'textbox', [.1 .92 .8 .06], 'String', 'Select muscles to drop from the further analisys, and then push "Finish"', 'Color', 'k', 'FontSize', 10, 'EdgeColor','None', 'HorizontalAlignment', 'left');

for i = 1:n_emg
    btnD(i) = uicontrol(fig_handle, 'Style', 'pushbutton', 'String', emg_label{i}, 'FontSize', 8, 'Units', 'normal', 'Position', [.01, .1+(n_emg-i)*.8/n_emg, .04, .75/n_emg]);
    btnD(i).Callback = @btnD_pushed;
end

btnRS = uicontrol(fig_handle, 'Style', 'pushbutton', 'String', 'Reset', 'FontSize', 8, 'Units', 'normal', 'Position', [.01, .92, .04, .06]);
btnRS.Callback = @btnRS_pushed;

btnFIN = uicontrol(fig_handle, 'Style', 'pushbutton', 'String', 'Finish selection', 'FontSize', 8, 'Units', 'normal', 'Position', [.8, .92, .18, .06]);
btnFIN.Callback = @btnFIN_pushed;

all_axes = findobj(allchild(fig_handle), 'flat', 'Type', 'axes');

function btnD_pushed(src, event)
    n_button = find(~cellfun(@isempty, strfind(emg_label, src.String)));
    delete(btnD(n_button));
    delete(find_axes_by_plot(fig_handle, ['^emg_' int2str(n_button) '$']));
    muscle_index(1, n_button) = 0;
end

function btnRS_pushed(src, event)
    delete(all_axes);
    for n_button = find(muscle_index)
        delete(btnD(n_button));
    end
    muscle_index = select_muscles(fig_handle, colors, emg_data, emg_bounds, emg_timestamp, emg_label);
end

function btnFIN_pushed(src, event)
    for n_button = find(muscle_index)
        btnD(n_button).Enable = 'off';
    end
    btnRS.Enable = 'off';
    btnFIN.Enable = 'off';
    uiresume();
end

uiwait();

muscle_index = find(muscle_index);

end