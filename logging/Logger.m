classdef Logger
  
    properties
        parent_obj;
        
        logger_tab;
        log_message;
        string_length;
        
        order;
        FontSize;
        
    end
    
    
    methods
        
        function obj = init_log(obj, parent_obj, logging_panel, app_name, order, FS)
            obj.parent_obj = parent_obj;
            
            obj.FontSize = FS;
            obj.order = order;
            obj.logger_tab = uicontrol(logging_panel, 'Style', 'Listbox', 'String', {sprintf('%s -- %s application launch --', datestr(now, 0), app_name)}, 'FontSize', obj.FontSize, 'Units', 'normal', 'Position', [.0 .0 1.0 1.0]);
            obj.log_message = get(obj.logger_tab, 'String');
            
            obj.parent_obj.logger = obj;
        end
        
        
        function obj = message(obj, message_type, message, matlab_exception_)
            obj = obj.parent_obj.logger;
            
            relative_position = obj.logger_tab.Parent.Position;
            global_position = obj.logger_tab.Parent.Parent.Position;
            obj.string_length = floor(global_position(3) * relative_position(3));
            
            message = sprintf('%s -- %s -- %s', datestr(now, 0), message_type, message);
            switch message_type
                case {'ERROR', 'WARNING'}
                    if exist('matlab_exception_', 'var')
                        message = [message sprintf('\n-- Matlab -- %s', matlab_exception_.message)];
                    end
            end
            
            if strcmp(obj.order, 'ascending')
                obj.log_message{end+1} = message; 
            elseif strcmp(obj.order, 'descending')
                obj.log_message = [{message}, obj.log_message];
            end
            
            wrapped_log_message = textwrap(obj.log_message, obj.string_length);
            set(obj.logger_tab, 'String', wrapped_log_message)
            
            obj.parent_obj.logger = obj;
        end
        
    end
    
end