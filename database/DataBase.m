classdef DataBase
  
    properties
        
        FontSize;
        database_file;
        parent_obj;
        
        n_files;
        
        module_idx_columns = {'subject', 'condition', 'side', 'nmf_stop_criteria'};
        maps_idx_columns = {'subject', 'condition', 'side'};
        
        module_database;
        maps_database;
        clustering;
        maps_patterns;
        
        subjects;
        conditions;
        sides;
                
        figure_handle;
        subject_name;
        subject_list;
        side_name;
        side_list;
        condition_names;
        condition_lists;
        button_Save_Modules;
        
        logger;
        
    end
    
    
    methods(Static)
        
        function cell_data = row_wise_cell_concat(cell_data)
            cell_data = arrayfun(@(x)fullfile(cell_data{x, :}), (1:size(cell_data, 1))', 'un', 0);
        end
        
        
        function unique_cells = find_unique_cells(cell_column)
            [~, idx] = unique(cell_column);
            unique_cells = cell_column(idx)';
        end
        
    end
    
    
    methods
        
        function obj = init(obj, parent_obj, database_file, N_clusters)
            
            obj.parent_obj = parent_obj;
            obj.FontSize = obj.parent_obj.FontSize;
            obj.logger = obj.parent_obj.logger;
            
            obj.database_file = database_file;
            
            try
                loaded = load(obj.database_file);
                obj.module_database = loaded.('module_database');
                obj.maps_database = loaded.('maps_database');
                
                try
                    obj.clustering = loaded.(['clustering_' int2str(N_clusters)]);
                catch
                    obj.logger.message('WARNING', sprintf('No clustering precomputed for %d clusters in the database. Modules comparison with reference will not be available.', N_clusters));
                end
                try
                    obj.maps_patterns = loaded.('maps_patterns');
                catch
                    obj.logger.message('WARNING', 'No spinal maps patterns precomputed in the database. Maps comparison with reference will not be available.');
                end
                
                columns = obj.module_database.Properties.VariableNames;
                idx_weights = cell_contains(columns, '_weight');
                muscle_list = cellfun (@(x) x(1:end-7), columns(idx_weights), 'un', 0);
                init_list = obj.parent_obj.data.muscle_list;
                try
                    assert((length(muscle_list) == length(init_list)) & (length(intersect(muscle_list, init_list)) == length(init_list)));
                catch
                    obj.database_file = [];
                    obj.module_database = [];
                    obj.maps_database = [];
                    obj.logger.message('ERROR', sprintf('Muscle list in %s database [%s] does not match initial PEPATO list [%s]. Database is not loaded. Please change the database or initial muscle list.', ...
                        obj.database_file, strjoin(muscle_list, ', '), strjoin(init_list, ', ')));
                end
                
            catch except
                if exist(obj.database_file, 'file') == 2
                    obj.database_file = [obj.database_file(1:end-4) '_' rand_string_gen(3) '.mat'];
                end
                obj.logger.message('WARNING', sprintf('Database does not exist or is corrupted. Comparison with reference will not be available. Creating empty database %s.', obj.database_file), except);
                
                
                muscle_list = obj.parent_obj.data.muscle_list;
                n_points = obj.parent_obj.config.current_config.n_points;
                
                obj.module_database = array2table(zeros(0, length(obj.module_idx_columns)+4+length(muscle_list)+n_points));
                obj.module_database.Properties.VariableNames = [obj.module_idx_columns, 'n_synergies', 'reco_quality', 'pattern_fwhm', 'pattern_coa', ...
                    strcat(muscle_list, {'_weight'}), strcat({'pattern_'}, strsplit(num2str(1:n_points)))];
                
                obj.maps_database = array2table(zeros(0, length(obj.maps_idx_columns)+5+2*n_points));
                obj.maps_database.Properties.VariableNames = [obj.maps_idx_columns, 'sacral_max', 'lumbar_max', 'sacral_fwhm', 'lumbar_fwhm', 'coact_index', ...
                    strcat({'sacral_pat_'}, strsplit(num2str(1:n_points))), strcat({'lumbar_pat_'}, strsplit(num2str(1:n_points)))];
                
                obj.save_database('init');
            end
            
            obj.parent_obj.database = obj;
        end
        
        
        function obj = save_database(obj, init_flag)
            if nargin < 2
                init_flag = 'append';
            end
            
            module_database = obj.module_database;
            maps_database = obj.maps_database;
            switch init_flag
                case 'init'
                    save(obj.database_file, 'module_database', 'maps_database');
                case 'append'
                    save(obj.database_file, 'module_database', 'maps_database', '-append');
            end
        end
        
        
        function obj = get_database_info(obj)
            obj = obj.parent_obj.database;
            
            obj.n_files = obj.parent_obj.data.n_files;
            
            if ~ isempty(obj.module_database)
                obj.subjects = obj.find_unique_cells(obj.module_database{:, {'subject'}});
                obj.conditions = obj.find_unique_cells(obj.module_database{:, {'condition'}});
            else
                obj.subjects = {};
                obj.conditions = {};
            end
            
            obj.parent_obj.database = obj;
        end        
        
        
        function obj = input_names(obj)
            obj = obj.parent_obj.database.get_database_info();
            
            [subject_, ~, conditions_] = get_trial_info(obj.parent_obj.data.filenames);
            
            obj.figure_handle = figure('name', 'Save analysis results', 'NumberTitle','off', 'Units', 'normal', 'OuterPosition', [.2 .2 .6 .6], 'WindowStyle', 'modal'); clf;
            set(obj.figure_handle, 'MenuBar', 'none'); set(obj.figure_handle, 'ToolBar', 'none');
            
            annotation(obj.figure_handle, 'textbox', 'String', 'Select subject name:', 'Units', 'normal', 'Position', [.05, .87, .55, .08], 'VerticalAlignment', 'bottom');
            obj.subject_name = uicontrol(obj.figure_handle, 'Style', 'Edit', 'String', subject_, 'Units', 'normal', 'Position', [.05, .77, .55, .08], 'FontSize', obj.FontSize+2);
            obj.subject_list = uicontrol(obj.figure_handle, 'Style', 'ListBox', 'String', obj.subjects, 'Units', 'normal', 'Position', [.05, .65, .55, .1], 'FontSize', obj.FontSize+2);
            obj.subject_list.Callback = @obj.subject_list_selection;
            
            annotation(obj.figure_handle, 'textbox', 'String', sprintf('Side of the body: %s', obj.parent_obj.body_side), 'Units', 'normal', 'Position', [.65, .77, .3, .08], 'VerticalAlignment', 'bottom');
            annotation(obj.figure_handle, 'textbox', 'String', sprintf('NMF stop criteria: %s', obj.parent_obj.data.config.nnmf_stop_criterion{:}), 'Units', 'normal', 'Position', [.65, .65, .3, .1], 'VerticalAlignment', 'middle');
            
            obj.condition_names = cell(1, obj.n_files);
            obj.condition_lists = cell(1, obj.n_files);
            for i = 1:obj.n_files
                annotation(obj.figure_handle, 'textbox', 'String', sprintf('%d file condition:', i), 'Units', 'normal', 'Position', [.05 + (i-1)*.92/obj.n_files, .52, .92/obj.n_files - .02, .08], 'VerticalAlignment', 'bottom');
                obj.condition_names{i} = uicontrol(obj.figure_handle, 'Style', 'Edit', 'String', conditions_{1, i}, 'Units', 'normal', 'Position', [.05 + (i-1)*.92/obj.n_files, .42, .92/obj.n_files - .02, .08], 'FontSize', obj.FontSize+2);
                obj.condition_lists{i} = uicontrol(obj.figure_handle, 'Style', 'ListBox', 'String', obj.conditions, 'Units', 'normal', 'Position', [.05 + (i-1)*.92/obj.n_files, .2, .92/obj.n_files - .02, .2], 'FontSize', obj.FontSize+2);
                obj.condition_lists{i}.Callback = @obj.condition_list_selection;
            end
            
            obj.button_Save_Modules = uicontrol(obj.figure_handle, 'Style', 'pushbutton', 'String', 'Add analysis results to the database', 'FontSize', obj.FontSize+2, 'Units', 'normal', 'Position', [.05 .02 .9 .1]);
            obj.button_Save_Modules.Callback = @obj.button_Save_Modules_pushed; 
            
            obj.parent_obj.database = obj;
        end
        
        
        function subject_list_selection(obj, src, ~)
            n_row = src.Value;
            set(obj.subject_name, 'String', obj.subjects{n_row});
        end
        
        
        function condition_list_selection(obj, src, ~)
            n_row = src.Value;
            i = 1 + round(obj.n_files/.92 * (src.Position(1) - .05));
            set(obj.condition_names{i}, 'String', obj.conditions{n_row});
        end
        
        
        function button_Save_Modules_pushed(obj, ~, ~)
            conditions_ = {};
            for i = 1:obj.n_files
                condition_ = obj.condition_names{i}.String;
                conditions_ = [conditions_, condition_];
            end
            
            [~, idx, ~] = intersect(conditions_, obj.conditions, 'stable');
            new_conditions = conditions_; new_conditions(idx) = [];
            if ~isempty(new_conditions)
                qustopts = obj.parent_obj.yes_no_question_opts;
                qustopts.Default = 'Add';
                
                new_ = questdlg(sprintf('Conditions: \n%s\nare new for the database. Add them?', ...
                add_backslash(strjoin(conditions_, ', '), '_')), ...
                'New conditions', 'Add', 'Fix conditions', qustopts);
                switch new_
                    case 'Fix conditions'
                        return;
                end
            end
            
            save_ = questdlg(sprintf('Save modules and maps for subject "%s" \nconditions: %s?', ...
                add_backslash(obj.subject_name.String, '_'), add_backslash(strjoin(conditions_, ', '), '_')), ...
                'Append analysis results to database', 'Yes', 'No', obj.parent_obj.yes_no_question_opts);
            switch save_
                case 'Yes'
                    obj.add_rows(obj.subject_name.String, conditions_);
                    delete(obj.figure_handle);
            end
        end        
        
        
        function obj = add_rows(obj, subject_id, conditions)
            obj = obj.parent_obj.database;
            
            side_id = obj.parent_obj.body_side;
            basic_patterns = obj.parent_obj.data.basic_patterns;
            muscle_weightings_ = obj.parent_obj.data.muscle_weightings;
            
            muscle_list = obj.parent_obj.data.muscle_list;
            emg_labels = obj.parent_obj.data.emg_label;
            
            BP = cell2mat(basic_patterns)';
            n_rows = size(BP, 1);
            
            subject = repmat({subject_id}, n_rows, 1);
            side = repmat({side_id}, n_rows, 1);
            nmf_stop_criteria = repmat(obj.parent_obj.data.config.nnmf_stop_criterion, n_rows, 1);
            
            condition = cell(n_rows, 1);
            
            n_synergies = NaN(n_rows, 1);
            reco_quality = NaN(n_rows, 1);
            pattern_fwhm = NaN(n_rows, 1);
            pattern_coa = NaN(n_rows, 1);
            
            MW = NaN(n_rows, length(muscle_list));
            
            row_idx = 1;
            for i = 1:obj.n_files 
                n_syn = obj.parent_obj.data.output_data(i).data.('muscle_synergy_number');
                
                condition(row_idx : row_idx+n_syn-1, 1) = repmat(conditions(i), n_syn, 1); 
                
                n_synergies(row_idx : row_idx+n_syn-1, 1) = repmat(n_syn, n_syn, 1);
                reco_quality(row_idx : row_idx+n_syn-1, 1) = repmat(obj.parent_obj.data.output_data(i).data.('emg_reco_quality'), n_syn, 1);
                pattern_fwhm(row_idx : row_idx+n_syn-1, 1) = obj.parent_obj.data.output_data(i).data.('pattern_fwhm')';
                pattern_coa(row_idx : row_idx+n_syn-1, 1) = obj.parent_obj.data.output_data(i).data.('pattern_coa')';
                
                mw = muscle_weightings_{i}';
                for j = 1:length(emg_labels{i})
                    label = emg_labels{i}(j);
                    idx = strcmp(muscle_list, label);
                    MW(row_idx : row_idx+n_syn-1, idx) = mw(:, j);
                end
                
                row_idx = row_idx + n_syn;
            end
            
            rows_to_add = [subject, condition, side, nmf_stop_criteria, num2cell(n_synergies), num2cell(reco_quality), ...
                num2cell(pattern_fwhm), num2cell(pattern_coa), num2cell(MW), num2cell(BP)];
            rows_to_add = cell2table(rows_to_add, 'VariableNames', obj.module_database.Properties.VariableNames);
            
            index2drop = obj.find_index2drop(obj.module_database, obj.module_idx_columns, rows_to_add);
            [rows_to_add, idx_to_add] = obj.find_index2add(obj.module_idx_columns, rows_to_add, index2drop, 'Modules');
            
            obj.module_database = [obj.module_database; rows_to_add];
            
            if ~isempty(rows_to_add)
                obj.logger.message('INFO', sprintf('Modules data indexed "%s" added.', idx_to_add));
            end
            
            
            n_rows = obj.n_files;
            n_points = obj.parent_obj.config.current_config.n_points;
            
            subject = repmat({subject_id}, n_rows, 1);
            side = repmat({side_id}, n_rows, 1);
             
            condition = cell(n_rows, 1);
            sacral_max = NaN(n_rows, 1);
            lumbar_max = NaN(n_rows, 1);
            sacral_fwhm = NaN(n_rows, 1);
            lumbar_fwhm = NaN(n_rows, 1);
            coact_index = NaN(n_rows, 1);
            sacral = NaN(n_rows, n_points);
            lumbar = NaN(n_rows, n_points);
            
            for i = 1:n_rows
                condition(i, 1) = conditions(i);
                max_ = obj.parent_obj.data.output_data(i).data.('motor_pool_max_activation');
                fwhm_ = obj.parent_obj.data.output_data(i).data.('motor_pool_fwhm');
                sacral_max(i, 1) = max_(1, 1);
                lumbar_max(i, 1) = max_(1, 2);
                sacral_fwhm(i, 1) = fwhm_(1, 1);
                lumbar_fwhm(i, 1) = fwhm_(1, 2);
                coact_index(i, 1) = obj.parent_obj.data.output_data(i).data.('motor_pool_coact_index');
                sacral(i, :) = mean(obj.parent_obj.data.motorpools_activation_avg{i}(1:2, :), 1);
                lumbar(i, :) = mean(obj.parent_obj.data.motorpools_activation_avg{i}(4:5, :), 1);
            end
            
            
            rows_to_add = [subject, condition, side, num2cell(sacral_max), num2cell(lumbar_max), ...
                num2cell(sacral_fwhm), num2cell(lumbar_fwhm), num2cell(coact_index), num2cell(sacral), num2cell(lumbar)];
            rows_to_add = cell2table(rows_to_add, 'VariableNames', obj.maps_database.Properties.VariableNames);
            
            index2drop = obj.find_index2drop(obj.maps_database, obj.maps_idx_columns, rows_to_add);
            [rows_to_add, idx_to_add] = obj.find_index2add(obj.maps_idx_columns, rows_to_add, index2drop, 'Maps');
            
            obj.maps_database = [obj.maps_database; rows_to_add];
            
            if ~isempty(rows_to_add)
                obj.logger.message('INFO', sprintf('Spinal maps data indexed "%s" added.', idx_to_add));
            end
            
            
            obj.save_database();
            
            obj.parent_obj.database = obj;
            
        end
        
        
        function index2drop = find_index2drop(obj, base_table, index_columns, rows_to_add)
            base_index = base_table{:, index_columns};
            addrows_index = rows_to_add{:, index_columns};
            if ~ isempty(base_index)
                index2drop = ismember(obj.row_wise_cell_concat(base_index), obj.row_wise_cell_concat(addrows_index));
            else
                index2drop = zeros(size(addrows_index));
            end
        end
        
        
        function [rows_to_add, idx_to_add] = find_index2add(obj, index_columns, rows_to_add, index2drop, base_name)
            if sum(index2drop) ~= 0 
                if sum(index2drop) < size(rows_to_add, 1)
                    idx_to_add = rows_to_add{~ index2drop, index_columns};
                    idx_to_add = strjoin(obj.find_unique_cells(obj.row_wise_cell_concat(idx_to_add)), ', '); 
                    to_drop = rows_to_add{index2drop, index_columns};
                    to_drop = strjoin(obj.find_unique_cells(obj.row_wise_cell_concat(to_drop)), ', ');

                    obj.logger.message('WARNING', sprintf('%s analysis data indexed "%s" added; %s analysis data indexed "%s" already exists in modules database.', base_name, idx_to_add, base_name, to_drop));
                    rows_to_add = rows_to_add(~ index2drop, :);
                else
                    idx_to_add = [];
                    to_drop = rows_to_add{:, index_columns};
                    to_drop = strjoin(obj.find_unique_cells(obj.row_wise_cell_concat(to_drop)), ', ');
                    
                    obj.logger.message('WARNING', sprintf('%s analysis data indexed "%s" already exists in modules database. Nothing to add.', base_name, to_drop));
                    rows_to_add = {};
                    
                    %warn_handler = warndlg('\color{blue} Nothing to add to the database. All data with the specified index is already in the database.', 'Database WARNING', struct('WindowStyle','modal', 'Interpreter','tex'));
                    %drawnow;
                    %waitfor(warn_handler);
                end
            else
                idx_to_add = rows_to_add{:, index_columns};
                idx_to_add = strjoin(obj.find_unique_cells(obj.row_wise_cell_concat(idx_to_add)), ', '); 
            end
        end
                
    end
    
end
