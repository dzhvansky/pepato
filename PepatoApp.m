classdef PepatoApp < handle
    
    properties
        
        file_extension = '.csv';
        body_side; 
        condition_list;
        
        data;
        visual;
        config;
        database;
        
        figure_handle;
        
        load_type = 'raw';
        restart_pipeline = 'Yes';
        
        FileDat;
        PathDat;
        
        FontSize;
        
        menu_item;
        menu_item_config;
        menu_item_mode;
        menu_item_doc;
        menu_item_about;
        
        control_panel;
        visual_panel;
        research_panel;
                
        button_LoadRaw;
        button_LoadProcessed; 
        button_Reproduce;
        
        proc_pipeline;
        button_CropData;
        button_MuscleSelection;
        button_SpectraFiltering;
        button_ArtifactFiltering;
        
        button_Analysis;
        
        button_SaveResults;
        button_SaveProcessed;       
        
        criteria_list;
        button_UpdateDatabase;
        
        yes_no_question_opts;
        
        logger;
                
    end
    
    
    methods
        
        function obj = PepatoApp(FontSize, body_side, config_filename, database_filename, muscle_list)
            
            if nargin < 5 || isempty(muscle_list)
                muscle_list_to_print = {''};
            else
                muscle_list_to_print = muscle_list;
            end
            
            obj.body_side = body_side;
            obj.condition_list = {'speed2kmh', 'speed4kmh', 'speed6kmh'};
            
            obj.figure_handle = figure('name', 'PEPATO application', 'NumberTitle', 'off', 'Units', 'normal', 'OuterPosition', [0 0 1 1]); clf;
            obj.figure_handle.Units = 'characters';
            
            if verLessThan('matlab', '9.5')
                drawnow;
                set(get(obj.figure_handle, 'JavaFrame'), 'Maximized', 1);
            else
                obj.figure_handle.WindowState = 'maximized';
            end
            
            obj.FontSize = FontSize;
            obj.yes_no_question_opts.Interpreter = 'tex';
            obj.yes_no_question_opts.WindowStyle = 'modal';
            obj.yes_no_question_opts.Default = 'Yes';
            
            obj.menu_item = uimenu(obj.figure_handle, 'Label', 'PEPATO');
            obj.menu_item_config = uimenu(obj.menu_item, 'Label', 'Set config', 'Accelerator', 'M', 'Callback', @obj.EditConfig);        
            obj.menu_item_mode = uimenu(obj.menu_item, 'Label', 'Research mode', 'Accelerator', 'R', 'Callback', @obj.ResearchMode);
            obj.menu_item_doc = uimenu(obj.menu_item, 'Label', 'Documentation');
            obj.menu_item_about = uimenu(obj.menu_item, 'Label', 'About');            
            
            logging_panel = uipanel(obj.figure_handle, 'Title', 'Log','Units', 'normal', 'Position', [.1 .0 .9 .1], 'FontSize', obj.FontSize+2);
            obj.logger = Logger().init_log(obj, logging_panel, 'PEPATO', 'descending', obj.FontSize);
            obj.logger.message('INFO', sprintf('PEPATO init parameters: FontSize = %d, body_side = %s, config_filename = %s, database_filename = %s, muscle_list = %s', FontSize, body_side, config_filename, database_filename, strjoin(muscle_list_to_print, ', ')));
            obj.logger.message('INFO', sprintf('MATLAB version: %s', version));
            obj.control_panel = uipanel(obj.figure_handle, 'Title', 'Control Panel', 'BackgroundColor', 'white', 'Units', 'normal', 'Position', [.0 .0 .1 1.], 'FontSize', obj.FontSize+2);
            obj.visual_panel = uipanel(obj.figure_handle, 'Title', 'Visualization', 'BackgroundColor', 'white', 'Units', 'normal', 'Position', [.1 .1 .9 .9], 'FontSize', obj.FontSize+2);
            
            img = imread('eurobench.png'); 
            pax = axes('Parent', obj.control_panel, 'Position', [.05 .0 .9 .1]);
            imagesc(img, 'Parent', pax); 
            set(pax,'xtick',[],'ytick',[]);
            
            
            load_panel = uipanel(obj.control_panel, 'Title', 'Loading', 'Units', 'normal', 'Position', [.05 .85 .9 .14], 'FontSize', obj.FontSize); 
            obj.button_LoadRaw = uicontrol(load_panel,'Style','pushbutton', 'String', 'Load raw data','FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.05 .68972 .9 .27586]);
            obj.button_LoadRaw.Callback = @obj.button_LoadRaw_pushed;
            obj.button_LoadProcessed = uicontrol(load_panel,'Style','pushbutton', 'String', 'Load processed data','FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.05 .37936 .9 .27586]);
            obj.button_LoadProcessed.Callback = @obj.button_LoadProcessed_pushed;
            obj.button_Reproduce = uicontrol(load_panel,'Style','pushbutton', 'String', 'Reproduce analysis', 'FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.05 .069 .9 .27586]);
            obj.button_Reproduce.Callback = @obj.button_Reproduce_pushed;

            process_panel = uipanel(obj.control_panel, 'Title', 'Preprocessing', 'Units', 'normal', 'Position', [.05 .659 .9 .181], 'FontSize', obj.FontSize);
            obj.button_CropData = uicontrol(process_panel,'Style','pushbutton', 'Enable', 'off', 'String', 'Crop data', 'FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.05 .7631 .9 .2105], 'Tag', 'button_crop');
            obj.button_CropData.Callback = @obj.button_CropData_pushed;
            obj.button_MuscleSelection = uicontrol(process_panel,'Style','pushbutton', 'Enable', 'off', 'String', 'Muscles selection', 'FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.05 .5263 .9 .2105], 'Tag', 'button_muscle_sel');
            obj.button_MuscleSelection.Callback = @obj.button_MuscleSelection_pushed;
            obj.button_SpectraFiltering = uicontrol(process_panel,'Style','pushbutton', 'Enable', 'off', 'String', 'Spectral filtering', 'FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.05 .2894 .9 .2105], 'Tag', 'button_spectra_filt');
            obj.button_SpectraFiltering.Callback = @obj.button_SpectraFiltering_pushed;
            obj.button_ArtifactFiltering = uicontrol(process_panel,'Style','pushbutton', 'Enable', 'off', 'String', 'Artifact filtering', 'FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.05 .0526 .9 .2105], 'Tag', 'button_artifact_filt');
            obj.button_ArtifactFiltering.Callback = @obj.button_ArtifactFiltering_pushed;

            analysis_panel = uipanel(obj.control_panel, 'Title', 'Analysis','Units', 'normal', 'Position', [.05 .509 .9 .14], 'FontSize', obj.FontSize);
            obj.button_Analysis=uicontrol(analysis_panel, 'Style', 'pushbutton', 'Enable', 'off','String', 'Analysis', 'FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.05 .069 .9 .8966], 'Tag', 'button_analysis');
            obj.button_Analysis.Callback=@obj.button_Analysis_pushed;

            save_panel = uipanel(obj.control_panel, 'Title', 'Saving','Units', 'normal', 'Position', [.05 .399 .9 .1], 'FontSize', obj.FontSize);
            obj.button_SaveResults = uicontrol(save_panel, 'Style', 'pushbutton', 'Enable', 'off', 'String', 'Save results', 'FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.05 .55 .9 .4], 'Tag', 'button_save');
            obj.button_SaveResults.Callback = @obj.button_SaveResults_pushed; 
            obj.button_SaveProcessed = uicontrol(save_panel, 'Style', 'pushbutton', 'Enable', 'off', 'String', 'Save processed data', 'FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.05 .1 .9 .4], 'Tag', 'button_save');
            obj.button_SaveProcessed.Callback = @obj.button_SaveProcessed_pushed; 
                       
            obj.config = Config().init(obj, config_filename, {'high_pass', 'low_pass', 'n_points', 'n_synergies_max', 'nnmf_replicates', 'nnmf_stop_criterion'}, {30, 400, 200, 8, 20, 'N=4'});
            obj.data = PepatoData().init(obj, muscle_list);
            obj.visual = PepatoVisual().init(obj, obj.visual_panel);
            n_clusters = 4;
            obj.database = DataBase().init(obj, database_filename, n_clusters);
            
        end
        
        
        function ResearchMode(obj, ~, ~)
            switch obj.menu_item_mode.Checked
                case 'on'
                    obj.menu_item_mode.Checked = 'off';
                    obj.logger.message('INFO', 'Research mode OFF');

                    delete(obj.research_panel);
                case 'off' 
                    obj.menu_item_mode.Checked = 'on';
                    obj.logger.message('INFO', 'Research mode ON');

                    obj.research_panel = uipanel(obj.control_panel, 'Title', 'Research settings', 'Units', 'normal', 'Position', [.05 .11 .9 .279], 'FontSize', obj.FontSize);
                    syn_criteria_panel = uipanel(obj.research_panel, 'Title', 'NMF stop criteria', 'Units', 'normal', 'Position', [.05 .2 .9 .8], 'FontSize', obj.FontSize);
                    obj.criteria_list = uicontrol(syn_criteria_panel, 'Style', 'ListBox', 'String', {'BLF', 'N=2', 'N=3', 'N=4', 'N=5', 'N=6', 'R2=0.90', 'R2=0.95'}, 'Units', 'normal', 'Position', [.0 .0 1. 1.]);
                    obj.criteria_list.Callback = @obj.config_list_selection;
                    obj.button_UpdateDatabase = uicontrol(obj.research_panel, 'Style', 'pushbutton', 'String', 'Add to database', 'FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.05 .02 .9 .15]);
                    obj.button_UpdateDatabase.Callback = @obj.button_UpdateDatabase_pushed;
            end            
        end
        
        
        function config_list_selection(obj, ~, ~)
            obj.data.config.nnmf_stop_criterion = obj.criteria_list.String(get(obj.criteria_list, 'Value')); 
            obj.logger.message('INFO', sprintf('NMF stop criteria was set to "%s"', obj.data.config.nnmf_stop_criterion{:}));
        end
        
        
        function button_UpdateDatabase_pushed(obj, ~, ~)
            obj.database.input_names();
        end
        

        function EditConfig(obj, ~, ~)
            
            if ~ isempty(obj.proc_pipeline)
                warn_handler = warndlg('\color{blue} Current analysis may be interrupted if configuration changes.', 'Pipeline WARNING', struct('WindowStyle','modal', 'Interpreter','tex'));
                drawnow;
                waitfor(warn_handler);
            end
            config_to_compare = obj.config.current_config;
            config_gui = PepatoConfigGUI(obj, obj.FontSize);
            drawnow;
            waitfor(config_gui.figure_handle);
            
            if ~ isempty(setdiff(obj.config.current_config, config_to_compare)) && ~ isempty(obj.proc_pipeline)
                button_objects = findobj(allchild(obj.control_panel), '-regexp', 'Tag', 'button_*');
                for i = 1 : length(button_objects)
                    button_objects(i).Enable = 'off';
                end
                helpdlg({'Current analysis was interrupted due to config changes.', 'Please, restart the pipelene'}, 'Pipeline INFO');
            end
        end
        
        
        function button_Reproduce_pushed(obj, ~, ~)
            obj.load_type = 'repro';
            obj.button_LoadRaw_pushed();
        end
        
        
        function button_LoadProcessed_pushed(obj, ~, ~)
            obj.load_type = 'preproc';
            obj.button_LoadRaw_pushed();
        end
        
        
        function button_LoadRaw_pushed(obj, ~, ~)
            
            switch obj.load_type
                case 'raw'
                    title = 'Load new Data'; question = 'Stop current analysis and upload new data?';
                case 'preproc'
                    title = 'Load preprocessed Data'; question = 'Stop current analysis and upload PEPATO preprocessed data?';
                case 'repro'
                    title = 'Reproduce Analysis'; question = 'Stop current analysis and reproduce previous analysis?';
                
            end
            
            if ~isempty(obj.FileDat) && ~sum(strcmp(obj.FileDat, ''))
                obj.restart_pipeline = questdlg(question, title, 'Yes', 'No', obj.yes_no_question_opts);
            end
            switch obj.restart_pipeline
                case 'Yes'

                    obj.data.reset();
                    obj.visual.reset();
                    obj.proc_pipeline = {};
                    obj.logger.message('INFO', 'All variables reset');

                    obj.button_CropData.Enable = 'off'; obj.button_MuscleSelection.Enable = 'off'; obj.button_SpectraFiltering.Enable = 'off'; obj.button_ArtifactFiltering.Enable = 'off';
                    obj.button_Analysis.Enable = 'off';
                    obj.button_SaveResults.Enable = 'off'; obj.button_SaveProcessed.Enable = 'off';
                    
                    switch obj.load_type
                        case 'raw'
                            file_ext = ['_emg_*' obj.file_extension]; multiselect = 'on';
                        case {'preproc', 'repro'}
                            file_ext = '.mat'; multiselect = 'off';                                               
                    end
                    
                    try
                        [obj.FileDat, obj.PathDat] = uigetfile(['/cd/*' file_ext], 'Open EMG data', 'Multiselect', multiselect);
                        
                        switch obj.load_type
                            case 'raw'
                                if ischar(obj.FileDat)
                                    obj.FileDat = {obj.FileDat};
                                end
                                obj.FileDat = sort(obj.FileDat);
                                
                                [csv_files, yaml_files, checked_, csv_header] = check_filenames(cellfun(@(x) fullfile(obj.PathDat, x), obj.FileDat, 'UniformOutput', false), obj.condition_list, obj.data.muscle_list);
                                if ~csv_header
                                    obj.logger.message('ERROR', 'CSV files do not have all the required columns. %s', csv_header);
                                end
                                [subjects, ~, ~] = get_trial_info(obj.FileDat);
                                if checked_ && (length(unique(subjects)) == 1)
                                    obj.logger.message('INFO', ['Files ' sprintf('%s, ', obj.FileDat{:}) 'uploaded from the folder ' obj.PathDat]);
                                else
                                    obj.FileDat = '';
                                    if ~checked_
                                        obj.logger.message('ERROR', 'CSV or YAML file names do not match PEPATO requirements, please see README.md file.');
                                    end
                                    if length(unique(subjects)) > 1
                                        obj.logger.message('ERROR', 'More than one subject selected, please select only one.');
                                    end
                                end
                                
                            case 'preproc'
                                try
                                    preproc_filename = [obj.PathDat obj.FileDat];
                                    
                                    loaded = load(preproc_filename, 'input', 'emg_enveloped', 'emg_label');
                                    obj.logger.message('INFO', ['Load PEPATO preprocessed data: config and parametrs downloaded from the file ' obj.PathDat obj.FileDat]);
                                    obj.config.load_config_from_file(preproc_filename);

                                    obj.FileDat = loaded.input.FileDat;
                                    obj.PathDat = loaded.input.PathDat;
                                    [csv_files, yaml_files, ~, ~] = check_filenames(cellfun(@(x) fullfile(obj.PathDat, x), obj.FileDat, 'UniformOutput', false), obj.condition_list, loaded.input.muscle_list);
                                    
                                    obj.proc_pipeline = loaded.input.proc_pipeline;
                                    obj.body_side = loaded.input.body_side;

                                    obj.visual.time_bounds = loaded.input.time_bounds;
                                    obj.visual.selected_muscles = loaded.input.selected_muscles;
                                    obj.visual.freq2filt = loaded.input.freq2filt;
                                    obj.visual.cycles2drop = loaded.input.cycles2drop;
                                    
                                    obj.data.emg_enveloped = loaded.emg_enveloped;
                                    obj.data.emg_label = loaded.emg_label;
                                    
                                    for i = 1 : length(obj.data.emg_enveloped)
                                        [obj.data.emg_enveloped{i}, obj.data.emg_label{i}, muscle_index, ~] = normalize_input(obj.data.emg_enveloped{i}, obj.data.emg_label{i}, obj.data.muscle_list, obj.body_side);
                                        obj.data.colors{i} = obj.data.all_colors(muscle_index, :);
                                    end

                                catch except
                                    obj.logger.message('ERROR', 'Loading is possible only from PEPATO generated file', except);
                                end

                            case 'repro'
                                try
                                    loaded = load([obj.PathDat obj.FileDat], 'input');
                                    obj.logger.message('INFO', ['Reproduce PEPATO analysis: config and parametrs downloaded from the file ' obj.PathDat obj.FileDat]);
                                    obj.config.load_config_from_file([obj.PathDat obj.FileDat]);

                                    obj.FileDat = loaded.input.FileDat;
                                    obj.PathDat = loaded.input.PathDat;
                                    [csv_files, yaml_files, ~, ~] = check_filenames(cellfun(@(x) fullfile(obj.PathDat, x), obj.FileDat, 'UniformOutput', false), obj.condition_list, loaded.input.muscle_list);
                                    
                                    obj.proc_pipeline = loaded.input.proc_pipeline;
                                    
                                    obj.body_side = loaded.input.body_side;
                                    
                                    obj.data.muscle_list = loaded.input.muscle_list;

                                    obj.visual.time_bounds = loaded.input.time_bounds;
                                    obj.visual.selected_muscles = loaded.input.selected_muscles;
                                    obj.visual.freq2filt = loaded.input.freq2filt;
                                    obj.visual.cycles2drop = loaded.input.cycles2drop;
                                    obj.visual.reproduce = 'Yes';

                                catch except
                                    obj.logger.message('ERROR', 'Reproduce is possible only from PEPATO generated results file', except);
                                end
                        end

                        switch obj.load_type
                            case {'raw', 'repro'}
                                try
                                    obj.data.load_data(csv_files, yaml_files, obj.body_side);
                                    if sum(cellfun(@isempty, obj.data.unused_labels)) < obj.data.n_files
                                        for i = 1:obj.data.n_files
                                            if ~isempty(obj.data.unused_labels{i})
                                                obj.logger.message('WARNING', sprintf('%s: labels [%s] are not used\nLabels allowed: [%s]', obj.FileDat{i}, obj.data.unused_labels{i}, strjoin(obj.data.muscle_list, ', ')));
                                            end
                                        end
                                    end
                                    obj.visual.create_workspace(obj.data.filenames);

                                    obj.visual.draw_raw_emg(obj.data);

                                    obj.button_CropData.Enable = 'on';
                                    obj.button_MuscleSelection.Enable = 'on';
                                    obj.button_SpectraFiltering.Enable = 'on';
                                    obj.button_ArtifactFiltering.Enable = 'on';

                                    switch obj.visual.reproduce
                                        case 'Yes'
                                            obj.logger.message('INFO', ['Reproduce PEPATO analysis: files ' sprintf('%s, ', obj.FileDat{:}) 'downloaded from the folder ' obj.PathDat]);

                                            for func = obj.proc_pipeline
                                                switch func{:}
                                                    case 'crop'
                                                        obj.button_CropData_pushed;
                                                    case 'muscle selection'
                                                        obj.button_MuscleSelection_pushed;
                                                    case 'spectra filtering'
                                                        obj.button_SpectraFiltering_pushed;
                                                    case 'artifact filtering'
                                                        obj.button_ArtifactFiltering_pushed;
                                                    case 'analysis'
                                                        obj.button_Analysis_pushed;
                                                end
                                            end                                  
                                    end
                                catch except
                                    switch obj.load_type
                                        case 'raw'
                                            obj.logger.message('ERROR', ['Loading raw files: ' sprintf('%s, ', obj.FileDat{:}) 'from the folder ' obj.PathDat], except);
                                        case 'repro'
                                            obj.logger.message('ERROR', ['Reproduce PEPATO analysis: interrupted, files ' sprintf('%s, ', obj.FileDat{:}) 'are not available in the folder ' obj.PathDat], except);
                                    end
                                end
                                
                            case 'preproc'
                                obj.data.files_(obj.FileDat);
                                obj.data.config = obj.config.current_config;
                                obj.visual.create_workspace(obj.data.filenames);
                                obj.visual.draw_cleaned_envelope(obj.data);
                                obj.data.envelope_max_normalization();

                                obj.button_Analysis.Enable = 'on';
                        end
                        
                        
                    catch except
                        obj.logger.message('ERROR', 'error loading files', except);
                        obj.FileDat = '';
                        obj.PathDat = '';
                    end

            end
            
            obj.load_type = 'raw';
        end
        
        
        function button_CropData_pushed(obj, ~, ~)
            obj.button_CropData.Enable = 'off';
            switch obj.visual.reproduce
                case 'No'
                    obj.proc_pipeline = [obj.proc_pipeline, 'crop'];
            end
        
            obj.visual.draw_segment_selection(obj.data);
            obj.data.segment_selection(obj.visual.time_bounds);
            
        end
        
        
        function button_MuscleSelection_pushed(obj, ~, ~)
            obj.button_MuscleSelection.Enable = 'off';
            switch obj.visual.reproduce
                case 'No'
                    obj.proc_pipeline = [obj.proc_pipeline, 'muscle selection'];
            end
        
            obj.visual.draw_muscle_selection(obj.data);
            obj.data.muscles_selection(obj.visual.selected_muscles);            
        end
        
        
        function button_SpectraFiltering_pushed(obj, ~, ~)
            obj.button_SpectraFiltering.Enable = 'off';
            switch obj.visual.reproduce
                case 'No'
                    obj.proc_pipeline = [obj.proc_pipeline, 'spectra filtering'];
            end
        
            obj.data.spectra_noises_detection();        
            obj.visual.draw_spectra_filtering(obj.data);        
            obj.data.spectra_filtering(obj.visual.freq2filt);           
        end
        
        
        function button_ArtifactFiltering_pushed(obj, ~, ~)
            switch obj.button_SpectraFiltering.Enable
                case 'on'
                    filter_the_spectra_first = questdlg('Filter the spectra first? (recommended)', 'Preprocessing WARNING', 'Yes', 'No', obj.yes_no_question_opts);
                    switch filter_the_spectra_first
                        case 'Yes'
                            obj.button_SpectraFiltering_pushed()
                    end
            end
            
            obj.button_CropData.Enable = 'off';
            obj.button_MuscleSelection.Enable = 'off';
            obj.button_SpectraFiltering.Enable = 'off';
            obj.button_ArtifactFiltering.Enable = 'off';
            switch obj.visual.reproduce
                case 'No'
                    obj.proc_pipeline = [obj.proc_pipeline, 'artifact filtering'];
            end
        
            obj.data.interpolated_envelope();
            obj.visual.draw_artifact_filtering(obj.data);        
            obj.data.cycles_selection(obj.visual.cycles2drop);
            obj.visual.draw_cleaned_envelope(obj.data); 

            obj.data.envelope_max_normalization();

            obj.button_Analysis.Enable = 'on';
            obj.button_SaveProcessed.Enable = 'on';
        end
        
        
        function button_Analysis_pushed(obj, ~, ~)
            obj.button_Analysis.Enable = 'off';
            
            switch obj.visual.reproduce
                case 'No'
                    obj.proc_pipeline = [obj.proc_pipeline, 'analysis'];
            end
            
            obj.data.muscle_synergies();
            try
                obj.data.module_compare(obj.database.clustering);
            catch except
                obj.logger.message('WARNING', 'Modules comparison with reference is not available. Database error.', except);
            end
            obj.visual.draw_muscle_synergies(obj.data, obj.database.clustering);
            obj.logger.message('INFO', sprintf('Synergy analysis done. NMF stop criteria: "%s"', obj.data.config.nnmf_stop_criterion{:}));
            
            obj.data.spinal_maps();
            try
                obj.data.maps_compare(obj.database.maps_patterns);
            catch except
                obj.logger.message('WARNING', 'Spinal maps comparison with reference is not available. Database error.', except);
            end    
            obj.visual.draw_spinal_maps(obj.data, obj.database.maps_patterns);
            obj.logger.message('INFO', 'Spinal maps analysis done.');

            obj.button_Analysis.Enable = 'on';
            obj.button_SaveResults.Enable = 'on';
            obj.button_SaveProcessed.Enable = 'on';
        end
        
        
        function button_SaveResults_pushed(obj, ~, ~)
            if ~ isempty(setdiff(obj.data.config, obj.config.current_config))
                old_config_name = obj.data.config.Properties.RowNames{:};
                new_config_name = inputdlg(sprintf('Config was changed.\nSelect name for new config:'), 'New config name', [1 60], {[old_config_name '_']});
                if isempty(new_config_name)
                    new_config_name = [old_config_name '_' rand_string_gen(3)];
                end
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
        
        
        function button_SaveProcessed_pushed(obj, ~, ~)
            input = cell2struct({obj.FileDat, obj.PathDat, obj.proc_pipeline, obj.body_side, obj.data.muscle_list, obj.visual.time_bounds, obj.visual.selected_muscles, obj.visual.freq2filt, obj.visual.cycles2drop}, ...
                {'FileDat', 'PathDat', 'proc_pipeline', 'body_side', 'muscle_list', 'time_bounds', 'selected_muscles', 'freq2filt', 'cycles2drop'}, 2);
            config = obj.data.config;
            emg_enveloped = obj.data.emg_enveloped;
            emg_label = obj.data.emg_label;
            
            try
                [output_file, output_path] = uiputfile([obj.PathDat 'pepato_processed.mat']);
                output_filename = fullfile(output_path, output_file);
                save(output_filename, 'input', 'config', 'emg_enveloped', 'emg_label');
                obj.logger.message('INFO', ['PEPATO processed data (without analysis) saved to the ' output_filename]);
            catch
                obj.logger.message('ERROR', 'Processed data not saved');
            end
        end
        
    end
    
    
end