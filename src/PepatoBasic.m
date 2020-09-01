classdef PepatoBasic
    
    properties
        data;
        config;
        database_path;
        
        input_folder;
        output_folder;
        
        body_side;
        muscle_list;
        condition_list = {'speed2kmh', 'speed4kmh', 'speed6kmh'};
        N_clusters = 4;
        
        FileDat;
    end
    
    methods
        
        function obj = init(obj, input_folder, output_folder, body_side, config_params, database_path, muscle_list)
            in_ = what(input_folder);
            obj.input_folder = in_.path;
            out_ = what(output_folder);
            obj.output_folder = out_.path;
            
            obj.body_side = body_side;
            obj.config = [];
            obj.database_path = database_path;
            
            if nargin > 6
                obj.muscle_list = muscle_list;
            end
            
            config_ = cell2struct(config_params, {'high_pass', 'low_pass', 'n_points', 'n_synergies_max', 'nnmf_replicates', 'nnmf_stop_criterion'}, 2);
            obj.config.('current_config') = config_;
            obj.data = PepatoData().init(obj, obj.muscle_list);
        end
        
        
        function obj = pipeline(obj, condition_list, N_clusters)
            if nargin > 2
                obj.condition_list = condition_list;
                obj.N_clusters = N_clusters;
            elseif nargin > 1
                obj.condition_list = condition_list;
            end
            
            files = dir(fullfile(obj.input_folder, '*emg.csv'));
            files = struct2cell(files);
            obj.FileDat = files(1, :);
            [obj.FileDat, checked_] = check_filenames(obj.FileDat, obj.input_folder, obj.condition_list);
            if ~checked_
                fprintf('ERROR. CSV or YAML file names in "%s" input folder do not match PEPATO requirements, please see README.md file.\n', obj.input_folder);
            end
            
            [subjects, ~, ~] = get_trial_info(obj.FileDat);
            
            for subject = unique(subjects)
                
                subject_idx = strcmp(subjects, subject);
                obj.data = obj.data.load_data(obj.FileDat(subject_idx), obj.input_folder, obj.body_side);
                
                obj.data = obj.data.spectra_filtering(cell(1, obj.data.n_files));
                obj.data = obj.data.interpolated_envelope();
                obj.data = obj.data.envelope_max_normalization();
                obj.data = obj.data.muscle_synergies();
                try
                    cluster_name = ['clustering_' int2str(obj.N_clusters)];
                    loaded = load(obj.database_path, cluster_name);
                    assert(isequal(obj.muscle_list, loaded.(cluster_name).('muscle_list')));
                    obj.data = obj.data.module_compare(loaded.(cluster_name));
                catch
                    warning('Modules comparison with reference is not available. Database error.');
                end

                obj.data = obj.data.spinal_maps();
                try
                    loaded = load(obj.database_path, 'maps_patterns');
                    obj.data = obj.data.maps_compare(loaded.('maps_patterns'));
                catch
                    warning('Spinal maps comparison with reference is not available. Database error.');
                end
                
                % write results to the output file
                obj.data.write_output_yaml(obj.output_folder, obj.condition_list);
                
                fprintf('Analysis for subject "%s" done. The resultes are saved.\n', subject{:});
            end
        end
        
    end
    
end
