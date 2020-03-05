classdef PepatoData
  
    properties
        
        parent_obj;
        
        n_files;        
        filenames;
        
        output_data;
        
        emg_data_raw;
        emg_data_cleaned;
        emg_timestamp;
        emg_framerate;
        emg_label;
        
%         cycle_separator;
%         cycle_timestamp;
%         point_framerate;
        
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
        
        colors;
        muscles;
        
        all_muscles;
        all_labels;
        all_colors;         
        
        output_params;
        
        logger;
        config;
                
    end

    methods
        
        function obj = init(obj, parent_obj)
            obj.parent_obj = parent_obj;
            obj.logger = obj.parent_obj.logger;            
            
            obj.all_muscles = {'gluteus maximus', 'tensor fascia latae', 'biceps femoris', 'semitendinosus', ...
                'vastus medialis', 'vastus lateralis', 'rectus femoris', 'tibialis anterior', ...
                'peroneus longus', 'gastrocnemius medialis', 'gastrocnemius lateralis', 'soleus'};
            obj.all_labels = {'GlMa', 'TeFa', 'BiFe', 'SeTe', 'VaMe', 'VaLa', 'ReFe', 'TiAn', 'PeLo', 'GaMe', 'GaLa', 'Sol'};
            
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
            
            obj.output_params = {'muscle_synergy_number', 'emg_reco_quality', 'pattern_fwhm', 'pattern_coa',... 
                'muscle_module_similarity', 'motor_pool_max_activation', 'motor_pool_fwhm', 'motor_pool_coact_index', 'motor_pool_similarity'};
            
            obj.parent_obj.data = obj;
        end
        
        
        function obj = load_data(obj, FileDat, PathDat, body_side) 
            obj.config = obj.parent_obj.config.current_config;
            
            obj = obj.files_(FileDat); 
                        
            obj.emg_data_raw = cell(1, obj.n_files);
            obj.emg_timestamp = cell(1, obj.n_files);
%             obj.cycle_separator = cell(1, obj.n_files);
%             obj.cycle_timestamp = cell(1, obj.n_files);
            obj.emg_label = cell(1, obj.n_files);
            obj.emg_framerate = cell(1, obj.n_files);
%             obj.point_framerate = cell(1, obj.n_files);
            
            obj.muscles = cell(1, obj.n_files);
            obj.colors = cell(1, obj.n_files);
            
            obj.emg_bounds = cell(1, obj.n_files);            
            
            for i = 1 : obj.n_files
%                 filename = [PathDat FileDat{i}];
                
%                 [obj.emg_data_raw{i}, obj.emg_timestamp{i}, obj.cycle_separator{i}, obj.cycle_timestamp{i}, obj.emg_label{i}, obj.emg_framerate{i}, obj.point_framerate{i}] = load_data(filename, body_side); 
                [obj.emg_data_raw{i}, obj.emg_timestamp{i}, obj.emg_bounds{i}, obj.emg_label{i}, obj.emg_framerate{i}] = load_csv_yaml_data(PathDat, FileDat{i}, body_side); 

%                 [obj.emg_data_raw{i}, obj.emg_label{i}, muscle_index, warn_labels] = normalize_input(obj.emg_data_raw{i}, obj.emg_label{i}, obj.all_labels);
                [obj.emg_data_raw{i}, obj.emg_label{i}, muscle_index, warn_labels] = normalize_input(obj.emg_data_raw{i}, obj.emg_label{i}, obj.all_labels, body_side);
                if ~ isempty(warn_labels)
                    obj.logger.message('WARNING', sprintf('%s: labels [%s] are not in PEPATO muscle labels\nLabels must be among [%s]', FileDat{i}, warn_labels, strjoin(obj.all_labels, ', ')));
                end
                obj.muscles{i} = obj.all_muscles(muscle_index);
                obj.colors{i} = obj.all_colors(muscle_index, :);
                
%                 if ~isempty(strfind(FileDat{i}, '_2_'))
%                     gait_freq = 0.75;
%                 elseif ~isempty(strfind(FileDat{i}, '_4_'))
%                     gait_freq = 1.5;
%                 elseif ~isempty(strfind(FileDat{i}, '_6_'))
%                     gait_freq = 2.25;                    
%                 end
%                 
%                 obj.emg_bounds{i} = cycle_detection(obj.cycle_separator{i}, obj.emg_framerate{i}, obj.point_framerate{i}, gait_freq);                
            end
            obj.parent_obj.data = obj;
        end
        
        
        function obj = segment_selection(obj, time_bounds)        
            for i = 1 : obj.n_files
                if ~ isempty(obj.emg_data_cleaned)
%                     [obj.emg_data_cleaned{i}, ~, ~] = segment_selection(obj.emg_data_cleaned{i}, obj.emg_bounds{i}, obj.emg_timestamp{i}, obj.emg_framerate{i}, obj.point_framerate{i}, time_bounds{i});
                    [obj.emg_data_cleaned{i}, ~, ~] = segment_selection(obj.emg_data_cleaned{i}, obj.emg_bounds{i}, obj.emg_timestamp{i}, obj.emg_framerate{i}, time_bounds{i});
                end
