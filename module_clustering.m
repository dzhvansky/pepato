function output = module_clustering(database, N_clusters, mean_threshold, max_threshold)
% the "database" parameter can be both a string (path to the PEPATO database) and a table

if nargin < 3
    mean_threshold = 0.8;
    max_threshold = 2.0;
elseif nargin < 4
    max_threshold = 2.0;
end

output_params = {'N_clusters', 'mean_threshold', 'max_threshold', 'muscle_list', 'cluster_idx', 'include_mask', ...
    'cluster_center', 'scaler_mean', 'scaler_std', 'weight_mean', 'weight_sd', 'pattern_mean', 'pattern_sd'};
output = cell2struct(cell(1, length(output_params)), output_params, 2);

output.('N_clusters') = N_clusters;
output.('mean_threshold') = mean_threshold;
output.('max_threshold') = max_threshold;


% load table if the "database" parameter is a path to the database
if isa(database, 'char')
    db_path = database;
    loaded = load(database);
    database = loaded.module_database;
else
    db_path = [];
end

columns = database.Properties.VariableNames;
idx_weights = find_cell_contains(columns, '_weight');
idx_patterns = find_cell_contains(columns, 'pattern_[\d]+', 'regexp');

output.('muscle_list') = cellfun (@(x) x(1:end-7), columns(idx_weights), 'un', 0);

weights = database{:, idx_weights}; 
patterns = database{:, idx_patterns};
n_muscles = size(weights, 2);
n_points = size(patterns, 2);

[features, norm_patterns, output.('scaler_mean'), output.('scaler_std')] = get_cluster_features(weights, patterns);


% k-means
[cluster_idx, cluster_center] = kmeans(features, N_clusters, 'Replicates', 100);
% cluster_center_orig = cluster_center .* repmat(scaler_std, N_clusters, 1) + repmat(scaler_mean, N_clusters, 1);
include_mask = get_cluster_mask(features, cluster_idx, cluster_center, mean_threshold, max_threshold); 

output.('cluster_idx') = cluster_idx;
output.('cluster_center') = cluster_center;
output.('include_mask') = include_mask;

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

output.('weight_mean') = weight_mean;
output.('weight_sd') = weight_sd;
output.('pattern_mean') = pattern_mean;
output.('pattern_sd') = pattern_sd;


% save output structure if the path is known
if isa(db_path, 'char')
    v = genvarname(['clustering_' int2str(N_clusters)]);
    eval([v ' = output']);
    save(db_path, ['clustering_' int2str(N_clusters)], '-append');
end

end