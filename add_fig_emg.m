function add_fig_emg(handle_obj, data, col, alpha_transp)
n_emg = size(data, 2);
if nargin < 3
    col = [0 0 0]; alpha_transp = .4;
elseif nargin < 4
    alpha_transp = .4;
end

axes('Parent', handle_obj);

for i = 1:n_emg
    subplot(n_emg, 1, i);
    plot(data(:,i), 'Color', col); alpha(alpha_transp);
end
end