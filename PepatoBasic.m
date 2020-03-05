classdef PepatoBasic
    
    properties
        data;
        config;
        database;
        
        body_side;
        
        FileDat;
        PathDat;
        
        logger = [];
        FontSize = 8;
    end
    
    methods
        
        function obj = init(obj, body_side)
            obj.body_side = body_side;
            
%             figure_handle = figure('name', 'PEPATO application', 'NumberTitle', 'off', 'Units', 'normal', 'OuterPosition', [0 0 1 1]); clf;
%             set(figure_handle, 'Units', 'characters');
%             logging_panel = uipanel(figure_handle, 'Title', 'Log','Units', 'normal', 'Position', [.0 .0 1. 1.], 'FontSize', obj.FontSize+2);
%             obj.logger = Logger().init_log(obj, logging_panel, 'PEPATO', 'descending', obj.FontSize);
            
            obj.config = [];
%             obj.config.('current_config') = cell2table({20, 400, 200, 8, 10, 'N=4'}, ...
%                 'VariableNames', {'high_pass', 'low_pass', 'n_points', 'n_synergies_max', 'nnmf_replicates', 'nnmf_stop_criterion'}, ...
%                 'RowNames', {'default'});
            config_ = cell2struct({20, 400, 200, 8, 10, 'N=4'}, {'high_pass', 'low_pass', 'n_points', 'n_synergies_max', 'nnmf_replicates', 'nnmf_stop_criterion'}, 2);
            obj.config.('current_config') = config_;
            obj.data = PepatoData().init(obj);
%             obj.database = DataBase().init(obj, 'database.mat');
            
        end
        
        
        function obj = upload_data(obj)
            [obj.FileDat, obj.PathDat] = uigetfile('/cd/*.csv', 'Open EMG data', 'Multiselect', 'on');
            if ischar(obj.FileDat)
                obj.FileDat = {obj.FileDat};
            end
            
            obj.data = obj.data.load_data(obj.FileDat, obj.PathDat, obj.body_side);
        end
        
        
        function obj = pipeline(obj)
            
            obj.data = obj.data.spectra_filtering(cell(1, obj.data.n_files));
            obj.data = obj.data.interpolated_envelope();
            obj.data = obj.data.envelope_max_normalization();
            
            obj.data = obj.data.muscle_synergies(); 
            obj.data = obj.data.spinal_maps();
            
        end
        
    end
end