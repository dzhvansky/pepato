classdef FigSpinalmaps < handle
    
    properties
        handle_obj;
        
        n_points;
        
        motorpools_activation; 
        motorpools_activation_avg;
        
        maps_patterns;
        sacral;
        lumbar;
        
        fig_list;
    end    
    
    
    methods
        
        function obj = FigSpinalmaps(handle_obj, motorpools_activation, motorpools_activation_avg, maps_patterns, sacral, lumbar)
            obj.handle_obj = handle_obj;
            obj.motorpools_activation = motorpools_activation;
            obj.motorpools_activation_avg = motorpools_activation_avg;
            obj.maps_patterns = maps_patterns;
            obj.sacral = sacral;
            obj.lumbar = lumbar;
            
            obj.n_points = size(obj.motorpools_activation_avg, 2);
            
            obj.fig_list = uicontrol(obj.handle_obj, 'Style', 'ListBox', 'String', {'Smoothed map', 'Raw map', 'Pattern reference'}, 'Value', 1, 'Units', 'normal', 'Position', [.15, .01, .08, .07]);
            obj.fig_list.Callback = @obj.fig_list_selection;
            
            obj.draw_avg_activation()
            obj.draw_smoothed_map()
            obj.link_axes()
        end
        
        
        function draw_avg_activation(obj)
            axes('Parent', obj.handle_obj);
            
            subplot('Position', [.15 .55 .7, .35]);
            for j = 1:6
                plot(linspace(1, 100, obj.n_points), obj.motorpools_activation_avg(7-j, :), 'Tag', ['mp_activation_' num2str(j)]); hold on;
            end
            legend({'L2' 'L3' 'L4' 'L5' 'S1' 'S2'});
            set(gca, 'XTick', 0:20:100); 
            set(gca, 'XTickLabel', 0:20:100);
            xlim([1 100]);
            ylabel('Relative power of MP activation');
        end
        
        
        function draw_raw_map(obj)
            axes('Parent', obj.handle_obj);
            
            subplot('Position', [.15 .1 .7, .35]);
            contourf(linspace(1, 100, obj.n_points), 1:36, obj.motorpools_activation, 30, 'LineStyle', 'none', 'Tag', 'mp_contour_raw');
            c2max = max(max(obj.motorpools_activation));
            caxis([0 c2max]);   
            set(gca, 'YTick', 3.5:6:33.5); 
            set(gca, 'YTickLabel', {'S2' 'S1' 'L5' 'L4' 'L3' 'L2'});
            set(gca, 'XTick', 0:20:100); 
            set(gca, 'XTickLabel', 0:20:100);
            ylabel('Spinal cord segments');
            xlabel('percent of movement cycle');
            xlim([1 100]);
        end
        
        
        function draw_smoothed_map(obj)
            axes('Parent', obj.handle_obj);
            
            subplot('Position', [.15 .1 .7, .35]);
            contourf(linspace(1, 100, obj.n_points), 1:6, obj.motorpools_activation_avg, 30, 'LineStyle', 'none', 'Tag', 'mp_contour_smooth'); 
            c2max = max(max(obj.motorpools_activation_avg));
            caxis([0 c2max]);   
            set(gca, 'YTick', 1:6); 
            set(gca, 'YTickLabel', {'S2' 'S1' 'L5' 'L4' 'L3' 'L2'});
            set(gca, 'XTick', 0:20:100); 
            set(gca, 'XTickLabel', 0:20:100);
            ylabel('Spinal cord segments');
            xlabel('percent of movement cycle');
            xlim([1 100]);
        end
        
        
        function draw_pattern_reference(obj)
            axes('Parent', obj.handle_obj);
            
            sacral_mean = obj.maps_patterns.('sacral').('mean_val');
            lumbar_mean = obj.maps_patterns.('lumbar').('mean_val');
            sacral_sd = obj.maps_patterns.('sacral').('std_val');
            lumbar_sd = obj.maps_patterns.('lumbar').('std_val');
            ref_points = length(sacral_mean);
            
            subplot('Position', [.15 .1 .7, .35]);
            plot(linspace(1, 100, obj.n_points), obj.sacral, 'Color', 'g', 'LineWidth', 1.5, 'Tag', 'mp_sacral', 'DisplayName', 'Sacral activation'); hold on;
            plot(linspace(1, 100, obj.n_points), obj.lumbar, 'Color', 'r', 'LineWidth', 1.5, 'Tag', 'mp_lumbar', 'DisplayName', 'Lumbar activation');
            plot(linspace(1, 100, ref_points), sacral_mean, 'Color', [0.3835 0.7095 0.5605], 'Tag', 'mp_ref_sacral', 'DisplayName', 'Reference pattern sacral');
            plot(linspace(1, 100, ref_points), lumbar_mean, 'Color', [0.8895 0.5095 0.1115], 'Tag', 'mp_ref_lumbar', 'DisplayName', 'Reference pattern lumbar');
            h = fill([linspace(1, 100, ref_points) fliplr(linspace(1, 100, ref_points))], ...
                [max(sacral_mean - sacral_sd, zeros(1, ref_points)) fliplr(sacral_mean + sacral_sd)], ...
                [0.3835 0.7095 0.5605], 'EdgeColor', 'None', 'FaceAlpha', .2);
            h.Annotation.LegendInformation.IconDisplayStyle = 'off';
            h = fill([linspace(1, 100, ref_points) fliplr(linspace(1, 100, ref_points))], ...
                [max(lumbar_mean - lumbar_sd, zeros(1, ref_points)) fliplr(lumbar_mean + lumbar_sd)], ...
                [0.8895 0.5095 0.1115], 'EdgeColor', 'None', 'FaceAlpha', .2);
            h.Annotation.LegendInformation.IconDisplayStyle = 'off';
            
            legend('-DynamicLegend', 'Location', 'best');
            set(gca, 'XTick', 0:20:100); 
            set(gca, 'XTickLabel', 0:20:100);
            xlabel('percent of movement cycle');
            xlim([1 100]);
            ylabel('Relative power of MP activation');
            hold off;
        end
        
        
        function link_axes(obj)
            linkaxes(find_axes_by_plot(obj.handle_obj, 'mp_*'), 'x'); % linking of subplot axes for X-axis
        end
        
        
        function fig_list_selection(obj, ~, ~)
            selected = get(obj.fig_list, 'Value');
            selected = obj.fig_list.String{selected};
            
            if ~strcmp(selected, 'Pattern reference') || ~isempty(obj.maps_patterns)
                eval(sprintf('obj.draw_%s()', strrep(lower(selected), ' ', '_')));
                obj.link_axes();
            else
                msgbox('There is no reference data for spinal maps.', 'Database error');
            end
        end
        
    end
    
end
