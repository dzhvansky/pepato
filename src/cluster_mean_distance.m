function dist = cluster_mean_distance(features, cluster_center)
% size = [n_samples, n_features]
n_features = size(features, 2);

dist = sqrt(sum((features - cluster_center) .^ 2, 2) / n_features);

end