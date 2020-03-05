classdef FigSynergies < handle
    
    properties
        handle_obj;
        
        emg_patterns;
        emg_patterns_sd;
        
        c_normalized_mean;
        c_normalized_sd;
        w_normalized;
        nmf_r2;
        
        colors;
        emg_label;
        
        fig_list;
        
        n_synergies;
        n_points;
        n_emg;
    end    
    
    
    methods
        
        function obj = FigSynergies(handle_obj,  emg_patterns, emg_patterns_sd, c_normalized_mean, c_normalized_sd, w_normalized, nmf_r2, emg_label, all_colors)
            obj.handle_obj = handle_obj;
            obj.colors = all_colors;
            obj.emg_label = emg_label;
            
            obj.emg_patterns = emg_patterns;
            obj.emg_patterns_sd = emg_patterns_sd;
            obj.c_normalized_mean = c_normalized_mean;
            obj.c_normalized_sd = c_normalized_sd;
            obj.w_normalized = w_normalized;
            obj.nmf_r2 = nmf_r2;
            
            obj.n_synergies = size(obj.c_normalized_mean, 2);
            obj.n_points = size(obj.c_normalized_mean, 1);
            obj.n_emg  = size(obj.emg_label, 2);
            
            obj.fig_list = uicontrol(obj.handle_obj, 'Style', 'ListBox', 'String', {'Temporal components', 'EMG decomposition + VAF'}, 'Value', 1, 'Units', 'normal', 'Position', [.85, .92, .14, .06]);
            obj.fig_list.Callback = @obj.fig_list_selection;
            
            obj.fig_list_selection()
            obj.link_axes()
        end
        
        
        function draw_temporal_components(obj)
            axes('Parent', obj.handle_obj);
            
            for i = 1:obj.n_synergies
                subplot('Position', [.1, .08+(obj.n_synergies-i)*.83/obj.n_synergies, .35, .75/obj.n_synergies]);

                plot(obj.c_normalized_mean(:, i), 'Color', obj.colors(i, :), 'LineWidth', 2, 'Tag', ['temporal_' num2str(i)]); hold on;
                pattern_sd = fill([1:obj.n_points fliplr(1:obj.n_points)], ...
                    [max((obj.c_normalized_mean(:, i) - obj.c_normalized_sd(:, i))', zeros(1, obj.n_points)) fliplr((obj.c_normalized_mean(:, i) + obj.c_normalized_sd(:, i))')], ...
                    obj.colors(i, :), 'EdgeColor','None', 'FaceAlpha', .2); 
                
                ylabel(sprintf(['temporal #' num2str(i)]));
                ylim([0 1]); 
                axis(axis);

                set(gca, 'YTick', [0 0.5 1]);
                set(gca, 'YTickLabel', {'0' '50%' '100%'});
                if i < obj.n_synergies
                    set(gca,'XTick',[]);
                else
                    set(gca, 'XTick', 0:40:200);
                    set(gca, 'XTickLabel', 0:20:100);
                    xlabel('% of movement cycle'); 
                    ylabel(sprintf([ '[percent of max EMG]\n' 'temporal #' num2str(i)]));
                end
            end
        end
        
        
        function draw_synergies(obj)
            axes('Parent', obj.handle_obj);
            
            for i = 1 : obj.n_synergies
                subplot('Position', [.55, .08+(obj.n_synergies-i)*.83/obj.n_synergies, .35, .75/obj.n_synergies]);

                for j = 1 : obj.n_emg        
                    bar(j, obj.w_normalized(j, i), 'FaceColor', obj.colors(i, :), 'Tag', ['syn_' num2str(j) '_' num2str(i)], 'FaceAlpha', .7); hold on;
                end
                ylabel(sprintf(['synergy #' num2str(i)]));
                ylim([0 1.05]); 

                set(gca, 'YTick', [0 0.5 1]);
                set(gca, 'YTickLabel', {'0' '50%' '100%'});
                
                if i < obj.n_synergies
                    set(gca,'XTick',[]);
                else
                    set(gca, 'XTick', 1:obj.n_emg);
                    set(gca, 'XTickLabel', obj.emg_label);
                    set(gca, 'XTickLabelRotation', 90);
                    ylabel(sprintf([ '[EMG impact]\n' 'synergy #' num2str(i)]));
                end
            end
        end
        
        
        function draw_emg_decomposition(obj)
            axes('Parent', obj.handle_obj);
            
            for i = 1 : obj.n_emg
                subplot('Position', [.1, .1+(obj.n_emg-i)*.8/obj.n_emg, .25, .7/obj.n_emg]);
                
                h = area(obj.c_normalized_mean .* repelem(obj.w_normalized(i, :), obj.n_points, 1), 'LineStyle', 'None', 'FaceAlpha', .7);
                for j = 1:obj.n_synergies h(j).FaceColor = obj.colors(j, :); end
                hold on;
                
                plot(obj.emg_patterns(:, i), 'Color', [.3 .3 .3], 'LineWidth', 1, 'Tag', ['pattern_' num2str(i)]); hold on;
                emg_sd = fill([1:obj.n_points fliplr(1:obj.n_points)], ...
                    [max((obj.emg_patterns(:, i) - obj.emg_patterns_sd(:, i))', zeros(1, obj.n_points)) fliplr((obj.emg_patterns(:, i) + obj.emg_patterns_sd(:, i))')], ...
                    [.8 .8 .8], 'EdgeColor', 'None', 'FaceAlpha', .2); 
                
                xlim([1 200]);
                ylim([0 1.05]);
                ylabel(sprintf([obj.emg_label{i}]), 'Rotation', 0, 'VerticalAlignment','middle', 'HorizontalAlignment','right');
                
                set(gca, 'YTick', [0 0.5 1]);
                set(gca, 'YTickLabel', {'0' '50%' '100%'});   
                
                if i == 1
                    ylabel(sprintf(['[%% of max]\n\n' obj.emg_label{i} '\n\n']), 'Rotation', 0, 'VerticalAlignment','middle', 'HorizontalAlignment','right');
                end
                
                if i < obj.n_emg
                    set(gca,'XTick',[]);
                else
                    set(gca, 'XTick', 0:40:200); 
                    set(gca, 'XTickLabel', 0:20:100);                    
                    xlabel('percent of movement cycle'); 
                end
            end
        end
        
        
        function draw_emg_vaf(obj)
            axes('Parent', obj.handle_obj);
            
            for i = 1 : obj.n_emg
                weight_sum = sum(obj.w_normalized(i, :));
                muscle_vaf = obj.nmf_r2(obj.n_synergies, i+1);
                norm_weight = weight_sum / muscle_vaf;
                
                subplot('Position', [.4, .1+(obj.n_emg-i)*.8/obj.n_emg, .2, .7/obj.n_emg]);
                
                h = barh([obj.w_normalized(i, :) / norm_weight; nan(size(obj.w_normalized(i, :)))], 'stacked', 'FaceAlpha', .7, 'Tag', ['vaf_' num2str(i)]);
                for j = 1:obj.n_synergies h(j).FaceColor = obj.colors(j, :); end
                hold on; 
                
                xlim([0 1]);
                ylim([0.7 1.3]);
                set(gca,'YTick',[]);                
                
                ylabel(num2str(muscle_vaf, 2), 'Rotation', 0, 'VerticalAlignment','middle', 'HorizontalAlignment','right');                
                
                if i < obj.n_emg
                    set(gca,'XTick',[]);
                else                 
                    xlabel('Variance accounted for'); 
                end
            end
        end
        
                
        function draw_variance(obj)
            axes('Parent', obj.handle_obj);
            n_to_plot = max([8 obj.n_synergies + 2]);
            
            subplot('Position', [.67, .1, .28, .75]);            
            plot(obj.nmf_r2(1:n_to_plot, 1), 'Color', 'k', 'Marker', 'o', 'LineWidth', 2, 'MarkerEdgeColor','None', 'MarkerFaceColor',[.6 .6 .6], 'MarkerSize', 8, 'Tag', 'total_plot');
            title('Total variance accounted for');
            t = text([1:n_to_plot] + 0.1, obj.nmf_r2(1:n_to_plot, 1) - 0.02, num2str(obj.nmf_r2(1:n_to_plot, 1), 3));
            t(obj.n_synergies).Color = 'r';
            xlim([0 n_to_plot+1])
            ylim([0 1])
            set(gca, 'YTick', 0:0.2:1);
            xlabel('Number of synergies');
            ylabel('VAF');
        end
        
        
        function link_axes(obj)
            temporal_axes = find_axes_by_plot(obj.handle_obj, 'temporal_*');
            if ~ isempty(temporal_axes) linkaxes(temporal_axes, 'xy'); end
            syn_axes = find_axes_by_plot(obj.handle_obj, 'syn_*');
            if ~ isempty(syn_axes) linkaxes(syn_axes, 'xy'); end
            pattern_axes = find_axes_by_plot(obj.handle_obj, 'pattern_*');
            if ~ isempty(pattern_axes) linkaxes(pattern_axes, 'xy'); end
            vaf_axes = find_axes_by_plot(obj.handle_obj, 'vaf_*');
            if ~ isempty(vaf_axes) linkaxes(vaf_axes, 'xy'); end
        end
        
        
        function fig_list_selection(obj, ~, ~)
            selected = get(obj.fig_list, 'Value');
            selected = obj.fig_list.String{selected};
            
            switch selected
                case 'Temporal components'
                    axes_all = findobj(allchild(obj.handle_obj), 'flat', 'Type', 'axes');
                    delete(axes_all);
                    obj.draw_temporal_components();
                    obj.draw_synergies();
                case 'EMG decomposition + VAF'
                    axes_all = findobj(allchild(obj.handle_obj), 'flat', 'Type', 'axes');
                    delete(axes_all);
                    obj.draw_emg_decomposition();
                    obj.draw_emg_vaf();
                    obj.draw_variance();
            end
            
            obj.link_axes()
        end
        
    end
    
end
