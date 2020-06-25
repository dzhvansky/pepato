classdef PepatoVisual
    
    properties
        
        parent_obj;
        
        visual_panel;
        second_level_tab_names;
        
        n_files;
        
        first_level_tab_group;
        first_level_tab_handle;
        second_level_tab_group;        
        second_level_tab_handle;
        
        report_tab_handle;
        report_table;
        
        time_bounds;
        selected_muscles;
        freq2filt;
        cycles2drop;
        
        reproduce = 'No';
        
        logger;
        config;
                
    end
    
    
    methods        
        
        function obj = init(obj, parent_obj, visual_panel)
            obj.parent_obj = parent_obj;
            obj.logger = obj.parent_obj.logger;
            
            obj.visual_panel = visual_panel;
            obj.second_level_tab_names = {'Raw EMG data', 'Muscle selection', 'Spectra filtering', 'Artifact filtering', 'Cleaned EMG envelope', 'Muscle synergies', 'Spinal maps'};
            
            obj.parent_obj.visual = obj;
        end
        
        
        function obj = create_workspace(obj, filenames)
            
            obj.n_files = size(filenames, 2);
            
            delete(obj.first_level_tab_group);
            obj.first_level_tab_group = uitabgroup(obj.visual_panel);
            
            obj.second_level_tab_group = cell(1, obj.n_files);
            
            for i = 1 : obj.n_files
                
                obj.first_level_tab_handle(i) = uitab(obj.first_level_tab_group, 'Title', filenames{i});
                obj.second_level_tab_group{i} = uitabgroup(obj.first_level_tab_handle(i));
                
                for j = 1:length(obj.second_level_tab_names)
                  obj.second_level_tab_handle(j, i) = uitab(obj.second_level_tab_group{i}, 'Title', obj.second_level_tab_names{j});
                end
            end
            
            obj.report_tab_handle = uitab(obj.first_level_tab_group, 'Title', 'Report');
            obj.report_table = uitable(obj.report_tab_handle, 'RowName', obj.parent_obj.data.output_params, 'ColumnName', filenames, 'ColumnWidth', {400}, 'Units', 'Normalized', 'Position', [.0 .0, 1., 1.], 'FontS', obj.parent_obj.FontSize+2);
            obj.parent_obj.visual = obj;
        end
        
        
        function obj = draw_raw_emg(obj, data)
            obj.config = obj.parent_obj.config.current_config;
            
            n_handle = 1;
            
            for i = 1 : obj.n_files
                obj.first_level_tab_group.SelectedTab = obj.first_level_tab_handle(i);
                obj.second_level_tab_group{i}.SelectedTab = obj.second_level_tab_handle(n_handle, i);
                
                fig_emg(obj.second_level_tab_handle(n_handle, i), data.colors{i}, data.emg_data_raw{i}, data.emg_timestamp{i}, data.emg_bounds{i}, data.emg_framerate{i}, data.emg_label{i});
            end
            
            obj.parent_obj.visual = obj;
        end
        
        
        function obj = draw_segment_selection(obj, data)
            n_handle = 1;
            switch obj.reproduce
                case 'No'
                    obj.time_bounds = cell(1, obj.n_files);
            end
            
            for i = 1 : obj.n_files
                
                obj.first_level_tab_group.SelectedTab = obj.first_level_tab_handle(i);
                obj.second_level_tab_group{i}.SelectedTab = obj.second_level_tab_handle(n_handle, i);
                
                switch obj.reproduce
                    case 'No'                        
                        segment_selected = 'No';
                        while ~strcmp(segment_selected, 'Yes')
                            try
                                handlers = findobj(allchild(obj.second_level_tab_handle(n_handle, i)), '-regexp', 'Tag', 'segment_*');
                                if ~ isempty(handlers)
                                    delete(handlers);
                                end

                                n_segments = str2double(inputdlg('Enter a number of segments to select', 'Number of segments', [1 60], {'1'}));
                                for j = 1 : n_segments
                                    [obj.time_bounds{i}(j, 1:2), ~] = ginput(2);
                                    fig_segment(obj.second_level_tab_handle(n_handle, i), size(data.emg_data_raw{i}, 2), data.emg_timestamp{i}, data.emg_framerate{i}, obj.time_bounds{i}(j, 1:2));
                                end
                            catch ex
                                n_segments = [];
                                obj.logger.message('ERROR', 'Segment boundaries were not selected correctly', ex);
                            end
                            segment_selected = questdlg('Finish selection', 'Segment selection', 'Yes', 'No, redo', obj.parent_obj.yes_no_question_opts);
                        end                        
                            
                        if isempty(n_segments)
                            obj.time_bounds{i}(1, 1:2) = [data.emg_timestamp{i}(1) data.emg_timestamp{i}(end)];
                            obj.logger.message('INFO', sprintf('Entire segment selected in %s file', data.filenames{1, i}));
                        end
                        
                    case 'Yes'
                        for j = 1 : size(obj.time_bounds{i}, 1)
                            fig_segment(obj.second_level_tab_handle(n_handle, i), size(data.emg_data_raw{i}, 2), data.emg_timestamp{i}, data.emg_framerate{i}, obj.time_bounds{i}(j, 1:2));
                        end
                end
                
            end
            
            obj.parent_obj.visual = obj;
        end
        
        
        function obj = draw_muscle_selection(obj, data)
            n_handle = 2;
            switch obj.reproduce
                case 'No'
                    obj.selected_muscles = cell(1, obj.n_files);
            end
            
            for i = 1 : obj.n_files
                obj.first_level_tab_group.SelectedTab = obj.first_level_tab_handle(i);
                obj.second_level_tab_group{i}.SelectedTab = obj.second_level_tab_handle(n_handle, i);

                switch obj.reproduce
                	case 'No'
                        obj.selected_muscles{i} = select_muscles(obj.second_level_tab_handle(n_handle, i), data.colors{i}, data.emg_data_raw{i}, data.emg_bounds{i}, data.emg_timestamp{i}, data.emg_label{i});
                	case 'Yes'
                        select_muscles_repro(obj.second_level_tab_handle(n_handle, i), data.colors{i}, data.emg_data_raw{i}, data.emg_bounds{i}, data.emg_timestamp{i}, data.emg_label{i}, obj.selected_muscles{i});
                end
            end
            
            obj.parent_obj.visual = obj;
        end
        
        
        function obj = draw_spectra_filtering(obj, data)
            n_handle = 3;            
            switch obj.reproduce
                case 'No'
                    obj.freq2filt = cell(1, obj.n_files);
            end
        
            for i = 1 : obj.n_files
                obj.first_level_tab_group.SelectedTab = obj.first_level_tab_handle(i);
                obj.second_level_tab_group{i}.SelectedTab = obj.second_level_tab_handle(n_handle, i);

                switch obj.reproduce
                	case 'No'
                        obj.freq2filt{i} = select_freq2filt(obj.second_level_tab_handle(n_handle, i), data.colors{i}, data.emg_data_raw{i}, data.emg_framerate{i}, data.emg_label{i}, data.freq2filt{i}, obj.config.high_pass, obj.config.low_pass);
                    case 'Yes'
                    select_freq2filt_repro(obj.second_level_tab_handle(n_handle, i), data.colors{i}, data.emg_data_raw{i}, data.emg_framerate{i}, data.emg_label{i}, obj.config.high_pass, obj.config.low_pass, obj.freq2filt{i});
                end
            end
            
            obj.parent_obj.visual = obj;
        end
        
        
        function obj = draw_artifact_filtering(obj, data)
            n_handle = 4;            
            switch obj.reproduce
                case 'No'
                    obj.cycles2drop = cell(1, obj.n_files);
            end

            for i = 1 : obj.n_files    
                obj.first_level_tab_group.SelectedTab = obj.first_level_tab_handle(i);
                obj.second_level_tab_group{i}.SelectedTab = obj.second_level_tab_handle(n_handle, i);

                fig_envelope(obj.second_level_tab_handle(n_handle, i), data.emg_enveloped{i}, data.emg_label{i}, data.config.n_points, data.colors{i}, data.emg_data_cleaned{i}, data.emg_framerate{i});
                switch obj.reproduce
                	case 'No'
                        obj.cycles2drop{i} = select_cycles(data.emg_enveloped{i}, data.emg_label{i}, data.emg_data_raw{i}, data.emg_bounds{i}, .6);
                end
            end
            
            obj.parent_obj.visual = obj;
        end
        
        
        function obj = draw_cleaned_envelope(obj, data)
            n_handle = 5;
            for i = 1 : obj.n_files
                obj.first_level_tab_group.SelectedTab = obj.first_level_tab_handle(i);
                obj.second_level_tab_group{i}.SelectedTab = obj.second_level_tab_handle(n_handle, i);
                
                fig_envelope(obj.second_level_tab_handle(n_handle, i), data.emg_enveloped{i}, data.emg_label{i}, data.config.n_points, repmat([0 0.4470 0.7410], size(data.emg_enveloped{i}, 1), 1));
            end
            
            obj.parent_obj.visual = obj;
        end
        
        function obj = draw_muscle_synergies(obj, data, clustering)
            n_handle = 6;
            [~, conditions] = get_trial_info(data.filenames);
            
            for i = 1 : obj.n_files
                if strcmp(data.clustering_mode, 'unique')
                    cluster_condition = conditions{i};
                elseif strcmp(data.clustering_mode, 'common')
                    cluster_condition = 'all_conditions';
                end
                
                delete(obj.second_level_tab_handle(n_handle, i));
                obj.second_level_tab_handle(n_handle, i) = uitab(obj.second_level_tab_group{i}, 'Title', obj.second_level_tab_names{n_handle}); 

                obj.first_level_tab_group.SelectedTab = obj.first_level_tab_handle(i);
                obj.second_level_tab_group{i}.SelectedTab = obj.second_level_tab_handle(n_handle, i);

                FigSynergies(obj.second_level_tab_handle(n_handle, i), data.emg_patterns{i}, data.emg_patterns_sd{i}, ...
                    data.basic_patterns{i}, data.basic_patterns_sd{i}, data.muscle_weightings{i}, data.nmf_r2{i}, ...
                    data.emg_label{i}, data.all_colors, clustering, cluster_condition, data.module_info{i});      
            end            
            
            obj.refresh_report(data);
            
            obj.parent_obj.visual = obj;
        end
        
        
        function obj = draw_spinal_maps(obj, data, maps_patterns)
            n_handle = 7;
            colormap(jetnew(32,-1)); % recalibrate colormap
            [~, conditions] = get_trial_info(data.filenames);
        
            for i = 1 : obj.n_files
                delete(obj.second_level_tab_handle(n_handle, i));
                obj.second_level_tab_handle(n_handle, i) = uitab(obj.second_level_tab_group{i}, 'Title', obj.second_level_tab_names{n_handle});

                obj.first_level_tab_group.SelectedTab = obj.first_level_tab_handle(i);
                obj.second_level_tab_group{i}.SelectedTab = obj.second_level_tab_handle(n_handle, i);

                FigSpinalmaps(obj.second_level_tab_handle(n_handle, i), data.motorpools_activation{i}, data.motorpools_activation_avg{i}, ...
                    maps_patterns, conditions{i}, data.sacral{i}, data.lumbar{i});
            end
            
            obj.refresh_report(data);

            obj.parent_obj.visual = obj;
        end
        
        
        function obj = reset(obj)
            obj.time_bounds = [];
            obj.selected_muscles = [];
            obj.freq2filt = [];
            obj.cycles2drop = [];

            obj.reproduce = 'No';
            
            obj.parent_obj.visual = obj;
        end
        
        
        function obj = refresh_report(obj, data)
            n_params = length(obj.parent_obj.data.output_params);
            to_report = cell(n_params, obj.n_files);
            
            for i = 1 : obj.n_files
                temp_ = struct2cell(data.output_data(i)); 
                temp_ = temp_(2);
                temp_ = struct2cell(temp_{:});
                to_report(:, i) = temp_(:, 1); 
                temp_ = to_report(1, i);
                
                n_round = 1;
                for j = 1:n_params
                    if j == 2 || j == 8 n_round = 2; end
                    temp_ = to_report(j, i);
                    if ~ isempty(temp_{:}) to_report(j, i) = {num2str(round(temp_{:}, n_round))}; end
                end
            end
            
            obj.report_table.Data = to_report;
        end
        
    end
        
end
