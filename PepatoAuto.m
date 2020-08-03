classdef PepatoAuto < handle
    
    properties
        
        file_extension = 'csv';
        body_side; 
        
        data;
        config;
        database;
        
        figure_handle;
        
        load_type = 'raw';
        restart_pipeline = 'Yes';
        
        FileDat;
        PathDat;
        
        FontSize;
        
        proc_pipeline;    
        
        criteria_list;
        
        yes_no_question_opts;
        
        logger;
                
    end
    
    
    methods
        
        function obj = PepatoAuto(FontSize, body_side, config_filename, database_filename, muscle_list)
            
            if nargin < 5 || isempty(muscle_list)
                muscle_list_to_print = {''};
            else
                muscle_list_to_print = muscle_list;
            end
            
            obj.body_side = body_side;
            
            obj.figure_handle = figure('name', 'PEPATO application', 'NumberTitle', 'off', 'Units', 'normal', 'OuterPosition', [0 0 1 1]); clf;
            obj.figure_handle.Units = 'characters';
            
            obj.FontSize = FontSize;
            obj.yes_no_question_opts.Interpreter = 'tex';
            obj.yes_no_question_opts.WindowStyle = 'modal';
            obj.yes_no_question_opts.Default = 'Yes';
            
            logging_panel = uipanel(obj.figure_handle, 'Title', 'Log','Units', 'normal', 'Position', [.0 .0 1. 1.], 'FontSize', obj.FontSize+2);
            obj.logger = Logger().init_log(obj, logging_panel, 'PEPATO', 'descending', obj.FontSize);
            obj.logger.message('INFO', sprintf('PEPATO init parameters: FontSize = %d, body_side = %s, config_filename = %s, database_filename = %s, muscle_list = %s', FontSize, body_side, config_filename, database_filename, strjoin(muscle_list_to_print, ', ')));
            obj.logger.message('INFO', sprintf('MATLAB version: %s', version));
            
            obj.config = Config().init(obj, config_filename, {'high_pass', 'low_pass', 'n_points', 'n_synergies_max', 'nnmf_replicates', 'nnmf_stop_criterion'}, {30, 400, 200, 8, 10, 'N=4'});
            obj.data = PepatoData().init(obj, muscle_list);
            n_basic_patterns = 4;
            obj.database = DataBase().init(obj, database_filename, n_basic_patterns);
            
        end
        
        
        function load_preprocessed(obj, preproc_filename)
            try
                loaded = load(preproc_filename, 'input', 'emg_enveloped', 'emg_label');
                obj.logger.message('INFO', ['Load PEPATO preprocessed data: config and parametrs downloaded from the file ' preproc_filename]);
                obj.config.load_config_from_file(preproc_filename);

                obj.FileDat = loaded.input.FileDat;
                obj.PathDat = loaded.input.PathDat;

                obj.proc_pipeline = loaded.input.proc_pipeline;

                % TODO: ??????? try catch -- delete
                % after using preproc files for
                % database
                try
                    obj.body_side = loaded.input.body_side;
                catch
                    filename_splitted = strsplit(preproc_filename, '_');
                    obj.body_side = filename_splitted{end-1};
                end

                obj.data.emg_enveloped = loaded.emg_enveloped;
                obj.data.emg_label = loaded.emg_label;

                for i = 1 : length(obj.data.emg_enveloped)
                    [obj.data.emg_enveloped{i}, obj.data.emg_label{i}, muscle_index, ~] = normalize_input(obj.data.emg_enveloped{i}, obj.data.emg_label{i}, obj.data.muscle_list, obj.body_side);
                    obj.data.colors{i} = obj.data.all_colors(muscle_index, :);
                end

            catch except
                obj.logger.message('ERROR', 'Loading is possible only from PEPATO generated file', except);
            end

            obj.data.files_(obj.FileDat);
            obj.data.config = obj.config.current_config;
            obj.data.envelope_max_normalization();
        end
        
        
        function analyze_data(obj)
            
            obj.data.muscle_synergies();
%             try
%                 obj.data.module_compare(obj.database.clustering);
%             catch except
%                 obj.logger.message('WARNING', 'Modules comparison with reference is not available. Database error.', except);
%             end
            obj.logger.message('INFO', sprintf('Synergy analysis done. NMF stop criteria: "%s"', obj.data.config.nnmf_stop_criterion{:}));
            
            obj.data.spinal_maps();
%             try
%                 obj.data.maps_compare(obj.database.maps_patterns);
%             catch except
%                 obj.logger.message('WARNING', 'Spinal maps comparison with reference is not available. Database error.', except);
%             end
            obj.logger.message('INFO', 'Spinal maps analysis done.');
            
        end
        
        
        function save_results(obj)
            if ~ isempty(setdiff(obj.data.config, obj.config.current_config))
                old_config_name = obj.data.config.Properties.RowNames{:};
                new_config_name = [old_config_name '_' rand_string_gen(3)];
                obj.data.config.Properties.RowNames = {new_config_name};
            end
            
            input = cell2struct({obj.FileDat, obj.PathDat, obj.proc_pipeline, obj.body_side, obj.data.muscle_list, obj.visual.time_bounds, obj.visual.selected_muscles, obj.visual.freq2filt, obj.visual.cycles2drop}, ...
                {'FileDat', 'PathDat', 'proc_pipeline', 'body_side', 'muscle_list', 'time_bounds', 'selected_muscles', 'freq2filt', 'cycles2drop'}, 2);            
            config = obj.data.config;
            results = obj.data.output_data;           
            
            try
                [output_file, output_path] = uiputfile([obj.PathDat 'pepato_results.mat']);
                output_filename = fullfile(output_path, output_file);
                save(output_filename, 'input', 'config', 'results');
                obj.logger.message('INFO', ['PEPATO analysis saved to the ' output_filename]);
            catch
                obj.logger.message('ERROR', 'Analysis not saved');
            end
        end
        
    end
    
    
end