classdef Config
  
    properties
        
        FontSize;
        
        parent_obj;
        config_file;        
        
        parameters;
        default_values;
        config_base;
        
        current_config;
        
        logger;
        
    end
    
    
    methods(Static)        
        
        function name = get_name(config, n_config_)
            if exist('n_config_', 'var')
                if strcmp(n_config_, 'all')
                    name = config.Properties.RowNames;
                else
                    name = config.Properties.RowNames{n_config_};
                end
                
            else
                name = config.Properties.RowNames{:};
            end            
        end
        
    end
    
    
    methods
        
        function obj = init(obj, parent_obj, config_file, parameters, default_values)
            obj.parent_obj = parent_obj;
            obj.FontSize = obj.parent_obj.FontSize;
            obj.logger = obj.parent_obj.logger;
            
            obj.config_file = config_file;
            obj.parameters = parameters;
            obj.default_values = default_values;
            
            default_config = obj.create_config(obj.default_values, 'default');
            
            try
                loaded = load(obj.config_file, 'config_base', 'current_config_name');               
                current_config_name = loaded.current_config_name;
                obj.config_base = loaded.config_base;                
                obj = obj.add_config_(default_config); % add only if default config doesn't exist
            catch except
                obj.logger.message('WARNING', 'Config file does not exist or is corrupted. Creating default config file.', except);
                obj.config_base = default_config;
                current_config_name = 'default';
                
                config_base = obj.config_base;
                save(obj.config_file, 'config_base', 'current_config_name');
            end            
            
            obj = obj.set_config_(current_config_name);
            
            obj.parent_obj.config = obj;
        end
        
        
        function obj = set_config(obj, config_name)
            obj = obj.parent_obj.config;
            obj = obj.set_config_(config_name);
            obj.parent_obj.config = obj;
        end
        
        
        function [obj, add_flag] = add_config(obj, config)
            obj = obj.parent_obj.config;
            config_name = obj.get_name(config);
            add_flag = 0;
            
            if ~ any(strcmp(obj.get_name(obj.config_base, 'all'), config_name))
                add_flag = 1;
            elseif ~ strcmp(config_name, 'default')
                confirm = questdlg(sprintf('The config "%s" already exists, overwrite the config?', add_backslash(config_name, '_')), 'Overwrite config', 'Yes', 'No', obj.parent_obj.yes_no_question_opts);            
                switch confirm
                    case 'Yes'
                        obj = obj.delete_config_(config_name);
                end
            else
                warndlg('\color{blue} The "default" config cannot be overwritten. Rename your config to save.', 'Config WARNING', struct('WindowStyle','modal', 'Interpreter','tex'));
            end
            obj = obj.add_config_(config);
            
            obj.parent_obj.config = obj;
        end
        
        
        function obj = delete_config(obj, config_name)
            obj = obj.parent_obj.config;
            
            if size(obj.config_base, 1) >1
                confirm = questdlg(sprintf('Delete "%s" configuration?', add_backslash(config_name, '_')), 'Delete config', 'Yes', 'No', obj.parent_obj.yes_no_question_opts);            
                switch confirm
                    case 'Yes'
                        obj = obj.delete_config_(config_name);
                        obj.logger.message('INFO', sprintf('Config named "%s" deleted from the config database.', config_name));
                end
                
            else
                warndlg('\color{blue} The last config in the config database cannot be deleted.', 'Config WARNING', struct('WindowStyle','modal', 'Interpreter','tex'));
            end
            
            obj.parent_obj.config = obj;
        end
        
        
        function obj = load_config_from_file(obj, filename)
            obj = obj.parent_obj.config;
            
            try
                load(filename, 'config');
                config_name = obj.get_name(config);
                
                if ~ any(strcmp(obj.get_name(obj.config_base, 'all'), config_name))
                    obj = obj.add_config_(config);
                    obj.logger.message('INFO', sprintf('Config named "%s" is loaded from %s and saved in the config database.', config_name, filename));
                else
                    if ~ isempty(setdiff(config, obj.config_base(config_name, :)))
                        add_to_name = strsplit(filename, {'/', '\'});
                        add_to_name = strrep(add_to_name(end), '.', '_');
                        new_config_name = [config_name '_' add_to_name];
                        config.Properties.RowNames = {new_config_name};
                        
                        obj = obj.add_config_(config);
                        obj.logger.message('WARNING', sprintf('Config named "%s" already exist, loaded config saved as "%s"', config_name, new_config_name));
                    else                        
                        obj = obj.set_config_(config_name);
                        obj.logger.message('INFO', sprintf('Loaded config named "%s" already existed in the config database.', config_name));
                    end
                end
                
                
            catch except
                obj.logger.message('WARNING', sprintf('There is no config in the file %s, or config stucture is wrong', filename), except);
            end
            
            obj.parent_obj.config = obj;
        end
         
        
        function obj = set_config_(obj, config_name)
            current_config_name = config_name;
            
            try
                obj.current_config = obj.config_base(current_config_name, :);
                obj.logger.message('INFO', sprintf('Config named "%s" is set', current_config_name));
            catch except
                obj.current_config = obj.config_base('default', :);
                obj.logger.message('ERROR', sprintf('Config named "%s" does not exist. Config set to "default".', current_config_name), except);
            end
            
            config_base = obj.config_base;
            save(obj.config_file, 'config_base', 'current_config_name', '-append');
        end
        
        
        function obj = add_config_(obj, config, warning_)
            config_name = obj.get_name(config);
            
            if ~ any(strcmp(obj.get_name(obj.config_base, 'all'), config_name))                
                obj.config_base = [config; obj.config_base];
                config_base = obj.config_base;                
                obj.logger.message('INFO', sprintf('Config named "%s" added to config database.', config_name));
                obj = obj.set_config_(config_name);
            else
                if exist('warning_', 'var')
                    obj.logger.message('ERROR', sprintf('Config named "%s" already exists in config database.', config_name));
                    warndlg(['\color{blue}' sprintf('Config "%s" already exists in config database. Rename your config to save.', add_backslash(config_name, '_'))], 'Config WARNING', struct('WindowStyle','modal', 'Interpreter','tex'));
                end
            end              
        end
        
        
        function obj = delete_config_(obj, config_name)
            current_config_name = obj.get_name(obj.current_config);
            
            obj.config_base(config_name, :) = [];

            if strcmp(config_name, current_config_name)
                current_config_name = obj.get_name(obj.config_base, 1);
            end

            obj = obj.set_config_(current_config_name);
        end
        
        
        function config = create_config(obj, values, name)
            config = cell2table(values, 'VariableNames', obj.parameters, 'RowNames', {name});            
        end
                
    end
    
end


