classdef ProgressBar < handle
    
    properties
        
        bar_handle;
        name;
        n_total;
        closeable = 'yes';
        
    end
    
    
    methods
        
        function obj = ProgressBar(name, n_total, on_top, closeable)
            
            obj.name = name;
            obj.n_total = n_total;
            obj.closeable = closeable;
            
            if strcmp(on_top, 'yes')
                window_style = 'modal';
            else
                window_style = 'normal';
            end
            
            obj.bar_handle = waitbar(0, sprintf('Stage: 0/%d', obj.n_total), 'Name', obj.name, 'WindowStyle', window_style);
            
            if strcmp(closeable, 'no')
                set(obj.bar_handle, 'CloseRequestFcn', '');
            end
            
        end
        
        
        function update(obj, n)
            waitbar(n / obj.n_total, obj.bar_handle, sprintf('Stage: %d/%d', n, obj.n_total));
            pause(0.1);
            if n == obj.n_total
                obj.close();
            end
        end
        
        
        function close(obj)
            delete(obj.bar_handle);
        end
        
    end
    
end

