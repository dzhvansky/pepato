function [cluster_idx, cluster_center] = get_cluster_order(cluster_idx, cluster_center, ordered_modules)

n_modules = size(ordered_modules, 1);
order = zeros(n_modules, 1);

for i = 1:n_modules
    reference = ordered_modules(i, :)';
    corr = corrcoef([reference cluster_center']);
    [~, order(i)] = max(corr(1, 2:end));
end

cluster_center = cluster_center(order, :);
[~, cluster_idx] = ismember(cluster_idx, order);

end