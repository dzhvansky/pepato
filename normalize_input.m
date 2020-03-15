% function [emg_data, emg_label, muscle_index, warn_labels] = normalize_input(emg_data, emg_label, all_labels)
function [emg_data, emg_label, muscle_index, warn_labels] = normalize_input(emg_data, emg_label, all_labels, body_side)

if sum(~cellfun(@isempty, regexp(emg_label, ['_' body_side '$']))) > 0
    emg_label = cellfun(@(x) x(1:end-1-length(body_side)), emg_label, 'UniformOutput', false); 
%     all_labels = strcat(all_labels, ['_' body_side]);

warn_labels = {};

idx = zeros(1, length(emg_label));
for i = 1:length(emg_label)
    index = find(ismember(all_labels, emg_label{i}), 1);
    if isempty(index)
        warn_labels = [warn_labels, emg_label{i}];
    else
        idx(1, i) = index;
    end    
end

[out, idx] = sort(idx);
idx = idx(out > 0);

emg_data = emg_data(:, idx);
emg_label = emg_label(idx);

muscle_index = idx;

if ~ isempty(warn_labels)
    warn_labels = strjoin(warn_labels, ', ');
end

end