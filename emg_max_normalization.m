function emg_max = emg_max_normalization(emg_max, emg_label, all_labels, n_files)

emg_max_all = zeros(size(all_labels));
        
for j = 1 : size(all_labels, 2)
    for i = 1 : n_files
        for k = 1 : size(emg_max{i}, 2)

            if strcmp(all_labels{j}, emg_label{i}{k})
                emg_max_all(j) = max([emg_max_all(j) emg_max{i}(k)]);
            end

        end
    end
end

for j = 1 : size(all_labels, 2)
    for i = 1 : n_files                
        for k = 1 : size(emg_max{i}, 2)

            if strcmp(all_labels{j}, emg_label{i}{k})
                emg_max{i}(k) = emg_max_all(j);
            end

        end
    end
end

end