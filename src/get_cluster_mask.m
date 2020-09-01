function include_mask = get_cluster_mask(features, cluster_idx, cluster_center, mean_threshold, max_threshold)

mean_dist = cluster_mean_distance(features, cluster_center(cluster_idx, :));
max_dist = max(abs(features - cluster_center(cluster_idx, :)), [], 2);

include_mask = (mean_dist < mean_threshold) & (max_dist < max_threshold);

end