%                 [obj.emg_data_raw{i}, obj.emg_bounds{i}, obj.emg_timestamp{i}] = segment_selection(obj.emg_data_raw{i}, obj.emg_bounds{i}, obj.emg_timestamp{i}, obj.emg_framerate{i}, obj.point_framerate{i}, time_bounds{i});
                [obj.emg_data_raw{i}, obj.emg_bounds{i}, obj.emg_timestamp{i}] = segment_selection(obj.emg_data_raw{i}, obj.emg_bounds{i}, obj.emg_timestamp{i}, obj.emg_framerate{i}, time_bounds{i});
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
                obj.muscles{i} = obj.muscles{i}(selected_muscles{i});
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
            obj.emg_max = emg_max_normalization(obj.emg_max, obj.emg_label, obj.all_labels, obj.n_files);
            
            obj.parent_obj.data = obj;
        end
        
        
        function obj = muscle_synergies(obj) 
            
            obj.emg_patterns = cell(1, obj.n_files);
            obj.emg_patterns_sd = cell(1, obj.n_files);
            obj.basic_patterns = cell(1, obj.n_files);
            obj.basic_patterns_sd = cell(1, obj.n_files);
            obj.muscle_weightings = cell(1, obj.n_files);
            obj.nmf_r2 = cell(1, obj.n_files);
            
            for i = 1 : obj.n_files
                N_points = obj.config.n_points;
                emg_enveloped_normalized = obj.emg_enveloped{i} ./ repelem(obj.emg_max{i}, size(obj.emg_enveloped{i}, 1), 1);
                
                [n_synergies, obj.nmf_r2{i}] = compute_n_synergies(emg_enveloped_normalized, N_points, obj.config.n_synergies_max, obj.config.nnmf_replicates, obj.config.nnmf_stop_criterion);

                [obj.muscle_weightings{i}, temporal_components, ~] = nmf_emg(emg_enveloped_normalized, n_synergies, N_points, obj.config.nnmf_replicates);

                [obj.emg_patterns{i}, obj.emg_patterns_sd{i}, ~, ~] = emg_cycle_averaging(emg_enveloped_normalized, N_points, 2);
                [obj.basic_patterns{i}, obj.basic_patterns_sd{i}, ~, ~] = emg_cycle_averaging(temporal_components', N_points, 2);

                [fwhm, coa] = pattern_analisys(obj.basic_patterns{i}, N_points);

%                 obj.output_data(i).data.emg_label = obj.emg_label{i};
%                 obj.output_data(i).data.SYN_basic_patterns = obj.basic_patterns{i};
                obj.output_data(i).data.('muscle_synergy_number') = n_synergies;
                obj.output_data(i).data.('emg_reco_quality') = obj.nmf_r2{i}(n_synergies, 1);            
                obj.output_data(i).data.('pattern_fwhm') = mean(fwhm, 1);
                obj.output_data(i).data.('pattern_coa') = mean(coa, 1);
                obj.output_data(i).data.('muscle_module_similarity') = [];
            end
            
            obj.parent_obj.data = obj;
        end
        
        
        function obj = spinal_maps(obj)
            N_points = obj.config.n_points;
            
            obj.motorpools_activation = cell(1, obj.n_files);
            obj.motorpools_activation_avg = cell(1, obj.n_files);
            
            for i = 1 : obj.n_files
                %  emg_enveloped_normalized = emg_enveloped{i} ./ repelem(emg_max{i}, size(emg_enveloped{i}, 1), 1);

                [emg_mean, ~, ~, ~] = emg_cycle_averaging(obj.emg_enveloped{i}, N_points, 2);

                obj.motorpools_activation{i} = spinalcord_detailed_sharrard(emg_mean', obj.emg_label{i});       
                obj.motorpools_activation_avg{i} = squeeze(mean(reshape(obj.motorpools_activation{i}, [6 6 size(obj.motorpools_activation{i}, 2)]), 1));                      

                sacral = mean(obj.motorpools_activation_avg{i}(1:2, :), 1);
                lumbar = mean(obj.motorpools_activation_avg{i}(4:5, :), 1);

                [~, sacral_max] = max(sacral);
                sacral_max = sacral_max / N_points * 100;
                [~, lumbar_max] = max(lumbar);
                lumbar_max = lumbar_max / N_points * 100;
                [sacral_fwhm, ~] = pattern_analisys(sacral', N_points);
                [lumbar_fwhm, ~] = pattern_analisys(lumbar', N_points);

                CI = co_activation_index(sacral, lumbar);

                obj.output_data(i).data.('motor_pool_max_activation') = [sacral_max lumbar_max];
                obj.output_data(i).data.('motor_pool_fwhm') = [sacral_fwhm lumbar_fwhm];
                obj.output_data(i).data.('motor_pool_coact_index') = CI;
                obj.output_data(i).data.('motor_pool_similarity') = [];
            end
            
            obj.parent_obj.data = obj;
        end
        
        
        function obj = reset(obj)
            
            obj.config = [];
            
            obj.output_data = [];

            obj.emg_data_raw = [];
            obj.emg_data_cleaned = [];
            obj.emg_timestamp = [];
            obj.emg_framerate = [];
            obj.emg_label = [];

%             obj.cycle_separator = [];
%             obj.cycle_timestamp = [];
%             obj.point_framerate = [];

            obj.freq2filt = [];

            obj.emg_bounds = [];

            obj.emg_enveloped = [];
            obj.emg_max = [];

            obj.muscle_weightings = [];
            obj.basic_patterns = [];
            obj.motorpools_activation = [];
            obj.motorpools_activation_avg = [];
            
            obj.parent_obj.data = obj;
        end
        
        
        function obj = files_(obj, FileDat)
        
            obj.n_files = size(FileDat, 2);
            obj.filenames = cell(1, obj.n_files);
            
            for i = 1 : obj.n_files
                obj.filenames{1, i} = FileDat{1, i}(1:end-4); % cut file extension (csv by default)
            end            
            
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