function output = module_clustering(database, N_clusters, mean_threshold, max_threshold, ordering)
% the "database" parameter can be both a string (path to the PEPATO database) and a table

if nargin < 3
    mean_threshold = 0.8;
    max_threshold = 2.0;
    ordering = [];
elseif nargin < 4
    max_threshold = 2.0;
    ordering = [];
elseif nargin < 5
    ordering = [];
end

% load table if the "database" parameter is a path to the database
if isa(database, 'char')
    db_path = database;
    loaded = load(database);
    database = loaded.module_database;
else
    db_path = [];
end

if ~isempty(ordering)
    loaded = load(ordering);
    ordered_modules = loaded.ordered_modules;
end


columns = database.Properties.VariableNames;
idx_weights = find_cell_contains(columns, '_weight');
idx_patterns = find_cell_contains(columns, 'pattern_[\d]+', '-regexp');
n_muscles = length(idx_weights);
n_points = length(idx_patterns);

[~, unique_idx] = unique(database.('condition'));
conditions = database.('condition')(unique_idx)';
conditions = [{'all_conditions'}, conditions];
n_conditions = length(conditions);


output_params = {'cluster_center', 'scaler_mean', 'scaler_std', 'weight_mean', 'weight_sd', 'pattern_mean', 'pattern_sd'};
% excluded params: 'cluster_idx', 'include_mask' 
struct_1_lvl = cell2struct(cell(1, length(output_params)), output_params, 2);

cell_conditions = cell(1, n_conditions);
[cell_conditions{:}] = deal(struct_1_lvl);

output = cell2struct(cell(1, 5), {'N_clusters', 'mean_threshold', 'max_threshold', 'muscle_list', 'data'}, 2);

output.('N_clusters') = N_clusters;
output.('mean_threshold') = mean_threshold;
output.('max_threshold') = max_threshold;
output.('muscle_list') = cellfun (@(x) x(1:end-7), columns(idx_weights), 'un', 0);
output.('data') = cell2struct(cell_conditions, conditions, 2);


for j = 1:n_conditions
    
    condition = conditions{j};
    if strcmp(condition, 'all_conditions')
        row_idx = 1:size(database, 1);
    else
        row_idx = cell2mat(cellfun(@(x) strcmp(x, condition), database.('condition'), 'un', 0));
    end
    
    weights = database{row_idx, idx_weights}; 
    patterns = database{row_idx, idx_patterns};
    
    [features, norm_patterns, output.('data').(condition).('scaler_mean'), ...
        output.('data').(condition).('scaler_std')] = get_cluster_features(weights, patterns);

    % k-means
    [cluster_idx, cluster_center] = kmeans(features, N_clusters, 'Replicates', 100);
    if ~isempty(ordering)
        [cluster_idx, cluster_center] = get_cluster_order(cluster_idx, cluster_center, ordered_modules);
    end
    % cluster_center_orig = cluster_center .* repmat(scaler_std, N_clusters, 1) + repmat(scaler_mean, N_clusters, 1);
    include_mask = get_cluster_mask(features, cluster_idx, cluster_center, mean_threshold, max_threshold); 
    output.('data').(condition).('cluster_center') = cluster_center;

    weight_mean = zeros(N_clusters, n_muscles);
    weight_sd = zeros(N_clusters, n_muscles);
    pattern_mean = zeros(N_clusters, n_points);
    pattern_sd = zeros(N_clusters, n_points);

    for i = 1:N_clusters
        cluster_mask = (include_mask) & (cluster_idx == i);

        weight_mean(i, :) = mean(weights(cluster_mask, :), 1);
        weight_sd(i, :) = std(weights(cluster_mask, :), 1);
        pattern_mean(i, :) = mean(norm_patterns(cluster_mask, :), 1);
        pattern_sd(i, :) = std(norm_patterns(cluster_mask, :), 1);
    end

    output.('data').(condition).('weight_mean') = weight_mean;
    output.('data').(condition).('weight_sd') = weight_sd;
    output.('data').(condition).('pattern_mean') = pattern_mean;
    output.('data').(condition).('pattern_sd') = pattern_sd;
    
end

% save output structure if the path is known
if isa(db_path, 'char')
    v = genvarname(['clustering_' int2str(N_clusters)]);
    eval([v ' = output']);
    save(db_path, ['clustering_' int2str(N_clusters)], '-append');
end

end