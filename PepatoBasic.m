classdef PepatoBasic
    
    properties
        data;
        config;
        database;
        
        input_folder;
        output_folder;
        
        body_side;
        
        FileDat;
        
        logger = [];
        FontSize = 8;
    end
    
    methods
        
        function obj = init(obj, input_folder, output_folder, body_side, config_params, database_filename, muscle_list)
            in_ = what(input_folder);
            obj.input_folder = in_.path;
            out_ = what(output_folder);
            obj.output_folder = out_.path;
            
            obj.body_side = body_side;
            obj.config = [];
            
            config_ = cell2struct(config_params, {'high_pass', 'low_pass', 'n_points', 'n_synergies_max', 'nnmf_replicates', 'nnmf_stop_criterion'}, 2);
            obj.config.('current_config') = config_;
            obj.data = PepatoData().init(obj, muscle_list);
%             obj.database = DataBase().init(obj, database_filename);
            
        end
        
        
        function obj = upload_data(obj)
            
            files = dir(fullfile(obj.input_folder, '*.csv'));
            files = struct2cell(files);
            obj.FileDat = files(1, :);
            
%             [obj.FileDat, obj.PathDat] = uigetfile('/cd/*.csv', 'Open EMG data', 'Multiselect', 'on');
%             if ischar(obj.FileDat)
%                 obj.FileDat = {obj.FileDat};
%             end
            
            obj.data = obj.data.load_data(obj.FileDat, obj.input_folder, obj.body_side);
        end
        
        
        function obj = pipeline(obj)
            
            obj.data = obj.data.spectra_filtering(cell(1, obj.data.n_files));
            obj.data = obj.data.interpolated_envelope();
            obj.data = obj.data.envelope_max_normalization();
            
            obj.data = obj.data.muscle_synergies(); 
            obj.data = obj.data.spinal_maps();
            
        end
        
        
        function obj = get_output(obj)
            
        end
        
    end
end