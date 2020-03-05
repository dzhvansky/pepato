classdef PepatoConfigGUI < handle
  
    properties
        parent_obj;
        figure_handle;
        FontSize;
        column_width;
        
        config;
        
        button_Set_Config;        
        button_New_Config;
        button_Load_Config;
        button_Delete_Config;
        button_Restore_Config;
        
        config_list;        
        selected_name;        
        
        main_params;
        spectra_filtering;
        artifact_filtering;
        muscle_synergies;
        spinal_maps;
        
        button_Save_Config;
        button_Cancel_Saving;
        new_config_name;
        
    end
    
    
    methods(Static)
        
        function [data, cols, rows] = parse_table(table, column_width, n_rows_, n_cols_)
            if exist('n_rows_', 'var')
                table = table(n_rows_, :);
            end
            if exist('n_cols_', 'var')
                table = table(:, n_cols_);
            end
            
            data = table2cell(table);
            cols = table.Properties.VariableNames;
            rows = table.Properties.RowNames;
            
            data = strcat(sprintf('<html><tr align=center><td width=%d>', column_width), cellfun(@num2str, data, 'un', 0));
        end
        
        
        function deselect_table_cell(src, ~)
            temp = src.Data;
            src.Data = {'dummy'};
            src.Data = temp;
        end
        
    end
    
    
    methods
        
        function obj = PepatoConfigGUI(parent_obj, FontSize)
            obj.parent_obj = parent_obj;
            obj.config = obj.parent_obj.config;
            obj.FontSize = FontSize;
            obj.column_width = 100;
            
            obj.figure_handle = figure('name', 'Config editor', 'NumberTitle','off', 'Units', 'normal', 'OuterPosition', [.1 .1 .7 .7], 'WindowStyle', 'modal'); clf;
            set(obj.figure_handle, 'MenuBar', 'none'); 
            set(obj.figure_handle, 'ToolBar', 'none');
            
            obj.button_Set_Config = uicontrol(obj.figure_handle, 'Style', 'pushbutton', 'String', 'Set selected config','FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.03 .9 .15 .07]); %'BackgroundColor', [.6 .6 .6],
            obj.button_Set_Config.Callback = @obj.button_Set_Config_pushed;            
            obj.button_Delete_Config = uicontrol(obj.figure_handle, 'Style', 'pushbutton', 'String', 'Delete selected config','FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.19 .9 .15 .07]); %'BackgroundColor', [.6 .6 .6],
            obj.button_Delete_Config.Callback = @obj.button_Delete_Config_pushed;   
            obj.button_Load_Config = uicontrol(obj.figure_handle, 'Style', 'pushbutton', 'String', 'Load config from file','FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.35 .9 .15 .07]); %'BackgroundColor', [.6 .6 .6],
            obj.button_Load_Config.Callback = @obj.button_Load_Config_pushed;                     
            obj.button_Restore_Config = uicontrol(obj.figure_handle, 'Style', 'pushbutton', 'String', 'Restore default config','FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.51 .9 .15 .07]); %'BackgroundColor', [.6 .6 .6],
            obj.button_Restore_Config.Callback = @obj.button_Restore_Config_pushed;
            obj.button_New_Config = uicontrol(obj.figure_handle, 'Style', 'pushbutton', 'String', 'New config','FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.67 .9 .31 .07]); %'BackgroundColor', [.6 .6 .6],
            obj.button_New_Config.Callback = @obj.button_New_Config_pushed;
            
            obj.config_list = uicontrol(obj.figure_handle, 'Style', 'ListBox', 'String', '', 'Units', 'normal', 'Position', [.03, .06, .15, .83]);
            obj.config_list.Callback = @obj.config_list_selection;
            
            obj.main_params = uipanel(obj.figure_handle, 'Title', 'Main parameters', 'BackgroundColor', [.92 .92 .92], 'Units', 'normal', 'Position', [.19, .74, .47, .15], 'FontSize', obj.FontSize);
            obj.spectra_filtering = uipanel(obj.figure_handle, 'Title', 'Spectra filtering', 'BackgroundColor', [.92 .92 .92], 'Units', 'normal', 'Position', [.19, .57, .47, .15], 'FontSize', obj.FontSize);
            obj.artifact_filtering = uipanel(obj.figure_handle, 'Title', 'Artifact filtering', 'BackgroundColor', [.92 .92 .92], 'Units', 'normal', 'Position', [.19, .40, .47, .15], 'FontSize', obj.FontSize);
            obj.muscle_synergies = uipanel(obj.figure_handle, 'Title', 'Muscle synergies', 'BackgroundColor', [.92 .92 .92], 'Units', 'normal', 'Position', [.19, .23, .47, .15], 'FontSize', obj.FontSize);
            obj.spinal_maps = uipanel(obj.figure_handle, 'Title', 'Spinal maps', 'BackgroundColor', [.92 .92 .92], 'Units', 'normal', 'Position', [.19, .06, .47, .15], 'FontSize', obj.FontSize);
            
            obj.main_params = uitable(obj.main_params, 'ColumnWidth', {obj.column_width}, 'Units', 'Normalized', 'Position', [.0 .0, 1., 1.], 'CellSelectionCallback', @obj.edit_selected_cell, 'CellEditCallback', @obj.restore_edited_cell);
            obj.spectra_filtering = uitable(obj.spectra_filtering, 'ColumnWidth', {obj.column_width}, 'Units', 'Normalized', 'Position', [.0 .0, 1., 1.], 'CellSelectionCallback', @obj.edit_selected_cell, 'CellEditCallback', @obj.restore_edited_cell);
            obj.artifact_filtering = uitable(obj.artifact_filtering, 'ColumnWidth', {obj.column_width}, 'Units', 'Normalized', 'Position', [.0 .0, 1., 1.], 'CellSelectionCallback', @obj.edit_selected_cell, 'CellEditCallback', @obj.restore_edited_cell);
            obj.muscle_synergies = uitable(obj.muscle_synergies, 'ColumnWidth', {obj.column_width}, 'Units', 'Normalized', 'Position', [.0 .0, 1., 1.], 'CellSelectionCallback', @obj.edit_selected_cell, 'CellEditCallback', @obj.restore_edited_cell);
            obj.spinal_maps = uitable(obj.spinal_maps, 'ColumnWidth', {obj.column_width}, 'Units', 'Normalized', 'Position', [.0 .0, 1., 1.], 'CellSelectionCallback', @obj.edit_selected_cell, 'CellEditCallback', @obj.restore_edited_cell);
            
            current_config_name = obj.config.get_name(obj.config.current_config);            
            obj.set_parameters(current_config_name);
            obj.lock_params();
            
        end
        
        
        function config_list_selection(obj, ~, ~)
            n_row = get(obj.config_list, 'Value');
            obj.selected_name = obj.config.get_name(obj.config.config_base, n_row);
            obj.set_parameters(obj.selected_name);
            
            if ~ isempty(obj.new_config_name)
                obj.new_config_name.String = [obj.selected_name '_'];
            end
        end
        
        
        function button_Set_Config_pushed(obj, ~, ~)
            obj.config = obj.config.set_config(obj.selected_name);
            
            obj.parent_obj.config = obj.config;
        end
        
        
        function button_Delete_Config_pushed(obj, ~, ~)
            obj.config = obj.config.delete_config(obj.selected_name);
            config_name = obj.config.get_name(obj.config.current_config);
            obj.set_parameters(config_name);
            
            obj.parent_obj.config = obj.config;
        end
        
        
        function button_Load_Config_pushed(obj, ~, ~)
            [FileDat, PathDat] = uigetfile('/cd/*.mat', 'Load config from PEPATO output file');
            filename = [PathDat FileDat];
            
            obj.config = obj.config.load_cofig_from_file(filename); 
            config_name = obj.config.get_name(obj.config.current_config);            
            obj.set_parameters(config_name);
            
            obj.parent_obj.config = obj.config;
        end
        
        
        function button_Restore_Config_pushed(obj, ~, ~)
            try
                obj.config = obj.config.set_config('default');
            catch
                default_config = obj.config.create_config(obj.config.default_values, 'default');
                obj.config = obj.config.add_config(default_config);
            end
            obj.set_parameters('default');
            
            obj.parent_obj.config = obj.config;
        end
        
        
        function button_New_Config_pushed(obj, ~, ~)
            obj.button_Save_Config = uicontrol(obj.figure_handle, 'Style', 'pushbutton', 'String', 'Save config as:', 'FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.67 .82 .15 .07]); %'BackgroundColor', [.6 .6 .6],
            obj.button_Save_Config.Callback = @obj.button_Save_Config_pushed;
            obj.button_Cancel_Saving = uicontrol(obj.figure_handle, 'Style', 'pushbutton', 'String', 'Cancel', 'FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.83 .74 .15 .15]); %'BackgroundColor', [.6 .6 .6],
            obj.button_Cancel_Saving.Callback = @obj.button_Cancel_Saving_pushed;
            
            obj.new_config_name = uicontrol(obj.figure_handle, 'Style', 'Edit', 'String', [obj.selected_name '_'], 'Units', 'normal', 'Position', [.67, .74, .15, .07]);
            
            obj.unlock_params();
            waitfor(obj.button_Save_Config);            
        end
        
        
        function button_Save_Config_pushed(obj, ~, ~)
            
            for table = [obj.main_params, obj.spectra_filtering, obj.artifact_filtering, obj.muscle_synergies, obj.spinal_maps]
                obj.deselect_table_cell(table);
                
                if ~ isempty(table.Data)
                    for i = 1 : length(table.Data)
                        if ~ strcmp(table.Data{i}(1), '<')
                            table.Data{1, i} = [sprintf('<html><tr align=center><td width=%d>', obj.column_width), table.Data{1, i}];
                        end
                    end
                end
            end
            
            obj.lock_params();
            config_name = obj.new_config_name.String;
            values_to_add = obj.get_parameters();
            config_to_add = obj.config.create_config(values_to_add, config_name);
            
            delete(obj.new_config_name); obj.new_config_name = [];
            delete(obj.button_Save_Config);
            delete(obj.button_Cancel_Saving);
            
            validate_message = obj.validate_config(config_to_add);
            if isempty(validate_message)            
                [obj.config, add_flag] = obj.config.add_config(config_to_add);
                if add_flag
                    obj.set_parameters(config_name);
                end

                obj.parent_obj.config = obj.config;            
            else
                warndlg(sprintf(['Config "%s" cannot be saved, fix the issues first:\n\n', validate_message], add_backslash(config_name, '_')), 'Config WARNING', struct('WindowStyle','modal', 'Interpreter','tex'))
            end
            
        end
        
        
        function button_Cancel_Saving_pushed(obj, ~, ~)
            obj.lock_params();
            delete(obj.new_config_name); obj.new_config_name = [];
            delete(obj.button_Save_Config);
            delete(obj.button_Cancel_Saving);
            
            current_config_name = obj.config.get_name(obj.config.current_config); 
            obj.set_parameters(current_config_name);
        end
        
        
        function set_parameters(obj, config_name)
            row_names = obj.config.get_name(obj.config.config_base, 'all');
            config_ = obj.config.config_base(config_name, :);
            
            n_row = find(ismember(row_names, config_name));
            set(obj.config_list, 'String', row_names);
            set(obj.config_list, 'Value', n_row);
            
            [data, ~, rows] = obj.parse_table(config_, obj.column_width, 1);
            obj.main_params.Data = data(3); obj.main_params.ColumnName = {'<html><center />N points <br />(cycle norm)'}; obj.main_params.RowName = rows;
            obj.spectra_filtering.Data = data(1:2); obj.spectra_filtering.ColumnName = {'<html><center />High pass <br />frequency, Hz', '<html><center />Low pass <br />frequency, Hz'}; obj.spectra_filtering.RowName = rows;
            obj.muscle_synergies.Data = data(4:6); obj.muscle_synergies.ColumnName = {'N synergies max', 'NNMF replicates', 'Stop criterion'}; obj.muscle_synergies.RowName = rows;
            
            obj.selected_name = config_name;
        end
        
        
        function values_to_add = get_parameters(obj)
            
            idx = strfind(obj.main_params.Data{1}, '>');
            idx = idx(end);

            mp = cellfun(@(x) x(idx+1 : end), obj.main_params.Data, 'un', 0);
            sf = cellfun(@(x) x(idx+1 : end), obj.spectra_filtering.Data, 'un', 0);
            ms = cellfun(@(x) x(idx+1 : end), obj.muscle_synergies.Data, 'un', 0);
            
            values_to_add = {str2double(sf{1}), str2double(sf{2}), str2double(mp{1}), str2double(ms{1}), str2double(ms{2}), ms{3}};
            
        end
        
        
        function lock_params(obj)
            for table = [obj.main_params, obj.spectra_filtering, obj.artifact_filtering, obj.muscle_synergies, obj.spinal_maps]
                table.ColumnEditable = false(1, length(table.Data));
            end

            obj.button_Set_Config.Enable = 'on';
            obj.button_Delete_Config.Enable = 'on';
            obj.button_Load_Config.Enable = 'on';
            obj.button_Restore_Config.Enable = 'on';
            obj.button_New_Config.Enable = 'on';
        end
        
        
        function unlock_params(obj)
            for table = [obj.main_params, obj.spectra_filtering, obj.artifact_filtering, obj.muscle_synergies, obj.spinal_maps]
                table.ColumnEditable = true(1, length(table.Data));
            end
            
            obj.button_Set_Config.Enable = 'off';
            obj.button_Delete_Config.Enable = 'off';
            obj.button_Load_Config.Enable = 'off';
            obj.button_Restore_Config.Enable = 'off';
            obj.button_New_Config.Enable = 'off';
        end
        
        
        function edit_selected_cell(obj, table, selected)
            if isempty(selected.Indices)
                return
            end
            
            if table.ColumnEditable(selected.Indices(2))                
                to_edit = table.Data{selected.Indices(2)};
                idx = strfind(to_edit, '>');
                if ~isempty(idx)
                    idx = idx(end);
                else
                    idx = 0;
                end
                
                table.Data{selected.Indices(2)} = to_edit(idx+1 : end);
            else
                obj.deselect_table_cell(table);
            end
        end
        
        
        function restore_edited_cell(obj, table, selected)
            table.Data{selected.Indices(2)} = [sprintf('<html><tr align=center><td width=%d>', obj.column_width), table.Data{selected.Indices(2)}];
        end        
        
        
        function message = validate_config(obj, config)
            message = [];
            
            if ~ isnumeric(config.low_pass) || isnan(config.low_pass)
                message = [message, '- Low pass frequency must be numeric\n\n'];
            else
                if (config.low_pass <= 0) || (config.low_pass >= 5000)
                    message = [message, '- Low pass frequency must be greater then 0 and less than the half of EMG framerate (default = 5000 Hz)\n\n'];
                end
            end
            
            if ~ isnumeric(config.high_pass) || isnan(config.high_pass)
                message = [message, '- High pass frequency must be numeric\n\n'];
            else
                if (config.high_pass <= 0) || (config.high_pass >= config.low_pass)
                    message = [message, '- High pass frequency must be greater then 0 and less than Low pass frequency\n\n'];
                end
            end
            
            if ~ isnumeric(config.n_points) || isnan(config.n_points)
                message = [message, '- Number of points to normalize cycle must be numeric\n\n'];
            else
                if mod(config.n_points, 1) ~= 0
                    message = [message, '- Number of points to normalize cycle must be an integer\n\n'];
                else
                    if (config.n_points < 10) || (config.n_points > 10000)
                        message = [message, '- Number of points to normalize cycle must be greater then 9 and less than 10001\n\n'];
                    end
                end                
            end
            
            if ~ isnumeric(config.n_synergies_max) || isnan(config.n_synergies_max)
                message = [message, '- Max number of synergies must be numeric\n\n'];
            else
                if mod(config.n_synergies_max, 1) ~= 0
                    message = [message, '- Max number of synergies must be an integer\n\n'];
                else
                    if (config.n_synergies_max < 2) || (config.n_synergies_max > length(obj.parent_obj.data.all_muscles))
                        message = [message, '- Max number of synergies must be greater then 1 and less than (Number of muscles + 1)\n\n'];
                    end
                end                
            end
            
            if ~ isnumeric(config.nnmf_replicates) || isnan(config.nnmf_replicates)
                message = [message, '- Max number of NNMF replicates must be numeric\n\n'];
            else
                if mod(config.nnmf_replicates, 1) ~= 0
                    message = [message, '- Max number of NNMF replicates must be an integer\n\n'];
                else
                    if (config.nnmf_replicates < 4) || (config.nnmf_replicates > 50)
                        message = [message, '- Max number of NNMF replicates must be greater then 3 and less than 51\n\n'];
                    end
                end                
            end
            
            if ~ iscell(config.nnmf_stop_criterion) || ~ ischar(config.nnmf_stop_criterion{:})
                message = [message, '- Stop criterion for Number of synergies must be a string\n\n'];
            else
                nnmf_stop_criterion = config.nnmf_stop_criterion{:};                
                if ~ any(strcmp(nnmf_stop_criterion(1:2), {'N=', 'R=', 'BL'}))
                    message = [message, '- Stop criterion for Number of synergies must start with "N=.." (N synergies), "R=.." (R square criteria) or "BL" (Best Linear Fit method)\n\n'];
                else
                    
                    if strcmp(nnmf_stop_criterion(1:2), 'N=')
                        number_ = str2double(nnmf_stop_criterion(3:end));
                        if ~ isnumeric(number_) || isnan(number_)
                            message = [message, '- Number of synergies  must be numeric\n\n'];
                        else
                            if mod(number_, 1) ~= 0
                                message = [message, '-  Number of synergies must be an integer\n\n'];
                            else
                                if (number_ < 2) || (number_ > config.n_synergies_max)
                                    message = [message, '- Number of synergies must be greater then 1 and less than Max number of synergies\n\n'];
                                end
                            end                
                        end
                    
                    elseif strcmp(nnmf_stop_criterion(1:2), 'R=')
                        r_squared_ = str2double(nnmf_stop_criterion(3:end));
                        if ~ isnumeric(r_squared_) || isnan(r_squared_)
                            message = [message, '- R squared parameter must be numeric\n\n'];
                        else                            
                            if (r_squared_ <= 0) || (r_squared_ >= 1)
                                message = [message, '- R squared parameter must be greater then 0 and less than 1\n\n'];
                            end                
                        end
                    end
                    
                end                
            end
            
        end
        
    end

end
