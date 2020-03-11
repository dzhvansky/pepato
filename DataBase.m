classdef DataBase
  
    properties
        
        FontSize;
        database_file;
        parent_obj;
        
        n_files;
        
        index_columns;
        
        database;
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
        
        function obj = init(obj, parent_obj, database_file)
            obj.parent_obj = parent_obj;
            obj.FontSize = obj.parent_obj.FontSize;
            obj.logger = obj.parent_obj.logger;
            
            obj.database_file = database_file;
            obj.index_columns = {'subject', 'condition', 'side', 'nmf_stop_criteria'};
            
            try
                 loaded = load(obj.database_file);
                 obj.database = loaded.module_database;
            catch except
                obj.logger.message('WARNING', 'Modules database does not exist or is corrupted. Creating empty database.', except);
                
                muscle_list = obj.parent_obj.data.muscle_list;  
                obj.database= array2table(zeros(0, 216));
                disp(muscle_list);
                obj.database.Properties.VariableNames = [obj.index_columns, strcat(muscle_list, {'_weight'}), strcat({'pattern_'}, strsplit(num2str(1:200)))];
                
                obj.save_database();
            end
            
            obj.parent_obj.database = obj;
        end
        
        
        function obj = save_database(obj)        
            module_database = obj.database;
            save(obj.database_file, 'module_database');
        end
        
        
        function obj = get_database_info(obj)
            obj = obj.parent_obj.database;
            
            obj.n_files = obj.parent_obj.data.n_files;
            
            obj.sides = {'left', 'right'};
            
            if ~ isempty(obj.database)
                obj.subjects = obj.find_unique_cells(obj.database{:, {'subject'}});
                obj.conditions = obj.find_unique_cells(obj.database{:, {'condition'}});
            else
                obj.subjects = {};
                obj.conditions = {};
            end
            
            obj.parent_obj.database = obj;
        end        
        
        
        function obj = input_names(obj)
            obj = obj.parent_obj.database.get_database_info();            
            
            obj.figure_handle = figure('name', 'Save modules', 'NumberTitle','off', 'Units', 'normal', 'OuterPosition', [.2 .2 .6 .6], 'WindowStyle', 'modal'); clf;
            set(obj.figure_handle, 'MenuBar', 'none'); set(obj.figure_handle, 'ToolBar', 'none');
            
            annotation(obj.figure_handle, 'textbox', 'String', 'Select subject name:', 'Units', 'normal', 'Position', [.05, .87, .55, .08], 'VerticalAlignment', 'bottom');
            obj.subject_name = uicontrol(obj.figure_handle, 'Style', 'Edit', 'String', '', 'Units', 'normal', 'Position', [.05, .77, .55, .08]);
            obj.subject_list = uicontrol(obj.figure_handle, 'Style', 'ListBox', 'String', obj.subjects, 'Units', 'normal', 'Position', [.05, .65, .55, .1]);
            obj.subject_list.Callback = @obj.subject_list_selection;
            annotation(obj.figure_handle, 'textbox', 'String', 'Select side of the body:', 'Units', 'normal', 'Position', [.65, .87, .3, .08], 'VerticalAlignment', 'bottom');
            obj.side_name = uicontrol(obj.figure_handle, 'Style', 'Edit', 'Enable', 'off', 'String', '', 'Units', 'normal', 'Position', [.65, .77, .3, .08]);
            obj.side_list = uicontrol(obj.figure_handle, 'Style', 'ListBox', 'String', obj.sides, 'Units', 'normal', 'Position', [.65, .65, .3, .1]);
            obj.side_list.Callback = @obj.side_list_selection;
            
            obj.condition_names = cell(1, obj.n_files);
            obj.condition_lists = cell(1, obj.n_files);
            for i = 1:obj.n_files
                annotation(obj.figure_handle, 'textbox', 'String', sprintf('%d file condition:', i), 'Units', 'normal', 'Position', [.05 + (i-1)*.92/obj.n_files, .52, .92/obj.n_files - .02, .08], 'VerticalAlignment', 'bottom');
                obj.condition_names{i} = uicontrol(obj.figure_handle, 'Style', 'Edit', 'String', '', 'Units', 'normal', 'Position', [.05 + (i-1)*.92/obj.n_files, .42, .92/obj.n_files - .02, .08]);
                obj.condition_lists{i} = uicontrol(obj.figure_handle, 'Style', 'ListBox', 'String', obj.conditions, 'Units', 'normal', 'Position', [.05 + (i-1)*.92/obj.n_files, .2, .92/obj.n_files - .02, .2]);
                obj.condition_lists{i}.Callback = @obj.condition_list_selection;
            end
            
            obj.button_Save_Modules = uicontrol(obj.figure_handle, 'Style', 'pushbutton', 'String', 'Save modules with names chosen', 'FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.05 .02 .9 .1]);
            obj.button_Save_Modules.Callback = @obj.button_Save_Modules_pushed; 
            
            obj.parent_obj.database = obj;
        end
        
        
        function subject_list_selection(obj, src, ~)
            n_row = src.Value;
            set(obj.subject_name, 'String', obj.subjects{n_row});
        end
        
        
        function side_list_selection(obj, src, ~)
            n_row = src.Value;
            set(obj.side_name, 'String', obj.sides{n_row});
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
            
            save_ = questdlg(sprintf('Save modules for subject "%s" %s body side \nconditions: %s?', ...
                add_backslash(obj.subject_name.String, '_'), obj.side_name.String, add_backslash(strjoin(conditions_, ', '), '_')), ...
                'Save modules', 'Yes', 'No', obj.parent_obj.yes_no_question_opts);
            switch save_
                case 'Yes'
                    obj.add_rows(obj.subject_name.String, obj.side_name.String, conditions_);
                    delete(obj.figure_handle);
            end
        end        
        
        
        function obj = add_rows(obj, subject_id, side, conditions)
            obj = obj.parent_obj.database;
            
            basic_patterns = obj.parent_obj.data.basic_patterns;
            muscle_weightings_ = obj.parent_obj.data.muscle_weightings;
            
            muscle_list = obj.parent_obj.data.muscle_list;
            emg_labels = obj.parent_obj.data.emg_label;
            
            n_rows = size(cell2mat(basic_patterns)', 1);
            
            subject = repmat({subject_id}, n_rows, 1);
            
            condition = {};
            for i = 1:obj.n_files 
                condition = [condition; repmat(conditions(i), size(basic_patterns{i}, 2), 1)]; 
            end
            
            side = repmat({side}, n_rows, 1);
            
            nmf_stop_criteria = repmat(obj.parent_obj.data.config.nnmf_stop_criterion, n_rows, 1);
            
            MW = NaN(n_rows, length(muscle_list));
            col_shift = 0;
            for i = 1:length(muscle_weightings_)
                mw = muscle_weightings_{i}';
                n_rows_ = size(mw, 1);
                for j = 1:length(emg_labels{i})
                    label = emg_labels{i}(j);
                    idx = strcmp(muscle_list, label);
                    MW(col_shift+1: col_shift+n_rows_, idx) = mw(:, j);
                end
                col_shift = col_shift + n_rows_;
            end
            
            BP = cell2mat(basic_patterns)';
            
            rows_to_add = [subject, condition, side, nmf_stop_criteria, num2cell(MW), num2cell(BP)];
            rows_to_add = cell2table(rows_to_add, 'VariableNames', obj.database.Properties.VariableNames);
            
            index2drop = obj.find_index2drop(obj.database, rows_to_add, obj.index_columns);
            
            if sum(index2drop) ~= 0 
                if sum(index2drop) < size(rows_to_add, 1)
                    to_add = rows_to_add{~ index2drop, obj.index_columns};
                    to_add = strjoin(obj.find_unique_cells(obj.row_wise_cell_concat(to_add)), ', '); 
                    to_drop = rows_to_add{index2drop, obj.index_columns};
                    to_drop = strjoin(obj.find_unique_cells(obj.row_wise_cell_concat(to_drop)), ', ');

                    obj.logger.message('WARNING', sprintf('Synergy analysis data indexed "%s" added; Synergy analysis data indexed "%s" already exists in modules database.', to_add, to_drop));
                    rows_to_add = rows_to_add(~ index2drop, :);
                else
                    to_drop = rows_to_add{:, obj.index_columns};
                    to_drop = strjoin(obj.find_unique_cells(obj.row_wise_cell_concat(to_drop)), ', ');
                    
                    obj.logger.message('WARNING', sprintf('Synergy analysis data indexed "%s" already exists in modules database. Nothing to add.', to_drop));
                    rows_to_add = {};
                    
                    warn_handler = warndlg('\color{blue} Nothing to add to the database. All data with the specified index is already in the database.', 'Database WARNING', struct('WindowStyle','modal', 'Interpreter','tex'));
                    drawnow;
                    waitfor(warn_handler);
                end
            else
                to_add = rows_to_add{:, obj.index_columns};
                to_add = strjoin(obj.find_unique_cells(obj.row_wise_cell_concat(to_add)), ', '); 
            end
            
            obj.database = [obj.database; rows_to_add];
            obj.save_database();
            
            if ~isempty(rows_to_add)
                obj.logger.message('INFO', sprintf('Modules data indexed "%s" added.', to_add));
            end
            
            obj.parent_obj.database = obj;
            
        end
        
        
        function index2drop = find_index2drop(obj, base_table, rows_to_add, index_columns)
            base_index = base_table{:, index_columns};
            addrows_index = rows_to_add{:, index_columns};
            if ~ isempty(base_index)
                index2drop = ismember(obj.row_wise_cell_concat(base_index), obj.row_wise_cell_concat(addrows_index));
            else
                index2drop = zeros(size(addrows_index));
            end
        end
                
    end
    
end
