classdef PepatoData
  
    properties
        
        parent_obj;
        
        n_files;        
        filenames;
        
        unused_labels;
        
        output_data;
        
        emg_data_raw;
        emg_data_cleaned;
        emg_timestamp;
        emg_framerate;
        emg_label;
        mov_data;
        mov_timestamp;
        
        freq2filt;
        
        emg_bounds;
        
        emg_enveloped;
        emg_max;
        
        emg_patterns;        
        emg_patterns_sd;
        muscle_weightings;
        basic_patterns;
        basic_patterns_sd;
        nmf_r2;
        motorpools_activation;
        motorpools_activation_avg;
        sacral;
        lumbar;
        
        clustering_mode;
        module_info;
        
        colors;
        muscles;
        
        % do not change the order of the muscles here! 
        % (if necessary, you can add muscle anywhere in this list but preserving the original order)
        muscle_list = {'GlMa', 'TeFa', 'BiFe', 'SeTe', 'VaMe', 'VaLa', 'ReFe', 'TiAn', 'PeLo', 'GaMe', 'GaLa', 'Sol'};
        all_colors;         
        
        output_params;
        
        config;
                
    end
    
    
    methods(Static)
        
        function emg_max = max_among_trials(emg_max, emg_label, all_labels, n_files)
            
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
        
    end
    

    methods
        
        function obj = init(obj, parent_obj, muscle_list)
            obj.parent_obj = parent_obj;
            
            if nargin > 2 || ~isempty(muscle_list)
                obj.muscle_list = muscle_list;
            end           
            
            obj.all_colors = [         
                         0    0.4470    0.7410;
                    0.8500    0.3250    0.0980;
                    0.9290    0.6940    0.1250;
                    0.4940    0.1840    0.5560;
                    0.4660    0.6740    0.1880;
                    0.3010    0.7450    0.9330;
                    0.6350    0.0780    0.1840;
                         0    0.4470    0.7410;
                    0.8500    0.3250    0.0980;
                    0.9290    0.6940    0.1250;
                    0.4940    0.1840    0.5560;
                    0.4660    0.6740    0.1880;
                    0.3010    0.7450    0.9330;
                    0.6350    0.0780    0.1840;
                         0    0.4470    0.7410;
                    0.8500    0.3250    0.0980;
                    0.9290    0.6940    0.1250
                    ];
            
            obj.output_params = {'muscle_synergy_number', 'emg_reco_quality', 'pattern_fwhm', 'pattern_coa', 'patterns_similarity', 'synergies_similarity', 'matching_standard_reference_index', ...
                'motor_pool_max_activation', 'motor_pool_fwhm', 'motor_pool_coact_index', 'motor_pool_similarity'};
            
            obj.clustering_mode = 'unique'; % options: 'unique', 'common' for condition dependent and independent clustering, respectively
            
            obj.parent_obj.data = obj;
        end
        
        
        function obj = load_data(obj, csv_files, yaml_files, body_side)
            
            obj.config = obj.parent_obj.config.current_config;
            
            obj = obj.files_(csv_files);
                        
            obj.emg_data_raw = cell(1, obj.n_files);
            obj.emg_timestamp = cell(1, obj.n_files);
            obj.emg_label = cell(1, obj.n_files);
            obj.unused_labels = cell(1, obj.n_files);
            obj.emg_framerate = cell(1, obj.n_files);
            obj.mov_data = cell(1, obj.n_files);
            obj.mov_timestamp = cell(1, obj.n_files);
            
            obj.colors = cell(1, obj.n_files);
            
            obj.emg_bounds = cell(1, obj.n_files);            
            
            for i = 1 : obj.n_files
                [obj.emg_data_raw{i}, obj.emg_timestamp{i}, obj.emg_bounds{i}, obj.emg_label{i}, obj.emg_framerate{i}, obj.mov_data{i}, obj.mov_timestamp{i}] = load_csv_yaml_data(csv_files{i}, yaml_files{i}, body_side); 
                [obj.emg_data_raw{i}, obj.emg_label{i}, muscle_index, obj.unused_labels{i}] = normalize_input(obj.emg_data_raw{i}, obj.emg_label{i}, obj.muscle_list, body_side);
                obj.colors{i} = obj.all_colors(muscle_index, :);
            end
            
            obj.parent_obj.data = obj;
        end
        
        
        function obj = segment_selection(obj, time_bounds)        
            for i = 1 : obj.n_files
                if ~ isempty(obj.emg_data_cleaned)
                    [obj.emg_data_cleaned{i}, ~, ~] = select_segment(obj.emg_data_cleaned{i}, obj.emg_bounds{i}, obj.emg_timestamp{i}, obj.emg_framerate{i}, time_bounds{i});
                end
                [obj.emg_data_raw{i}, obj.emg_bounds{i}, obj.emg_timestamp{i}] = select_segment(obj.emg_data_raw{i}, obj.emg_bounds{i}, obj.emg_timestamp{i}, obj.emg_framerate{i}, time_bounds{i});
            end
            obj.parent_obj.data = obj;
        end
        
        
        function obj = muscles_selection(obj, selected_muscles)        
            for i = 1 : obj.n_files
                if ~ isempty(obj.emg_data_cleaned)
                    obj.emg_data_cleaned{i} = obj.emg_data_cleaned{i}(:, selected_muscles{i});
                end
                obj.emg_data_raw{i} = obj.emg_data_raw{i}(:, selected_muscles{i});                
                obj.emg_label{i} = obj.emg_label{i}(selected_muscles{i});
                obj.colors{i} = obj.colors{i}(selected_muscles{i}, :);
            end
            obj.parent_obj.data = obj;
        end
        
        
        function obj = spectra_noises_detection(obj)
            obj.freq2filt = cell(1, obj.n_files);
            for i = 1 : obj.n_files
                obj.freq2filt{i} = find_noise_freq(obj.emg_data_raw{i}, obj.emg_framerate{i}, obj.config.high_pass, obj.config.low_pass);         
            end
            obj.parent_obj.data = obj;
        end
        
        
        function obj = spectra_filtering(obj, freq2filt)
            obj.emg_data_cleaned = cell(1, obj.n_files);
            obj.freq2filt = freq2filt;            
            for i = 1 : obj.n_files
                obj.emg_data_cleaned{i} = filter_emg(obj.emg_data_raw{i}, obj.emg_framerate{i}, obj.config.high_pass, obj.config.low_pass, freq2filt{i});            
            end
            obj.parent_obj.data = obj;
        end
        
        
        function obj = interpolated_envelope(obj)
            obj.emg_enveloped = cell(1, obj.n_files);
            
            if isempty(obj.emg_data_cleaned)
                obj.emg_data_cleaned = obj.emg_data_raw;
            end
            for i = 1 : obj.n_files
                obj.emg_enveloped{i} = emg_envelope(obj.emg_data_cleaned{i}, obj.emg_framerate{i}, 'lowpass', 10);
                obj.emg_enveloped{i} = normalize_emg(obj.emg_enveloped{i}, obj.emg_bounds{i}, obj.config.n_points);           
            end
            
            obj.parent_obj.data = obj;
        end
        
        
        function obj = cycles_selection(obj, cycles2drop)            
            for i = 1 : obj.n_files
                obj.emg_enveloped{i} = obj.emg_enveloped{i}(repelem(~cycles2drop{i}, obj.config.n_points), :);           
            end
            obj.parent_obj.data = obj;
        end
        
        
        function obj = envelope_max_normalization(obj)            
            obj.emg_max = cell(1, obj.n_files);
            for i = 1 : obj.n_files
                obj.emg_max{i} = max(obj.emg_enveloped{i}, [], 1);
            end
            obj.emg_max = obj.max_among_trials(obj.emg_max, obj.emg_label, obj.muscle_list, obj.n_files);
            
            obj.parent_obj.data = obj;
        end
        
        
        function obj = muscle_synergies(obj) 
            
            obj.emg_patterns = cell(1, obj.n_files);
            obj.emg_patterns_sd = cell(1, obj.n_files);
            obj.basic_patterns = cell(1, obj.n_files);
            obj.basic_patterns_sd = cell(1, obj.n_files);
            obj.muscle_weightings = cell(1, obj.n_files);
            obj.nmf_r2 = cell(1, obj.n_files);
            
            obj.module_info = cell(1, obj.n_files);
            
            for i = 1 : obj.n_files
                N_points = obj.config.n_points;
                emg_enveloped_normalized = obj.emg_enveloped{i} ./ repelem(obj.emg_max{i}, size(obj.emg_enveloped{i}, 1), 1);
                
                [n_synergies, obj.nmf_r2{i}] = compute_n_synergies(emg_enveloped_normalized, N_points, obj.config.n_synergies_max, obj.config.nnmf_replicates, obj.config.nnmf_stop_criterion);

                [obj.muscle_weightings{i}, temporal_components, ~] = nmf_emg(emg_enveloped_normalized, n_synergies, N_points, obj.config.nnmf_replicates);

                [obj.emg_patterns{i}, obj.emg_patterns_sd{i}, ~, ~] = emg_cycle_averaging(emg_enveloped_normalized, N_points, 2);
                [obj.basic_patterns{i}, obj.basic_patterns_sd{i}, ~, ~] = emg_cycle_averaging(temporal_components', N_points, 2);

                [fwhm, coa] = pattern_analisys(obj.basic_patterns{i}, N_points);
                
                obj.output_data(i).data.('muscle_synergy_number') = n_synergies;
                obj.output_data(i).data.('emg_reco_quality') = obj.nmf_r2{i}(n_synergies, 1);            
                obj.output_data(i).data.('pattern_fwhm') = mean(fwhm, 1);
                obj.output_data(i).data.('pattern_coa') = mean(coa, 1);
                obj.output_data(i).data.('patterns_similarity') = [];
                obj.output_data(i).data.('synergies_similarity') = [];
                obj.output_data(i).data.('matching_standard_reference_index') = [];
            end
            
            obj.parent_obj.data = obj;
        end
        
        
        function obj = spinal_maps(obj)
            N_points = obj.config.n_points;
            
            obj.motorpools_activation = cell(1, obj.n_files);
            obj.motorpools_activation_avg = cell(1, obj.n_files);
            obj.sacral = cell(1, obj.n_files);
            obj.lumbar = cell(1, obj.n_files);
            
            for i = 1 : obj.n_files
                [emg_mean, ~, ~, ~] = emg_cycle_averaging(obj.emg_enveloped{i}, N_points, 2);

                obj.motorpools_activation{i} = spinalcord_detailed_sharrard(emg_mean', obj.emg_label{i});       
                obj.motorpools_activation_avg{i} = squeeze(mean(reshape(obj.motorpools_activation{i}, [6 6 size(obj.motorpools_activation{i}, 2)]), 1));                      

                obj.sacral{i} = mean(obj.motorpools_activation_avg{i}(1:2, :), 1);
                obj.lumbar{i} = mean(obj.motorpools_activation_avg{i}(4:5, :), 1);

                [~, sacral_max] = max(obj.sacral{i});
                sacral_max = sacral_max / N_points * 100;
                [~, lumbar_max] = max(obj.lumbar{i});
                lumbar_max = lumbar_max / N_points * 100;
                [sacral_fwhm, ~] = pattern_analisys(obj.sacral{i}', N_points);
                [lumbar_fwhm, ~] = pattern_analisys(obj.lumbar{i}', N_points);

                CI = co_activation_index(obj.sacral{i}, obj.lumbar{i});

                obj.output_data(i).data.('motor_pool_max_activation') = [sacral_max lumbar_max];
                obj.output_data(i).data.('motor_pool_fwhm') = [sacral_fwhm lumbar_fwhm];
                obj.output_data(i).data.('motor_pool_coact_index') = CI;
                obj.output_data(i).data.('motor_pool_similarity') = [];
            end
            
            obj.parent_obj.data = obj;
        end
        
        
        function obj = module_compare(obj, clustering)
            [~, ~, conditions] = get_trial_info(obj.filenames);
            n_muscles = length(obj.muscle_list);
            
            for i = 1 : obj.n_files
                if strcmp(obj.clustering_mode, 'unique')
                    cluster_condition = conditions{i};
                elseif strcmp(data.clustering_mode, 'common')
                    cluster_condition = 'all_conditions';
                end
                
                N_clusters = clustering.('N_clusters');
                mean_threshold = clustering.('mean_threshold');
                max_threshold = clustering.('max_threshold');
                cluster_center = clustering.('data').(cluster_condition).('cluster_center');
                scaler_mean = clustering.('data').(cluster_condition).('scaler_mean');
                scaler_std = clustering.('data').(cluster_condition).('scaler_std');
                pattern_reference = clustering.('data').(cluster_condition).('pattern_mean');
                
                [features, ~, ~, ~] = get_cluster_features(obj.muscle_weightings{i}', obj.basic_patterns{i}', scaler_mean, scaler_std);
                n_rows = size(features, 1);
                
                cluster_idx = zeros(n_rows, 1);
                nearest_cluster_dist = zeros(n_rows, 1);
                muscle_module_similarity = zeros(n_rows, N_clusters);
                synergies_similarity = zeros(n_rows, N_clusters);
                patterns_similarity = zeros(n_rows, N_clusters);
                
                for j = 1:n_rows
                    muscle_module_similarity(j, :) = cluster_mean_distance(repmat(features(j, 1:n_muscles), N_clusters, 1), cluster_center(:, 1:n_muscles));
                    [nearest_cluster_dist(j), cluster_idx(j)] = min(muscle_module_similarity(j, :));
                    synergies_similarity(j, :) = get_synergy_similarity(features(j, 1:n_muscles), cluster_center(:, 1:n_muscles));
                    patterns_similarity(j, :) = get_pattern_similarity(obj.basic_patterns{i}(:, j)', pattern_reference);
                end
                include_mask = get_cluster_mask(features(:, 1:n_muscles), cluster_idx, cluster_center(:, 1:n_muscles), mean_threshold, max_threshold);
                
                matching_standard_reference_index = cluster_idx';
                matching_standard_reference_index(~include_mask') = NaN;
                
                module_info_ = cell2struct({include_mask', cluster_idx', nearest_cluster_dist', ...
                    synergies_similarity(sub2ind([n_rows, N_clusters], 1:n_rows, cluster_idx')), ...
                    patterns_similarity(sub2ind([n_rows, N_clusters], 1:n_rows, cluster_idx'))}, ...
                    {'is_clustered', 'n_cluster', 'nearest_cluster_dist', 'best_synergy_similarity', 'best_pattern_similarity'}, 2);
                obj.module_info{i} = module_info_;
                
                obj.output_data(i).data.('patterns_similarity') = patterns_similarity;
                obj.output_data(i).data.('synergies_similarity') = synergies_similarity;
                obj.output_data(i).data.('matching_standard_reference_index') = matching_standard_reference_index;
            end
            
            obj.parent_obj.data = obj;
        end
        
        
        function obj = maps_compare(obj, maps_patterns)
            [~, ~, conditions] = get_trial_info(obj.filenames);
            
            for i = 1 : obj.n_files
                sacral_mean = maps_patterns.(conditions{i}).('sacral').('mean_val');
                lumbar_mean = maps_patterns.(conditions{i}).('lumbar').('mean_val');
                
                mean_pts = length(sacral_mean);
                curr_pts = length(obj.sacral{i});
                if mean_pts ~= curr_pts
                    sacral_mean = interp1(sacral_mean, linspace(1, mean_pts, curr_pts));
                    lumbar_mean = interp1(lumbar_mean, linspace(1, mean_pts, curr_pts));
                end
                
                sacral_corrcoef = corrcoef(sacral_mean, obj.sacral{i});
                lumbar_corrcoef = corrcoef(lumbar_mean, obj.lumbar{i});
                
                obj.output_data(i).data.('motor_pool_similarity') = [sacral_corrcoef(1, 2), lumbar_corrcoef(1, 2)];
            end
            
            obj.parent_obj.data = obj;
        end
        
        
        function obj = write_output_yaml(obj, output_folder, condition_list, write_mode)
            if nargin < 4 || ~strcmp(write_mode, {'single', 'multiple'})
                write_mode = 'single';
            end
            data_types = cell2struct({'vector', 'vector', 'vector_of_vector', 'vector_of_vector', 'vector_of_matricies', 'vector_of_matricies', 'vector_of_vector', ...
                'matrix', 'matrix', 'vector', 'matrix'}, ...
                obj.output_params, 2);
            
            [subjects, trials, conditions] = get_trial_info(obj.filenames);
            assert(length(unique(subjects))==1)
            subject = subjects{1};
            
            for trial = unique(trials)
                trial_idx = strcmp(trials, trial);
                
                wtite_flag = 'w';
                for i = 1 : length(obj.output_params)
                    param_name = obj.output_params{i};
                    param_type = data_types.(param_name);
                    
                    switch write_mode
                        case 'single'
                            fname_postfix = 'output';
                            prefix = '    ';
                        case 'multiple'
                            fname_postfix = param_name;
                            prefix = '';
                    end
                    
                    output_filename = strjoin({'subject', subject, 'run', trial{:}, [fname_postfix, '.yaml']}, '_');
                    fout = fopen(fullfile(output_folder, output_filename), wtite_flag);
                    if strcmp(write_mode, 'single')
                        fprintf(fout, '%s:\n', param_name);
                        wtite_flag = 'a';
                    end
                    
                    n_conditions = length(condition_list);
                    param_output = cell(1, n_conditions);
                    for j = 1: n_conditions
                        condition = condition_list{j};
                        file_idx = find(trial_idx & strcmp(conditions, condition));
                        
                        if ~isempty(file_idx)
                            param_value = obj.output_data(file_idx).data.(param_name);
                            
                            switch param_type
                                case 'vector'
                                    param_output{1, j} = num2str(param_value);
                                case {'matrix', 'vector_of_vector'}
                                    param_output{1, j} = sprintf('[%s]', strjoin(num2str2cell(param_value), ', '));
                                case 'vector_of_matricies'
                                    matrix_rows = {};
                                    for k = 1:size(param_value, 1)
                                        matrix_rows = [matrix_rows, sprintf('[%s]', strjoin(num2str2cell(param_value(k, :)), ', '))];
                                    end
                                    param_output{1, j} = sprintf('[%s]', strjoin(matrix_rows, ', '));
                            end
                                    
                        else
                            switch param_type
                                case 'vector'
                                    param_output{1, j} = 'NaN';
                                case {'matrix', 'vector_of_vector'}
                                    param_output{1, j} = '[NaN]';
                                case 'vector_of_matricies'
                                    param_output{1, j} = '[[NaN]]';
                            end
                        end
                    end
                    
                    fprintf(fout, [prefix 'type: %s\n'], param_type);
                    fprintf(fout, [prefix 'value: [%s]\n'], strjoin(param_output, ', '));
                    fclose(fout);
                end
                
            end
            
        end
        
        
        function obj = reset(obj)
            
            obj.config = [];
            
            obj.output_data = [];

            obj.emg_data_raw = [];
            obj.emg_data_cleaned = [];
            obj.emg_timestamp = [];
            obj.emg_framerate = [];
            obj.emg_label = [];

            obj.freq2filt = [];

            obj.emg_bounds = [];

            obj.emg_enveloped = [];
            obj.emg_max = [];
            
            obj.emg_patterns = [];
            obj.emg_patterns_sd = [];
            obj.muscle_weightings = [];
            obj.basic_patterns = [];
            obj.basic_patterns_sd = [];
            obj.motorpools_activation = [];
            obj.motorpools_activation_avg = [];
            obj.sacral = [];
            obj.lumbar = [];
            obj.module_info = [];
            
            obj.parent_obj.data = obj;
        end
        
        
        function obj = files_(obj, csv_files)
            obj.n_files = length(csv_files);
            obj.filenames = get_filenames(csv_files);
            
            params_struct = cell2struct(cell(size(obj.output_params)), obj.output_params, 2);
            files = cell(obj.n_files, 2);
            for i = 1 : obj.n_files
                files(i, :) = {obj.filenames{i}, params_struct};
            end
            obj.output_data = cell2struct(files, {'name', 'data'}, 2);
            
            obj.parent_obj.data = obj;
        end
        
    end
end