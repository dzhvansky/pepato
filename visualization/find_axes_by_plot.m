function axes_ = find_axes_by_plot(handle_obj, plot_tag_regexp)

axes_ = [];

handlers = findobj(allchild(handle_obj), '-regexp', 'Tag', plot_tag_regexp);

if length(handlers) > 1
    for h = handlers
        ax = get(h, 'parent');
        axes_ = [axes_, ax{:}];
    end
else
    axes_ = get(handlers, 'parent');

end